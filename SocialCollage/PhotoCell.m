//
//  PhotoCell.m
//  SocialCollage
//
//  Created by David Merrick on 3/11/14.
//  Copyright (c) 2014 David Merrick. All rights reserved.
//

#import "PhotoCell.h"

@implementation PhotoCell
- (void) setImage:(UIImage *)image
{
	self.photoImageView.image = image;
	//Add a border to the imageview
	[self.photoImageView.layer setBorderColor: [[UIColor blackColor] CGColor]];
	[self.photoImageView.layer setBorderWidth: 2.0];
}
@end
