//
//  SettingsViewController.m
//  SocialCollage
//
//  Created by David Merrick on 3/15/14.
//  Copyright (c) 2014 David Merrick. All rights reserved.
//

#import "SettingsViewController.h"

@implementation SettingsViewController

- (IBAction)logOut:(id)sender
{
	// If the session state is any of the two "open" states when the button is clicked
	if (FBSession.activeSession.state == FBSessionStateOpen
		|| FBSession.activeSession.state == FBSessionStateOpenTokenExtended) {
		
		// Close the session and remove the access token from the cache
		// The session state handler (in the app delegate) will be called automatically
		[FBSession.activeSession closeAndClearTokenInformation];
	}
	
	//Show the logged out UI
	AppDelegate* appDelegate = [UIApplication sharedApplication].delegate;
	[appDelegate userLoggedOut];
	
}
@end
