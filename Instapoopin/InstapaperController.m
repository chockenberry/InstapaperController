//
//  InstapaperController.m
//
//  Created by Craig Hockenberry on 11/8/12.
//

#import "InstapaperController.h"

#ifdef DEBUG
	#define InstapaperDebugLog(...) NSLog(__VA_ARGS__)
#else
	#define InstapaperDebugLog(...) 
#endif

NSString *const InstapaperControllerNeedsAuthorizationNotification = @"InstapaperControllerNeedsAuthorizationNotification";
NSString *const InstapaperControllerResetAuthorizationNotification = @"InstapaperControllerResetAuthorizationNotification";
NSString *const InstapaperControllerDidSaveNotification = @"InstapaperControllerDidSaveNotification";
NSString *const InstapaperControllerDidFailNotification = @"InstapaperControllerDidFailNotification";

NSString *const InstapaperControllerFailStatusCode = @"statusCode";


@interface InstapaperController ()

@property (nonatomic, copy, readwrite) NSString *userName;
@property (nonatomic, copy, readwrite) NSString *password;
@property (nonatomic, copy, readwrite) NSURL *URL;
@property (nonatomic, copy, readwrite) NSString *description;

@property (nonatomic, assign, readwrite, getter=isSending) BOOL sending;

@end


@implementation InstapaperController
{
	NSURLConnection *_connection;
}

@synthesize userName = _userName, password = _password, URL = _URL, description = _description;
@synthesize sending = _sending;

+ (InstapaperController *)sharedInstapaperController
{
    static id sharedInstapaperControllerInstance = nil;
	
	if (! sharedInstapaperControllerInstance) {
		sharedInstapaperControllerInstance = [InstapaperController new];
		InstapaperDebugLog(@"%s created shared instance", __PRETTY_FUNCTION__);
	}

	return sharedInstapaperControllerInstance;
}

#pragma mark -

+ (BOOL)isInstapaperAppInstalled
{
#if TARGET_OS_IPHONE
#if DEBUG
	// since it's unlikely that you'll have Instapaper installed in the iOS Simulator, fake it if the DEBUG flag is set
	return YES;
#else
	return [[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"instapaper:///"]];
#endif
#else
	return NO;
#endif
}

#pragma mark -

- (void)setAuthorizationUserName:(NSString *)userName password:(NSString *)password
{
	self.userName = userName;
	self.password = password;
}

- (NSString *)encodeURLParameter:(NSString *)parameter
{
    return CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault, (__bridge CFStringRef)parameter, NULL, (CFStringRef)@"?=&+:/", kCFStringEncodingUTF8));
}

- (BOOL)sendURL:(NSURL *)URL withDescription:(NSString *)description
{
	BOOL result = NO;
	if (! self.isSending) {
		self.URL = URL;
		self.description = description;
		
		if (self.userName && [self.userName length] > 0) {
			if (self.URL) {
				NSString *encodedUserName = [self encodeURLParameter:self.userName];
				NSString *encodedURL = [self encodeURLParameter:[self.URL absoluteString]];

				NSMutableString *encodedParameters = [NSMutableString stringWithFormat:@"url=%@&username=%@", encodedURL, encodedUserName];
				if (self.password && [self.password length] > 0) {
					NSString *encodedPassword = [self encodeURLParameter:self.password];
					[encodedParameters appendFormat:@"&password=%@", encodedPassword];
				}
				if (self.description && [self.description length] > 0) {
					NSString *encodedDescription = [self encodeURLParameter:self.description];
					[encodedParameters appendFormat:@"&selection=%@", encodedDescription];
				}

				InstapaperDebugLog(@"%s encodedParameters = %@", __PRETTY_FUNCTION__, encodedParameters);
				NSData *body = [encodedParameters dataUsingEncoding:NSUTF8StringEncoding];
				
				NSMutableURLRequest *request = [NSMutableURLRequest new];
				[request setCachePolicy:NSURLRequestReloadIgnoringCacheData];
				[request setHTTPShouldHandleCookies:NO];
				[request setHTTPMethod:@"POST"];
				[request setURL:[NSURL URLWithString:@"https://www.instapaper.com/api/add"]];
				[request setHTTPBody:body];

				if (request) {
					_connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
					[_connection start];
					result = YES;
					self.sending = YES;
				}
			}
		}
		else {
			// a user name is required, post a notification that authorization is needed
			[[NSNotificationCenter defaultCenter] postNotificationName:InstapaperControllerNeedsAuthorizationNotification object:self];
		}
	}
	
	return result;
}

- (BOOL)retry
{
	NSURL *lastURL = self.URL;
	NSString *lastDescription = self.description;
	return [self sendURL:lastURL withDescription:lastDescription];
}

- (void)cancel
{
	self.sending = NO;

	[_connection cancel];
	_connection = nil;
}

- (void)reset
{
	self.userName = nil;
	self.password = nil;

	[[NSNotificationCenter defaultCenter] postNotificationName:InstapaperControllerResetAuthorizationNotification object:self];
}


#pragma mark - NSURLConnectionDelegate

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSHTTPURLResponse *)response
{
	NSInteger statusCode = [response statusCode];
	if (connection == _connection) {
        // change the sending state and ensure that we don't hear anything more from this connection
		[self cancel];
		
		NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
		if (statusCode == 201) {
			InstapaperDebugLog(@"%s saved URL = %@", __PRETTY_FUNCTION__, self.URL);
			[notificationCenter postNotificationName:InstapaperControllerDidSaveNotification object:self];
		}
		else if (statusCode == 403) {
			InstapaperDebugLog(@"%s need authorization for URL = %@", __PRETTY_FUNCTION__, self.URL);
			[notificationCenter postNotificationName:InstapaperControllerNeedsAuthorizationNotification object:self];
		}
		else {
			InstapaperDebugLog(@"%s failed with %d for URL = %@", __PRETTY_FUNCTION__, statusCode, self.URL);
			NSDictionary *userInfo = [NSDictionary dictionaryWithObject:[NSNumber numberWithInteger:statusCode] forKey:InstapaperControllerFailStatusCode];
			[notificationCenter postNotificationName:InstapaperControllerDidFailNotification object:self userInfo:userInfo];
		}
	}
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
	if (connection == _connection) {
		// change the sending state and ensure that we don't hear anything more from this connection
		[self cancel];
		InstapaperDebugLog(@"%s connection failed for URL = %@", __PRETTY_FUNCTION__, self.URL);
		NSDictionary *userInfo = [NSDictionary dictionaryWithObject:[NSNumber numberWithInteger:0] forKey:InstapaperControllerFailStatusCode];
		[[NSNotificationCenter defaultCenter] postNotificationName:InstapaperControllerDidFailNotification object:self userInfo:userInfo];
	}
}

@end
