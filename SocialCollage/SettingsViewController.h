//
//  SettingsViewController.h
//  SocialCollage
//
//  Created by David Merrick on 3/15/14.
//  Copyright (c) 2014 David Merrick. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <FacebookSDK/FacebookSDK.h>
#import "AppDelegate.h"

@interface SettingsViewController : UIViewController <FBLoginViewDelegate>
- (IBAction)logOut:(id)sender;
@end
