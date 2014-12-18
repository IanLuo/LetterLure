//
//  WODImagesCollectionViewController.m
//  TOP
//
//  Created by ianluo on 13-12-16.
//  Copyright (c) 2013年 WOD. All rights reserved.
//

#import "WODImagesCollectionViewController.h"
#import "WODImageScrollViewController.h"

@interface WODImagesCollectionViewController ()<UICollectionViewDelegateFlowLayout>

@property (nonatomic,strong)NSMutableArray * assets;

@end

@implementation WODImagesCollectionViewController

- (id)init
{
    self = [super init];
    
    if (self)
    {
		
    }
    return self;
}

- (void)dealloc
{
    WODDebug(@"deallocing..");
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
	
	[self.collectionView registerClass:[WODImageCell class] forCellWithReuseIdentifier:@"cellOfImageCollectionsView"];
	self.collectionView.backgroundColor = color_black;
    
    [self.collectionView setContentInset:UIEdgeInsetsMake(HEIGHT_STATUS_AND_NAV_BAR, 0, 0, 0)];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setAssetsGroup:(ALAssetsGroup *)assetsGroup
{
	_assetsGroup = assetsGroup;
	
	if (!self.assets) {
        _assets = [[NSMutableArray alloc] init];
    } else {
        [self.assets removeAllObjects];
    }
	
	ALAssetsFilter * onlyPhotosFilter = [ALAssetsFilter allPhotos];
	[self.assetsGroup setAssetsFilter:onlyPhotosFilter];
	[self.assetsGroup enumerateAssetsUsingBlock:^(ALAsset *result, NSUInteger index, BOOL *stop)
	 {
		 if (result)
		 {
			 [self.assets insertObject:result atIndex:0];
		 }
		 
		 if (index == [self.assetsGroup numberOfAssets] - 1)
		 {
			 [self.collectionView reloadData];
		 }
	 }];
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
	return self.assets.count;
}

#define cellImageViewTag 1
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
	static NSString * cellID = @"cellOfImageCollectionsView";
	
	WODImageCell * cell = [collectionView dequeueReusableCellWithReuseIdentifier:cellID forIndexPath:indexPath];
	
	ALAsset * asset = [self.assets objectAtIndex:indexPath.row];
	UIImage * image = [UIImage imageWithCGImage:asset.thumbnail];
	
	[cell.imageView setImage:image];
			
	return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
	return CGSizeMake(77, 77);
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
	return UIEdgeInsetsMake(3, 3, 3, 3);
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section
{
	return 2;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section
{
	return 2;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
	WODImageScrollViewController * chooseImageScrollView = [WODImageScrollViewController new];
	[chooseImageScrollView setImagePickerViewController:self.imagePickerViewController];
	[chooseImageScrollView setCurrentPage:indexPath.row];
	[chooseImageScrollView setAssetsGroup:self.assetsGroup];

	[self.imagePickerViewController.navigationController pushViewController:chooseImageScrollView animated:YES];
		
	self.currentIndexpath = indexPath;
}

@end

@implementation WODImageCell

- (id)initWithFrame:(CGRect)frame
{
	self = [super initWithFrame:CGRectMake(0, 0, 77, 77)];
	_imageView = [[UIImageView alloc]initWithFrame:self.bounds];
	[self addSubview:self.imageView];
	return self;
}

@end
