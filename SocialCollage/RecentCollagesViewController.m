//
//  FriendLookupViewController.m
//  SocialCollage
//
//  Created by David Merrick on 3/3/14.
//  Copyright (c) 2014 David Merrick. All rights reserved.
//
// References:
// http://www.appcoda.com/fetch-parse-json-ios-programming-tutorial/
// http://stackoverflow.com/questions/18585714/how-to-parse-this-json-and-show-in-uicollectionview
// http://brandontreb.com/iphone-programming-tutorial-creating-an-image-gallery-like-over-part-2


#import "RecentCollagesViewController.h"
#import "PhotoCell.h"

@implementation RecentCollagesViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	//Set the base URL
	self.baseURL = @"http://2-dot-ermagherdkittygallery.appspot.com";
}

-(void) viewDidAppear:(BOOL)animated
{
	[super viewDidAppear:animated];
	//Reload recent collages every time the view appears
	//Get the JSON data and populate the collectionView with it
	NSString *urlAsString = [NSString stringWithFormat:@"%@/viewapi_ios.jsp", self.baseURL];
    NSURL *url = [[NSURL alloc] initWithString:urlAsString];
    
	NSData *responseData = [NSURLConnection sendSynchronousRequest:[[NSURLRequest alloc] initWithURL:url] returningResponse:nil error:nil];
	NSDictionary *parsedObject = [NSJSONSerialization JSONObjectWithData:responseData options:0 error:nil];
	self.imagesArray = [parsedObject valueForKey:@"URL"];
	[self.collectionView reloadData];
}

#pragma mark - collection view data source

- (NSInteger) collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.imagesArray.count;
}


- (UICollectionViewCell *) collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    PhotoCell *cell = (PhotoCell *)[collectionView dequeueReusableCellWithReuseIdentifier:@"PhotoCell" forIndexPath:indexPath];

    //Get the base url for making requests
	NSURL *imageURL = [NSURL URLWithString:[NSString stringWithFormat:@"%@/%@", self.baseURL, [self.imagesArray objectAtIndex:indexPath.row]]];
	
    //download the image and display it into your cell here
	NSData *imageData = [NSData dataWithContentsOfURL:imageURL];
	cell.backgroundColor = [UIColor redColor];
	cell.image = [UIImage imageWithData:imageData];
	
    return cell;
	
}

- (CGFloat) collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section
{
    return 1;
}

- (CGFloat) collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section
{
    return 1;
}

@end
