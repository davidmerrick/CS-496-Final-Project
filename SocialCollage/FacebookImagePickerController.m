//
//  FacebookPhotoPicker.m
//  SocialCollage
//
//  Created by David Merrick on 3/15/14.
//  Copyright (c) 2014 David Merrick. All rights reserved.
//
// Based on http://brandontreb.com/iphone-programming-tutorial-creating-an-image-gallery-like-over-part-1
//

#import "FacebookImagePickerController.h"

@implementation FacebookImagePickerController

- (void)viewDidLoad
{
    [super viewDidLoad];
}

-(void)viewDidAppear:(BOOL)animated
{
	[super viewDidAppear:animated];
	[self.collectionView reloadData];
}

#pragma mark - collection view data source

- (NSInteger) collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
	//@todo: imageURLArray isn't initialized when this is called
    return self.imageURLArray.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
	//@todo: why is this never getting called?
	PhotoCell *cell = (PhotoCell *)[collectionView dequeueReusableCellWithReuseIdentifier:@"PhotoCell" forIndexPath:indexPath];
	
	//Retrieve the image
	NSURL *imageURL = [self.imageURLArray objectAtIndex:indexPath.row];
	NSData *imageData = [NSData dataWithContentsOfURL:imageURL];
	
	//cell.backgroundColor = [UIColor redColor];
	cell.image = [UIImage imageWithData:imageData];
    return cell;
}

- (CGFloat) collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section
{
    return 4;
}

- (CGFloat) collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section
{
    return 1;
}

- (IBAction)cancel:(id)sender {
	//Cancels the photo picker and dismisses the view
	[self dismissViewControllerAnimated:YES completion:nil];
}
@end
