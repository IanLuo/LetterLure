//
//  WODImageScrollViewController.m
//  TOP
//
//  Created by ianluo on 13-12-12.
//  Copyright (c) 2013年 WOD. All rights reserved.
//

#import "WODImageScrollViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "WODButton.h"

@interface WODImageScrollViewController ()<UIScrollViewDelegate,UICollectionViewDataSource,UICollectionViewDelegate>

@property (nonatomic, strong)UICollectionView * collectionView;
@property (nonatomic,strong)NSMutableArray * assets;
@property (nonatomic,strong)UIImageView * leftScrollIndecator;
@property (nonatomic,strong)UIImageView * rightScrollIndecator;
@property (nonatomic, assign)CGSize pageSize;
@end

@implementation WODImageScrollViewController

- (UICollectionView *)collectionView
{
	if (!_collectionView)
	{
		UICollectionViewFlowLayout * flowlayout = [UICollectionViewFlowLayout new];
		[flowlayout setScrollDirection:UICollectionViewScrollDirectionHorizontal];
		
		_collectionView = [[UICollectionView alloc]initWithFrame:self.view.bounds collectionViewLayout:flowlayout];
		[_collectionView setPagingEnabled:YES];
		_collectionView.delegate = self;
		_collectionView.dataSource = self;
		_collectionView.backgroundColor = WODConstants.COLOR_VIEW_BACKGROUND;
		_collectionView.translatesAutoresizingMaskIntoConstraints = NO;
		_collectionView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
		[_collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"imageCell"];
		
		_leftScrollIndecator = [[UIImageView alloc]initWithImage:[[UIImage imageNamed:@"arrow_left"]imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate]];
		_leftScrollIndecator.autoresizingMask = UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleBottomMargin;
		_leftScrollIndecator.tintColor = WODConstants.COLOR_CONTROLLER;
		_leftScrollIndecator.center = CGPointMake(5,self.collectionView.bounds.size.height/2);
		
		_rightScrollIndecator = [[UIImageView alloc]initWithImage:[[UIImage imageNamed:@"arrow_right"]imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate]];
		_rightScrollIndecator.autoresizingMask = UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleBottomMargin|UIViewAutoresizingFlexibleLeftMargin;
		_rightScrollIndecator.tintColor = WODConstants.COLOR_CONTROLLER;
		_rightScrollIndecator.center = CGPointMake(self.collectionView.bounds.size.width - 5,self.collectionView.bounds.size.height/2);
		
		self.leftScrollIndecator.alpha = 0.0;
		self.rightScrollIndecator.alpha = 0.0;
		
		[self.view addSubview:self.leftScrollIndecator];
		[self.view addSubview:self.rightScrollIndecator];
	}
	return _collectionView;
}

- (id)init
{
    self = [super init];
    if (self)
	{
		self.view.backgroundColor = WODConstants.COLOR_VIEW_BACKGROUND;
    }
    return self;
}

- (void)dealloc
{
#ifdef DEBUGMODE
	NSLog(@"(%@,%i):deallocing...",[[NSString stringWithUTF8String:__FILE__]lastPathComponent],__LINE__);
#endif
}

