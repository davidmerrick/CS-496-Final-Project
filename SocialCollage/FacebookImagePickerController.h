//
//  FacebookPhotoPicker.h
//  SocialCollage
//
//  Created by David Merrick on 3/15/14.
//  Copyright (c) 2014 David Merrick. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PhotoCell.h"
#import <FacebookSDK/FacebookSDK.h>

@interface FacebookImagePickerController : UIViewController <UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout>
@property(nonatomic, weak) IBOutlet UICollectionView *collectionView;
@property (strong, nonatomic) NSMutableArray *imageURLArray;
- (IBAction)cancel:(id)sender;
@end
