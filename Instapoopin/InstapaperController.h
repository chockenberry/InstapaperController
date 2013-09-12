//
//  InstapaperController.h
//
//  Created by Craig Hockenberry on 11/8/12.
//

// This controller implements the Simple Instapaper API that is described here: http://www.instapaper.com/api/simple


#import <Foundation/Foundation.h>

// Notifications

extern NSString *const InstapaperControllerNeedsAuthorizationNotification;
	// It's your responsibility to provide an email/username and password to the controller (using whatever UI you want in your app).
	// If the authorization hasn't been set, or if it fails when sending a URL to the Instapaper server, this notification will be posted.
	
extern NSString *const InstapaperControllerResetAuthorizationNotification;
	// You can call the -reset method to remove the current authorization information from the controller. This notification will be posted
	// after the email/username and password are set to nil.
	
extern NSString *const InstapaperControllerDidSaveNotification;
	// This notification is posted after a URL is successfully posted to the Instapaper server. The notificatation object's URL and description
	// properties are still valid if you need to include them in a success confirmation.
	
extern NSString *const InstapaperControllerDidFailNotification;
extern NSString *const InstapaperControllerFailStatusCode;
	// This notification is posted if a URL could not be sent to the Instapaper server. The notification's userInfo includes a
	// InstapaperControllerFailStatusCode key. The InstapaperControllerFailStatusCode is 0 if the connection failed (e.g. there's no Internet
	// connection.) Otherwise, the Instapaper server's response is used (400 for a bad request, or 500 for a server error.)


@interface InstapaperController : NSObject

@property (nonatomic, copy, readonly) NSString *userName; // probably an email address, but the parameter sent to the server is a "username"
@property (nonatomic, copy, readonly) NSString *password;
@property (nonatomic, copy, readonly) NSURL *URL;
@property (nonatomic, copy, readonly) NSString *description;

@property (nonatomic, assign, readonly, getter=isSending) BOOL sending;

+ (InstapaperController *)sharedInstapaperController;

// checks to see if the Instapaper app is installed on the device
+ (BOOL)isInstapaperAppInstalled;
	// If the Instapaper URL scheme can be opened, then we can assume that the user has installed Instapaper. Note that this controller
	// does not depend on the Instapaper app being installed: all authentication and communication is done directly with the server. This
	// method is useful if your app needs to decide whether a "Send to Instapaper" button should be included or not.
	
// sets the authorization used the communicate with the Instapaper server
- (void)setAuthorizationUserName:(NSString *)userName password:(NSString *)password;

// sends the URL and description to the Instapaper server
- (BOOL)sendURL:(NSURL *)URL withDescription:(NSString *)description;
	// Returns NO if already sending a URL or if there was an error creating the request.

// tries sending the last URL and description again
- (BOOL)retry;
	// This method is typically used after the authorization with the Instapaper server has failed. Returns NO if already sending a URL or
	// if there was an error creating the request.

// cancels a connection that's currently being sent
- (void)cancel;

// resets the authorization
- (void)reset;

@end
