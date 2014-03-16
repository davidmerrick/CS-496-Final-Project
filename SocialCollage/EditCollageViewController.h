//
//  PhotoGalleryViewController.h
//  SocialCollage
//
//  Created by David Merrick on 3/3/14.
//  Copyright (c) 2014 David Merrick. All rights reserved.
//

#import <AssetsLibrary/AssetsLibrary.h>
#import <UIKit/UIKit.h>
#import <MobileCoreServices/MobileCoreServices.h>
#import <FacebookSDK/FacebookSDK.h>
#import "FacebookImagePickerController.h"

#define messageAlertViewTag 1

@interface EditCollageViewController : UIViewController <UIImagePickerControllerDelegate, FBFriendPickerDelegate, UIAlertViewDelegate, UIActionSheetDelegate, UISearchBarDelegate>
- (IBAction)pickFriends:(id)sender;
@property (weak, nonatomic) IBOutlet UILabel *FinalCollageLabel;
@property (strong, atomic) ALAssetsLibrary* library; //For the image library
@property (weak, nonatomic) IBOutlet UIImageView *finalCollage;
@property (strong, nonatomic) IBOutletCollection(UIImageView) NSArray *imagePane;
@property (strong, nonatomic) NSMutableArray *pickedFriends;

@property (retain, nonatomic) NSString *username;

//For adding the search bar to the FriendPickerController
@property (retain, nonatomic) FBFriendPickerViewController *friendPickerController;
@property (retain, nonatomic) UISearchBar *searchBar;
@property (retain, nonatomic) NSString *searchText;

//Gesture recognizers
@property (nonatomic,strong) UILongPressGestureRecognizer *lpgr;

//Used when user wants to change the image in a certain UIImageView
@property (weak, nonatomic) UIImageView *imagePaneToUpdate;

@end
