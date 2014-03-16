//
//  PhotoCell.h
//  SocialCollage
//
//  Created by David Merrick on 3/11/14.
//  Copyright (c) 2014 David Merrick. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PhotoCell : UICollectionViewCell
@property(nonatomic, weak) IBOutlet UIImageView *photoImageView;
@property(nonatomic, strong) UIImage *image;
@end
