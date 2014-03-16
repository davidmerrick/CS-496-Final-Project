//
//  FirstViewController.m
//  SocialCollage
//
//  Created by David Merrick on 3/2/14.
//  Copyright (c) 2014 David Merrick. All rights reserved.
//

#import "LoginUIViewController.h"
#import "AppDelegate.h"

@interface LoginUIViewController ()
@property (strong, nonatomic) IBOutlet FBProfilePictureView *profilePictureView;
@property (strong, nonatomic) IBOutlet UILabel *nameLabel;
@property (strong, nonatomic) IBOutlet UILabel *statusLabel;
- (IBAction)buttonTouched:(id)sender;
@end

@implementation LoginUIViewController

-(void)getFacebookInfo
{
	//@todo: make this just return a string instead of setting a class property
	FBRequest *request = [FBRequest requestForGraphPath:@"me/?fields=name"];
	[request startWithCompletionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
		if (result) {
			//Set the profile picture and the name
			self.profilePictureView.profileID = [result objectForKey:@"id"];
			self.nameLabel.text = [result objectForKey:@"name"];
		}
	}];
}

-(void)userLoggedOut
{
	self.profilePictureView.profileID = nil;
	self.nameLabel.text = @"";
	self.statusLabel.text= @"You're not logged in";
	[self.loginButton setTitle:@"Log in with Facebook" forState:UIControlStateNormal];
}

-(void)userLoggedIn
{
	self.statusLabel.text = @"You're logged in as";
	[self.loginButton setTitle:@"Log out" forState:UIControlStateNormal];
	[self getFacebookInfo];
}

-(void)viewDidLoad
{
	//Check if they're logged in
	if(FBSession.activeSession.isOpen){
		[self userLoggedIn];
	} else {
		[self userLoggedOut];
	}
}

// This method will be called when the user information has been fetched
- (void)loginViewFetchedUserInfo:(FBLoginView *)loginView
                            user:(id<FBGraphUser>)user {
	self.profilePictureView.profileID = user.id;
	self.nameLabel.text = user.name;
}

// Implement the loginViewShowingLoggedInUser: delegate method to modify your app's UI for a logged-in user experience
- (void)loginViewShowingLoggedInUser:(FBLoginView *)loginView {
	self.statusLabel.text = @"You're logged in as";
}

// Implement the loginViewShowingLoggedOutUser: delegate method to modify your app's UI for a logged-out user experience
- (void)loginViewShowingLoggedOutUser:(FBLoginView *)loginView {
	self.profilePictureView.profileID = nil;
	self.nameLabel.text = @"";
	self.statusLabel.text= @"You're not logged in!";
}

// You need to override loginView:handleError in order to handle possible errors that can occur during login
- (void)loginView:(FBLoginView *)loginView handleError:(NSError *)error {
	NSString *alertMessage, *alertTitle;
	
	// If the user should perform an action outside of you app to recover,
	// the SDK will provide a message for the user, you just need to surface it.
	// This conveniently handles cases like Facebook password change or unverified Facebook accounts.
	if ([FBErrorUtility shouldNotifyUserForError:error]) {
		alertTitle = @"Facebook error";
		alertMessage = [FBErrorUtility userMessageForError:error];
		
		// This code will handle session closures since that happen outside of the app.
		// You can take a look at our error handling guide to know more about it
		// https://developers.facebook.com/docs/ios/errors
	} else if ([FBErrorUtility errorCategoryForError:error] == FBErrorCategoryAuthenticationReopenSession) {
		alertTitle = @"Session Error";
		alertMessage = @"Your current session is no longer valid. Please log in again.";
		
		// If the user has cancelled a login, we will do nothing.
		// You can also choose to show the user a message if cancelling login will result in
		// the user not being able to complete a task they had initiated in your app
		// (like accessing FB-stored information or posting to Facebook)
	} else if ([FBErrorUtility errorCategoryForError:error] == FBErrorCategoryUserCancelled) {
		NSLog(@"user cancelled login");
		
		// For simplicity, this sample handles other errors with a generic message
		// You can checkout our error handling guide for more detailed information
		// https://developers.facebook.com/docs/ios/errors
	} else {
		alertTitle  = @"Something went wrong";
		alertMessage = @"Please try again later.";
		NSLog(@"Unexpected error:%@", error);
	}
	
	if (alertMessage) {
		[[[UIAlertView alloc] initWithTitle:alertTitle
									message:alertMessage
								   delegate:nil
						  cancelButtonTitle:@"OK"
						  otherButtonTitles:nil] show];
	}
}

- (IBAction)buttonTouched:(id)sender
{
	// If the session state is any of the two "open" states when the button is clicked
	if (FBSession.activeSession.state == FBSessionStateOpen
		|| FBSession.activeSession.state == FBSessionStateOpenTokenExtended) {
		
		// Close the session and remove the access token from the cache
		// The session state handler (in the app delegate) will be called automatically
		[FBSession.activeSession closeAndClearTokenInformation];
		
		// If the session state is not any of the two "open" states when the button is clicked
		
		//Show logged-out UI
		[self userLoggedOut];
	} else {
		// Open a session showing the user the login UI
		// You must ALWAYS ask for basic_info permissions when opening a session
				NSArray *permissions = @[@"basic_info", @"user_photo_video_tags", @"user_friends", @"user_photos", @"friends_photos", @"friends_photo_video_tags"];
		[FBSession openActiveSessionWithReadPermissions:permissions
										   allowLoginUI:YES
									  completionHandler:
		 ^(FBSession *session, FBSessionState state, NSError *error) {
			 
			 // Retrieve the app delegate
			 AppDelegate* appDelegate = [UIApplication sharedApplication].delegate;
			 // Call the app delegate's sessionStateChanged:state:error method to handle session state changes
			 [appDelegate sessionStateChanged:session state:state error:error];
		 }];
	}
}
@end
