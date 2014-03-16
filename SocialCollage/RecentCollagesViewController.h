//
//  FriendLookupViewController.h
//  SocialCollage
//
//  Created by David Merrick on 3/3/14.
//  Copyright (c) 2014 David Merrick. All rights reserved.
//
#import <UIKit/UIKit.h>

@interface RecentCollagesViewController : UIViewController <UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout>
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;

//Holds the URLs of all recently posted images
@property (strong, nonatomic) NSMutableArray *imagesArray;
@property (retain, nonatomic) NSString *baseURL;
@end
