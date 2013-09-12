//
//  ViewController.m
//  Instapoopin
//
//  Created by Craig Hockenberry on 11/11/12.
//  Copyright (c) 2012 Craig Hockenberry. All rights reserved.
//

#import "ViewController.h"

#import "AuthorizationViewController.h"

#import "InstapaperController.h"


@interface ViewController () <AuthorizationViewControllerDelegate>

@property (nonatomic, strong) IBOutlet UITextField *URLTextField;
@property (nonatomic, strong) IBOutlet UITextField *descriptionTextField;
@property (nonatomic, strong) IBOutlet UIButton *sendToInstapaperButton;

- (IBAction)sendToInstapaper;
- (IBAction)resetAuthorization;

@end


@implementation ViewController

@synthesize URLTextField, descriptionTextField, sendToInstapaperButton;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
	if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
		// NOTE: These notifications don't need to be handled in this view controller. If it makes more sense for your app, you could easily
		// put them in your application delegate or some place in your view controller hierarchy.
		NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
		[notificationCenter addObserver:self selector:@selector(instapaperNeedsAuthorizationNotification:) name:InstapaperControllerNeedsAuthorizationNotification object:nil];
		[notificationCenter addObserver:self selector:@selector(instapaperResetAuthorizationNotification:) name:InstapaperControllerResetAuthorizationNotification object:nil];
		[notificationCenter addObserver:self selector:@selector(instapaperDidSaveNotification:) name:InstapaperControllerDidSaveNotification object:nil];
		[notificationCenter addObserver:self selector:@selector(instapaperDidFailNotification:) name:InstapaperControllerDidFailNotification object:nil];

		// NOTE: It's probably better to do this in your application delegate or some other central place. Also, DO NOT store the user's password
		// unencrypted in the keychain in an app you submit to the App Store. People will find out and you'll feel stupid (that's the voice of
		// experience talking.)
		NSString *userName = [[NSUserDefaults standardUserDefaults] stringForKey:@"instapaperUserName"];
		NSString *password = [[NSUserDefaults standardUserDefaults] stringForKey:@"instapaperPassword"];
		InstapaperController *instapaperController = [InstapaperController sharedInstapaperController];
		[instapaperController setAuthorizationUserName:userName password:password];
	}
	return self;
}

- (void)dealloc
{
	[[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidLoad
{
	if ([InstapaperController isInstapaperAppInstalled]) {
		sendToInstapaperButton.enabled = YES;
	}
	else {
		sendToInstapaperButton.enabled = YES;
	}
	
    [super viewDidLoad];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

#pragma mark - Actions

- (void)sendToInstapaper
{
	if ([InstapaperController isInstapaperAppInstalled]) {
		NSURL *URL = [NSURL URLWithString:[URLTextField text]];
		NSString *description = [descriptionTextField text];
		[[InstapaperController sharedInstapaperController] sendURL:URL withDescription:description];
	}
}

- (void)resetAuthorization
{
	if ([InstapaperController isInstapaperAppInstalled]) {
		[[InstapaperController sharedInstapaperController] reset];
	}
}

#pragma mark - AuthorizationViewControllerDelegate

- (void)authorizationViewControllerDidDismiss:(AuthorizationViewController *)viewController
{
	[self dismissModalViewControllerAnimated:YES];

	NSString *userName = viewController.email;
	NSString *password = viewController.password;
	
	[[NSUserDefaults standardUserDefaults] setObject:userName forKey:@"instapaperUserName"];
	[[NSUserDefaults standardUserDefaults] setObject:password forKey:@"instapaperPassword"]; // USE THE KEY CHAIN IN YOUR APP OR YOUR A LOSER

	InstapaperController *instapaperController = [InstapaperController sharedInstapaperController];
	[instapaperController setAuthorizationUserName:userName password:password];
	[instapaperController retry];
}

- (void)authorizationViewControllerDidCancel:(AuthorizationViewController *)viewController
{
	[self dismissModalViewControllerAnimated:YES];
}

#pragma mark - Notifications

- (void)instapaperNeedsAuthorizationNotification:(NSNotification *)notification
{
	NSString *userName = [[NSUserDefaults standardUserDefaults] stringForKey:@"instapaperUserName"];
	NSString *password = [[NSUserDefaults standardUserDefaults] stringForKey:@"instapaperPassword"]; // USE THE KEY CHAIN IN YOUR APP OR YOUR A LOSER

	AuthorizationViewController *authorizationViewController = [[AuthorizationViewController alloc] initWithNibName:nil bundle:nil];
	authorizationViewController.delegate = self;
	authorizationViewController.email = userName;
	authorizationViewController.password = password;
	[self presentModalViewController:authorizationViewController animated:YES];
}

- (void)instapaperResetAuthorizationNotification:(NSNotification *)notification
{
	[[NSUserDefaults standardUserDefaults] removeObjectForKey:@"instapaperUserName"];
	[[NSUserDefaults standardUserDefaults] removeObjectForKey:@"instapaperPassword"]; // USE THE KEY CHAIN IN YOUR APP OR YOUR A LOSER
}

- (void)instapaperDidSaveNotification:(NSNotification *)notification
{
	InstapaperController *instapaperController = [InstapaperController sharedInstapaperController];
	NSString *message = [NSString stringWithFormat:@"Saved %@ (%@) to Instapaper", [instapaperController.URL absoluteString], instapaperController.description];
	UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Instapoopin'" message:message delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
	[alertView show];
}

- (void)instapaperDidFailNotification:(NSNotification *)notification
{
	NSDictionary *userInfo = [notification userInfo];
	NSNumber *statusCode = [userInfo objectForKey:InstapaperControllerFailStatusCode];
	
	InstapaperController *instapaperController = [InstapaperController sharedInstapaperController];
	NSString *message = [NSString stringWithFormat:@"Could not save %@ (%@) to Instapaper. Error code is %@.", [instapaperController.URL absoluteString], instapaperController.description, statusCode];
	UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Instapoopin'" message:message delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
	[alertView show];
}


@end
