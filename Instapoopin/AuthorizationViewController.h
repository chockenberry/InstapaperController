//
//  AuthorizationViewController.h
//  Instapoopin
//
//  Created by Craig Hockenberry on 11/11/12.
//  Copyright (c) 2012 Craig Hockenberry. All rights reserved.
//

#import <UIKit/UIKit.h>


@class AuthorizationViewController;

@protocol AuthorizationViewControllerDelegate <NSObject>

- (void)authorizationViewControllerDidDismiss:(AuthorizationViewController *)viewController;
- (void)authorizationViewControllerDidCancel:(AuthorizationViewController *)viewController;

@end


@interface AuthorizationViewController : UIViewController

@property (nonatomic, weak) id<AuthorizationViewControllerDelegate> delegate;

@property (nonatomic, strong) NSString *email;
@property (nonatomic, strong) NSString *password;

@end
