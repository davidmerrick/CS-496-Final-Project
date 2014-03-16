//
//  FirstViewController.h
//  SocialCollage
//
//  Created by David Merrick on 3/2/14.
//  Copyright (c) 2014 David Merrick. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <FacebookSDK/FacebookSDK.h>

@interface LoginUIViewController : UIViewController <FBLoginViewDelegate>
@property (strong, nonatomic) IBOutlet UIButton *loginButton;

//Stuff from Facebook
@property (retain, nonatomic) NSString *username;
@end
