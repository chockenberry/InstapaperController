//
//  AuthorizationViewController.m
//  Instapoopin
//
//  Created by Craig Hockenberry on 11/11/12.
//  Copyright (c) 2012 Craig Hockenberry. All rights reserved.
//

#import "AuthorizationViewController.h"

@interface AuthorizationViewController () <UITextFieldDelegate>

@property (nonatomic, strong) IBOutlet UITextField *emailTextField;
@property (nonatomic, strong) IBOutlet UITextField *passwordTextField;

- (IBAction)login;
- (IBAction)cancel;

@end

@implementation AuthorizationViewController

@synthesize email = _email, password = _password;
@synthesize delegate = _delegate;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
    }
    return self;
}

- (void)viewDidLoad
{
	self.emailTextField.text = _email;
	self.emailTextField.delegate = self;
	self.emailTextField.autocorrectionType = UITextAutocorrectionTypeNo;
	self.emailTextField.autocapitalizationType = UITextAutocapitalizationTypeNone;
	self.emailTextField.keyboardType = UIKeyboardTypeEmailAddress;

	self.passwordTextField.text = _password;
	self.passwordTextField.delegate = self;
	self.passwordTextField.autocorrectionType = UITextAutocorrectionTypeNo;
	self.passwordTextField.autocapitalizationType = UITextAutocapitalizationTypeNone;
	self.passwordTextField.secureTextEntry = YES;

	[self.emailTextField becomeFirstResponder];

    [super viewDidLoad];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Properties

- (NSString *)email
{
	_email = self.emailTextField.text;
	return _email;
}

- (void)setEmail:(NSString *)email
{
	if (email != _email) {
		_email = email;
		self.emailTextField.text = _email;
	}
}

- (NSString *)password
{
	_password = self.passwordTextField.text;
	return _password;
}

- (void)setPassword:(NSString *)password
{
	if (password != _password) {
		_password = password;
		self.passwordTextField.text = _password;
	}
}

#pragma makr - Actions

- (IBAction)login
{
	_email = self.emailTextField.text;
	_password = self.passwordTextField.text;

	[self.delegate authorizationViewControllerDidDismiss:self];
}

- (IBAction)cancel
{
	_email = self.emailTextField.text;
	_password = self.passwordTextField.text;

	[self.delegate authorizationViewControllerDidCancel:self];
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
	if (textField == self.emailTextField) {
		[self.emailTextField becomeFirstResponder];
	}
	else if (textField == self.passwordTextField) {
		[self.delegate authorizationViewControllerDidDismiss:self];
	}
	return NO;
}


@end