- (void)addApplyButton
{
	UIView * bar = [[UIView alloc]initWithFrame:CGRectMake(0, self.view.bounds.size.height - 50, self.view.bounds.size.width, 50)];
	[bar setAutoresizingMask:UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleTopMargin];
	[bar setBackgroundColor:WODConstants.COLOR_TAB_BACKGROUND];
	[self.view addSubview:bar];
	
	WODButton * apply = [[WODButton alloc]initWithFrame: CGRectInset(bar.bounds, 100, 2)];
	[apply setImage:[[UIImage imageNamed:@"check_mark.png"]imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
	[apply setTintColor:WODConstants.COLOR_TEXT_TITLE];
	[apply setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
	[apply addTarget:self action:@selector(applyImage) forControlEvents:UIControlEventTouchUpInside];
	[bar addSubview:apply];
	
	[UIView animateWithDuration:0.5 animations:^{
		bar.frame = CGRectMake(0, self.view.bounds.size.height - 50, self.view.bounds.size.width, 50);
	}];
}

- (void)viewDidLoad
{
	[self.view addSubview:self.collectionView];
	[self setEdgesForExtendedLayout:UIRectEdgeNone];
	[self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|-[images]-|" options:0 metrics:nil views:@{@"images":self.collectionView}]];
	[self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-[images]-|" options:0 metrics:nil views:@{@"images":self.collectionView}]];
	
	self.collectionView.alpha = 0.0;
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
	NSMutableArray * visibaleIndexPaths = [NSMutableArray array];
	for(UICollectionViewCell * cell in [self.collectionView visibleCells])
	{
		NSIndexPath * indexPath = [self.collectionView indexPathForCell:cell];
		[visibaleIndexPaths addObject:indexPath];
	}
	
	[self.collectionView reloadItemsAtIndexPaths:[NSArray arrayWithArray:visibaleIndexPaths]];
	[self.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForRow:self.currentPage inSection:0] atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally animated:NO];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidAppear:(BOOL)animated
{
	[super viewDidAppear:animated];
	
	[self.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForRow:self.currentPage inSection:0] atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally animated:NO];
	
	[UIView animateWithDuration:0.3 animations:^{
		self.collectionView.alpha = 1.0;
	}];
	
	[self addApplyButton];
	[self checkScrollIndicatorVisiability];
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
	[_assetsGroup setAssetsFilter:onlyPhotosFilter];
	
	__weak typeof(self) wself = self;
	[_assetsGroup enumerateAssetsUsingBlock:^(ALAsset *result, NSUInteger index, BOOL *stop)
	 {
		 if (result)
		 {
			 [wself.assets insertObject:result atIndex:0];
		 }
		 
		 if (index == assetsGroup.numberOfAssets - 1)
		 {
			 [wself.collectionView reloadData];
		 }
	 }];
}

- (void)setImages:(NSArray *)images
{
	self.imageSource = Custom;
	_assets = [NSMutableArray arrayWithArray:images];
}

- (void)closeMe
{
	[self.navigationController popToRootViewControllerAnimated:YES];
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
	return self.assets.count;
}

- (void)applyImage
{
	
	if ([self.collectionView visibleCells] > 0)
	{
		NSIndexPath * indexPath = [self.collectionView indexPathForCell:[self.collectionView visibleCells][0]];
		
		if([self.imagePickerViewController.delegate respondsToSelector:@selector(didFinishPickingImage:originalImagePath:size:picker:)])
		{
			switch (self.imageSource)
			{
				case System:
				{
					{
						ALAsset * asset = (ALAsset *)self.assets[indexPath.row];
						UIImage * fullScreenImage = [UIImage imageWithCGImage:[[asset defaultRepresentation] fullScreenImage]];
						
						ALAssetRepresentation *defaultRep = [asset defaultRepresentation];
						
						UIImage * fullResImage1 = [UIImage imageWithCGImage:[defaultRep fullResolutionImage] scale:[defaultRep scale] orientation:(int)defaultRep.orientation];
						CGSize fullResImageSize = [WODConstants calculateNewSizeForImage:fullResImage1 maxSide:2048];
						NSString * keyForFullSizeImageInCache = (NSString *)[NSUUID UUID];
						
						dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
							UIImage * fullResImage = [WODConstants resizeImage:fullResImage1 maxSide:2048];
							[WODConstants addOrUpdateImageCache:fullResImage forKey:keyForFullSizeImageInCache];
						});
						
						[self.imagePickerViewController.delegate didFinishPickingImage:fullScreenImage originalImagePath:keyForFullSizeImageInCache size:fullResImageSize picker:self.imagePickerViewController];
						break;
					}
				}
				case Custom:
				{
					WODAsset * asset = (WODAsset *)self.assets[indexPath.row];
					if (asset)
					{
						NSString * keyForFullSizeImageInCache = (NSString *)[NSUUID UUID];
						asset.size = [WODConstants calculateNewSizeForImage:asset.originalImage maxSide:2048];
						
						dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
							UIImage * originalImage = [WODConstants resizeImage:asset.originalImage maxSide:2048];
							[WODConstants addOrUpdateImageCache:originalImage forKey:keyForFullSizeImageInCache];
						});
						
						[self.imagePickerViewController.delegate didFinishPickingImage:asset.fullScreenImage originalImagePath:keyForFullSizeImageInCache size:asset.size picker:self.imagePickerViewController];
					}
					break;
				}
			}
		}
	}
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
	UICollectionViewCell * cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"imageCell" forIndexPath:indexPath];
	
	for (UIView * view in cell.contentView.subviews)
	{
		[view removeFromSuperview];
	}
	
	CGRect imageFrame = (CGRect){CGPointZero,(CGSize){self.pageSize.width, self.pageSize.height - 50}};
	
	switch (self.imageSource)
	{
		case System:
		{
			UIImage * fullScreenImage = [UIImage imageWithCGImage:[[(ALAsset *)self.assets[indexPath.row] defaultRepresentation]fullScreenImage]];
			UIImageView * imageView = [[UIImageView alloc]initWithImage:fullScreenImage];
			[imageView setContentMode:UIViewContentModeScaleAspectFit];
			imageView.frame = imageFrame;
			
			[cell.contentView addSubview:imageView];
			break;
		}
		case Custom:
		{
			UIImage * fullScreenImage = [(WODAsset *)self.assets[indexPath.row] fullScreenImage];
			UIImageView * imageView = [[UIImageView alloc]initWithImage:fullScreenImage];
			[imageView setContentMode:UIViewContentModeScaleAspectFit];
			imageView.frame = imageFrame;
			
			[cell.contentView addSubview:imageView];
			break;
		}
	}
	
	return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
	self.pageSize = CGSizeMake(collectionView.bounds.size.width - 10, collectionView.bounds.size.height - 10);
	return self.pageSize;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
	self.currentPage = floor(self.collectionView.contentOffset.x/self.pageSize.width);
	[self checkScrollIndicatorVisiability];
}

- (void)checkScrollIndicatorVisiability
{
	[UIView animateWithDuration:0.3 animations:^{
		self.leftScrollIndecator.alpha = self.currentPage == 0 ? 0.0 : 1.0;
		self.rightScrollIndecator.alpha = self.currentPage == self.assets.count - 1 ? 0.0 : 1.0;
	}];
}

@end
