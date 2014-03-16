//
//  PhotoGalleryViewController.m
//  SocialCollage
//
//  Created by David Merrick on 3/3/14.
//  Copyright (c) 2014 David Merrick. All rights reserved.
//
//@todo: Add settings modal for choosing whether to sort images by date, likes, etc
//			--Border: on/off
//			--Sorting options: date, likes
//			--Include current logged-in user in tags
//@todo: Add other template options
//@todo: Add ability to change the photos with some sort of FacebookImagePicker thing
//@todo: Add ability to crop/zoom images in template
//@todo: Add loading bar for when rendering final collage

#import "EditCollageViewController.h"

@implementation EditCollageViewController
@synthesize library;

- (void)viewDidLoad
{
    [super viewDidLoad];
	
	//Set the user's name
	[self getFacebookUserName];
	
	self.FinalCollageLabel.text = @"";
	
	//Init the long press gesture recognizer
	self.lpgr = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPressGestures:)];
	self.lpgr.minimumPressDuration = 1.0f;
	self.lpgr.allowableMovement = 100.0f;
    
	//Add the gesture recognizer to the finalCollage view
	self.finalCollage.userInteractionEnabled = YES;
	[self.finalCollage addGestureRecognizer:self.lpgr];
	
	//Add a tap gesture recognizer to each imagePane view
	for(UIImageView *imageView in self.imagePane){
		imageView.userInteractionEnabled = YES;
		[imageView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapGestures:)]];
		
		//Set the default behavior of the imageViews
		//Add a border
		[imageView.layer setBorderColor: [[UIColor blackColor] CGColor]];
		[imageView.layer setBorderWidth: 2.0];
		
		//Make the image clip to the bounds (so it crops and doesn't overflow)
		imageView.clipsToBounds = YES;
	}
}

-(void) viewDidUnload
{
	[super viewDidUnload];
	self.friendPickerController = nil;
	self.searchBar = nil;
}

// Show an alert message
- (void)showMessage:(NSString *)text withTitle:(NSString *)title
{
	UIAlertView *messageAlert = [[UIAlertView alloc] initWithTitle:title
														   message:text
														  delegate:self
												 cancelButtonTitle:@"Okay"
												 otherButtonTitles:nil];
	//Tag it so we know what type of alert it is (we have multiple alerts in this viewController)
	messageAlert.tag = messageAlertViewTag;
	[messageAlert show];
}

#pragma mark Image Processing

-(void) renderCollage
{
	FBRequest *fql = [FBRequest requestForGraphPath:@"fql"];
	
	NSString *queryString = [self constructQuery:(int)self.imagePane.count];
	
	[fql.parameters setObject:queryString forKey:@"q"];
	[fql startWithCompletionHandler:^(FBRequestConnection *connection,
									  id result,
									  NSError *error) {
		if (result) {
			//First, check if the result is empty
			NSArray *dataArray = [result objectForKey:@"data"];
			if(dataArray == nil || [dataArray count] == 0){
				[self showMessage:@"No photos were found that match your search criteria. Please try again." withTitle:@"Uh oh"];
				return;
			}
			
			//Parse the result
			//@todo: for some reason, this is loading images by likes backwards (e.g. most-liked image appears in bottom-left corner in image pane) We want these more prominent
			//Current solution is to go through imagePane images backwards but this seems hacky
			int i = (int)[self.imagePane count] - 1; //index in the imageArray
			for (NSDictionary *photoData in dataArray)
			{
				//Retrieve the photo URL
				id photoUrl = [photoData objectForKey:@"src_big"];
				
				//Set the UIImageview to the photo
				NSURL *imageURL = [NSURL URLWithString:photoUrl];
				NSData *imageData = [NSData dataWithContentsOfURL:imageURL];
				UIImageView *tempUV = [self.imagePane objectAtIndex:i];
				tempUV.image = [UIImage imageWithData:imageData];
				i--;
			}
			[self renderCollageFromImagePane];
		}
	}];
}

