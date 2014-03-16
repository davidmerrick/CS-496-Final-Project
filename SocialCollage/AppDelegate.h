//
//  AppDelegate.h
//  SocialCollage
//
//  Created by David Merrick on 3/2/14.
//  Copyright (c) 2014 David Merrick. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <FacebookSDK/FacebookSDK.h>
#import "LoginUIViewController.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate>
@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) LoginUIViewController *customLoginViewController;
@property(nonatomic,strong)UITabBarController *tabBarController;

- (void)sessionStateChanged:(FBSession *)session state:(FBSessionState) state error:(NSError *)error;
- (void)userLoggedIn;
- (void)userLoggedOut;
@end