-(void) renderCollageFromImagePane
{
	//Join the images together
	CGSize size = CGSizeMake(2000, 2000);
	UIGraphicsBeginImageContext(size);
	
	//@todo: programmatically get the origin point by sorting the imagePane array -- origin point is currently hardcoded
	float scaleFactor = 12.5; //Scale factor of the 4 images to a 2000 x 2000 image
	//This loop draws the 850 x 850 px images
	for(int i = 0; i < self.imagePane.count; i++){
		//Resize the original image
		UIImageView *imageView = [self.imagePane objectAtIndex:i];
		UIImage *resizedImage = [self resizeImage:imageView.image scaledToSize:CGSizeMake(scaleFactor * imageView.frame.size.width, scaleFactor *imageView.frame.size.height)];
		//Subtract (80, 180) because this is the origin point within the view of the images
		CGPoint image1Point = CGPointMake(scaleFactor * (imageView.frame.origin.x - 80), scaleFactor * (imageView.frame.origin.y - 180));
		[resizedImage drawAtPoint:image1Point];
		
		//Set the imageView background to white after adding each image to it
		if(imageView.image){
			[imageView.layer setBackgroundColor:[[UIColor whiteColor] CGColor]];
		}
	}
	
	UIImage* finalImage = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
	
	self.FinalCollageLabel.text = @"Final Collage (tap and hold to share)";
	self.finalCollage.image = finalImage;
}


- (UIImage *)resizeImage:(UIImage*)originalImage scaledToSize:(CGSize)size
{
    //avoid redundant drawing
    if (CGSizeEqualToSize(originalImage.size, size))
    {
        return originalImage;
    }
	
	//Preserve the aspect ratio
	float oldWidth = originalImage.size.width;
    float oldHeight = originalImage.size.height;
	
	float scaleFactor;
	
	if(oldHeight > oldWidth){
			scaleFactor = size.height/oldHeight;
	} else {
			scaleFactor = size.width/oldWidth;
	}
	
    float newHeight = originalImage.size.height * scaleFactor;
    float newWidth = oldWidth * scaleFactor;
	
    //create drawing context
    UIGraphicsBeginImageContextWithOptions(size, NO, 0);
	
    //draw
    [originalImage drawInRect:CGRectMake(0, 0, newWidth, newHeight)];
	
    //capture resultant image
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
	
    //return image
    return image;
}

-(void)saveCollage
{
	//Saves the collage to the user's photos
	//@todo: stop saving it to test gallery, save to regular photos
	UIImage *finalImage = self.finalCollage.image;
	
	NSString *albumName = @"TestGallery";
	//Find the album
	__block ALAssetsGroup* groupToAddTo;
	[self.library enumerateGroupsWithTypes:ALAssetsGroupAlbum usingBlock:^(ALAssetsGroup *group, BOOL *stop) {
		//@todo: if album doesn't exist, create it
		if ([[group valueForProperty:ALAssetsGroupPropertyName] isEqualToString:albumName]) {
			// If album exists, put it in our group block
			groupToAddTo = group;
		}
	}
							  failureBlock:^(NSError* error) {
							  }];
	
	//Save the image to the album
	CGImageRef img = [finalImage CGImage];
	[self.library writeImageToSavedPhotosAlbum:img metadata:nil completionBlock:^(NSURL* assetURL, NSError* error) {
		if (error.code == 0) {
			// Try to get the asset
			[self.library assetForURL:assetURL resultBlock:^(ALAsset *asset) {
				// Add the photo to the album
				[groupToAddTo addAsset:asset];
			}
						 failureBlock:^(NSError* error) {
						 }];
		} else {
			//Save image failed
		}
	}];
}

-(void)pushCollageToCloud
{
	//Saves the collage to a Google App Engine app
	
	// Init the URLRequest
	NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
	NSString *boundary = @"----WebKitFormBoundaryS20yjrAmjaO2b04G"; //Form boundary
	[request setHTTPMethod:@"POST"];
	[request setURL:[NSURL URLWithString:@"http://2-dot-ermagherdkittygallery.appspot.com/"]];
	//[request setURL:[NSURL URLWithString:@"http://ermagherdkittygallery.appspot.com/uploader.jsp"]];
	[request setValue:@"max-age=0" forHTTPHeaderField:@"Cache-Control"];
	[request setValue:@"text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8" forHTTPHeaderField:@"Accept"];
	[request setValue:@"http://ermagherdkittygallery.appspot.com" forHTTPHeaderField:@"Origin"];
	[request setValue:@"SocialCollage App" forHTTPHeaderField:@"User-Agent"];
	[request setValue:[NSString stringWithFormat:@"multipart/form-data; boundary=%@", boundary] forHTTPHeaderField:@"Content-Type"];
	[request setValue:@"http://ermagherdkittygallery.appspot.com/" forHTTPHeaderField:@"Referer"];
	[request setValue:@"gzip,deflate,sdch" forHTTPHeaderField:@"Accept-Encoding"];
	[request setValue:@"en-US,en;q=0.8" forHTTPHeaderField:@"Accept-Language"];
	
	//IMAGE
	NSMutableData *postBody = [NSMutableData data];
    [postBody appendData:[[NSString stringWithFormat:@"\r\n--%@\r\nContent-Disposition: form-data; name=\"photo\"; filename=\"image.jpg\"\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
	[postBody appendData:[@"Content-Type: image/jpeg\r\n\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
	UIImage *yourImage= self.finalCollage.image;
	NSData *imageData = UIImageJPEGRepresentation(yourImage, 0.5);
    [postBody appendData:imageData];
	
	//Set the caption to the user's name. Then it'll say "Uploaded by: so-and-so"
	if(self.username){
		[postBody appendData:[[NSString stringWithFormat:@"\r\n--%@\r\nContent-Disposition: form-data; name=\"caption\"\r\n\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
		[postBody appendData:[self.username dataUsingEncoding:NSUTF8StringEncoding]];
	}
	
	//End the form
	[postBody appendData:[[NSString stringWithFormat:@"\r\n--%@--\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
	[request setHTTPBody:postBody];
	
    //send request
    NSData *responseData = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
    NSString *returnString = [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];
    NSLog(@"response: %@",returnString);
}

#pragma mark ImagePickerController

-(void)launchLocalImagePicker
{
	UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
	imagePicker.delegate = self;
	
	// Set the camera to be the source for picking images from
	imagePicker.sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
	imagePicker.mediaTypes = @[(NSString *) kUTTypeImage];
	
	//Keep it simple and don't allow users to edit photos before they're passed to the app
	imagePicker.allowsEditing = NO;
	[self presentViewController:imagePicker animated:YES completion:nil];
}

-(void)launchCameraImagePicker
{
	UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
	imagePicker.delegate = self;
	
	// Set the camera to be the source for picking images from
	imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
	imagePicker.mediaTypes = @[(NSString *) kUTTypeImage];
	
	//Keep it simple and don't allow users to edit photos before they're passed to the app
	imagePicker.allowsEditing = NO;
	[self presentViewController:imagePicker animated:YES completion:nil];
}

-(void)launchFacebookImagePicker
{
	int numImages = 10; //Number of images to fetch
	
	FBRequest *fql = [FBRequest requestForGraphPath:@"fql"];
	
	NSString *queryString = [self constructQuery:numImages];
	
	[fql.parameters setObject:queryString forKey:@"q"];
	
	//@todo: is this asynchronous? It's acting like it is
	[fql startWithCompletionHandler:^(FBRequestConnection *connection,
									  id result,
									  NSError *error) {
		if(result) {
			NSMutableArray *imageURLArray = [[NSMutableArray alloc] init];
			
			//First, check if the result is empty
			NSArray *dataArray = [result objectForKey:@"data"];
			if(dataArray == nil || [dataArray count] == 0){
				//[self showMessage:@"No photos were found that match your search criteria. Please try again." withTitle:@"Uh oh"];
				return;
			}
			
			//Instantiate the FacebookImagePickerController
			UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
			
			//@todo: have an init method in FacebookImagePickerController like initWithPickedFriends
			FacebookImagePickerController *facebookImagePicker = (FacebookImagePickerController*)[storyboard instantiateViewControllerWithIdentifier:@"FacebookImagePicker"];
			
			//Parse the result
			for (NSDictionary *photoData in dataArray)
			{
				//Retrieve the photo URL
				id photoUrl = [photoData objectForKey:@"src_big"];
				
				NSURL *imageURL = [NSURL URLWithString:photoUrl];
				
				//Add the image URL to the array
				[imageURLArray addObject:imageURL];
			}
			
			facebookImagePicker.imageURLArray = imageURLArray;
			
			//@todo: set up the delegate so we can retrieve images from it
			//	facebookImagePicker.delegate = self;
			
			[self presentViewController:facebookImagePicker animated:YES completion:nil];
		}
	}];
}

-(void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    //This tells the delegate that the user canceled the operation
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void)imagePickerController:(UIImagePickerController *)picker
didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    NSString *mediaType = info[UIImagePickerControllerMediaType];
    
    [self dismissViewControllerAnimated:YES completion:nil];
    
    // if kUTTypeImage (photo, not video), update that imageview with it
    if ([mediaType isEqualToString:(NSString *)kUTTypeImage]) {
        UIImage *image = info[UIImagePickerControllerOriginalImage];
		if(self.imagePaneToUpdate){
			self.imagePaneToUpdate.image = image;
			self.imagePaneToUpdate = nil;
			//Re-render the collage
			[self renderCollageFromImagePane];
		}
	}
}

#pragma mark Facebook Queries
//Builds the Facebook query based on the friends they picked
-(NSString*)constructQuery:(int)numItems
{
	NSString *queryString = [NSString stringWithFormat:@"SELECT pid, src_big, like_info FROM photo WHERE pid IN(SELECT pid FROM photo_tag WHERE subject = me()) "];
	
	if([self.pickedFriends count] != 0 && self.pickedFriends != nil){
		//Append the friend IDs to the query string
		
		for (NSString *userId in self.pickedFriends)
		{
			queryString = [queryString stringByAppendingString:[NSString stringWithFormat:@"AND pid IN(SELECT pid FROM photo_tag WHERE subject = %@)", userId]];
		}
	}
	
	queryString = [queryString stringByAppendingString:[NSMutableString stringWithFormat:@"ORDER BY like_info.like_count DESC LIMIT %d", numItems]];
	return queryString;
}

-(void) getFacebookUserName
{
	//@todo: make this just return a string instead of setting a class property
	FBRequest *request = [FBRequest requestForGraphPath:@"me/?fields=name"];
	[request startWithCompletionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
		if (result) {
			self.username = [result objectForKey:@"name"];
		}
	}];
}

#pragma mark ActionSheet stuff

- (void)actionSheet:(UIActionSheet *)popup clickedButtonAtIndex:(NSInteger)buttonIndex {
	switch (popup.tag) {
		case 1: { // Tag 1 is for sharing options
			switch (buttonIndex) {
				case 0: //Save to device
					[self saveCollage];
					[self showMessage:@"Collage Saved" withTitle:@"Success"];
					break;
				case 1: //Share to cloud
					[self pushCollageToCloud];
					[self showMessage:@"Pushed to Cloud" withTitle:@"Success"];
					break;
				default:
					break;
			}
			break;
		} case 2: { // Tag 2 is for selecting a photo
			switch (buttonIndex) {
				case 0: //Choose from Facebook photos
					[self launchFacebookImagePicker];
					break;
				case 1: //Choose from local photos
					[self launchLocalImagePicker];
					break;
				case 2: //Open camera
					[self launchCameraImagePicker];
					break;
				default:
					break;
			}
			break;
		}
		default:
			break;
	}
}

#pragma mark Gesture Recognizers

- (void)handleLongPressGestures:(UILongPressGestureRecognizer *)sender
{
    if ([sender isEqual:self.lpgr]) {
        if (sender.state == UIGestureRecognizerStateBegan)
        {
			if(self.finalCollage.image){
				//Pop up the sharing action menu
				UIActionSheet *popup = [[UIActionSheet alloc] initWithTitle:@"Share Collage" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:
										@"Save to Camera Roll",
										@"Push to Cloud",
										nil];
				popup.tag = 1;
				[popup showInView:[UIApplication sharedApplication].keyWindow];
			}
        }
    }
}

- (void)handleTapGestures:(UITapGestureRecognizer *)sender
{
	self.imagePaneToUpdate = (UIImageView *)sender.view;
	UIActionSheet *popup = [[UIActionSheet alloc] initWithTitle:@"Choose Photo" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:
							@"Choose from Facebook photos",
							@"Choose from Local photos",
							@"Open the Camera",
							nil];
	popup.tag = 2;
	[popup showInView:[UIApplication sharedApplication].keyWindow];
}

#pragma mark FriendPickerView

- (IBAction)pickFriends:(id)sender {
	if (self.friendPickerController == nil) {
        // Create friend picker, and get data loaded into it.
        self.friendPickerController = [[FBFriendPickerViewController alloc] init];
        self.friendPickerController.title = @"Select Friends";
        self.friendPickerController.delegate = self;
    }
    [self.friendPickerController loadData];
	[self presentViewController:self.friendPickerController
                       animated:YES
                     completion:^(void){
                         [self addSearchBarToFriendPickerView];
                     }
	 ];
}

/*
 * Event: Error during data fetch
 */
- (void)friendPickerViewController:(FBFriendPickerViewController *)friendPicker
                       handleError:(NSError *)error
{
	//NSLog(@"Error during data fetch.");
}

/*
 * Event: Data loaded
 */
- (void)friendPickerViewControllerDataDidChange:(FBFriendPickerViewController *)friendPicker
{
    //NSLog(@"Friend data loaded.");
}

/*
 * Event: Decide if a given user should be displayed
 */
- (BOOL)friendPickerViewController:(FBFriendPickerViewController *)friendPicker
                 shouldIncludeUser:(id <FBGraphUser>)user
{
	if (self.searchText && ![self.searchText isEqualToString:@""]) {
        NSRange result = [user.name
                          rangeOfString:self.searchText
                          options:NSCaseInsensitiveSearch];
        if (result.location != NSNotFound) {
            return YES;
        } else {
            return NO;
        }
    } else {
        return YES;
    }
    return YES;
}

/*
 * Event: Selection changed
 */
- (void)friendPickerViewControllerSelectionDidChange:
(FBFriendPickerViewController *)friendPicker
{
	//NSLog(@"Current friend selections: %@", friendPicker.selection);
}

/*
 * Event: Done button clicked
 */
- (void)facebookViewControllerDoneWasPressed:(id)sender {
	self.pickedFriends = [[NSMutableArray alloc] init];
	
	//If they didn't select any friends, ask if they want just photos of themselves
	if(self.friendPickerController.selection == nil || [self.friendPickerController.selection count] == 0){
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Hold on" message:@"You didn't select any friends. Do you want to just load photos of yourself?" delegate:self cancelButtonTitle:@"Sure" otherButtonTitles:@"Select Friends", nil];
		[alert show];
	} else {
		NSString* friendId;
		for (id<FBGraphUser> user in self.friendPickerController.selection) {
			friendId = user.id;
			[self.pickedFriends addObject:friendId];
		}
		[self renderCollage];
	}
	
	// Dismiss the friend picker
    [[sender presentingViewController] dismissViewControllerAnimated:YES completion:nil];
}

/*
 * Event: Cancel button clicked
 */
- (void)facebookViewControllerCancelWasPressed:(id)sender {
    // Dismiss the friend picker
    [[sender presentingViewController] dismissViewControllerAnimated:YES completion:nil];
}

//Handle the alert view that's presented if they don't select any friends
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if(alertView.tag == messageAlertViewTag){
		return;
	}
	if (buttonIndex == 0){
        // They just want photos of themselves
		[self renderCollage];
    } else if(buttonIndex == 1){
		//Relaunch the friend picker
		[self pickFriends:nil];
	}
}

- (void) handleSearch:(UISearchBar *)searchBar {
    [searchBar resignFirstResponder];
    self.searchText = searchBar.text;
    [self.friendPickerController updateView];
}

- (void)searchBarSearchButtonClicked:(UISearchBar*)searchBar
{
    [self handleSearch:searchBar];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *) searchBar {
    self.searchText = nil;
    [searchBar resignFirstResponder];
}

- (void)addSearchBarToFriendPickerView
{
    if (self.searchBar == nil) {
        CGFloat searchBarHeight = 44.0;
        self.searchBar =
        [[UISearchBar alloc]
         initWithFrame:
         CGRectMake(0,0,
                    self.view.bounds.size.width,
                    searchBarHeight)];
        self.searchBar.autoresizingMask = self.searchBar.autoresizingMask |
		UIViewAutoresizingFlexibleWidth;
        self.searchBar.delegate = self;
        self.searchBar.showsCancelButton = YES;
		
        [self.friendPickerController.canvasView addSubview:self.searchBar];
        CGRect newFrame = self.friendPickerController.view.bounds;
        newFrame.size.height -= searchBarHeight;
        newFrame.origin.y = searchBarHeight;
        self.friendPickerController.tableView.frame = newFrame;
    }
}
@end
