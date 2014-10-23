//
//  WODImagePickerViewController.m
//  TOP
//
//  Created by ianluo on 13-12-12.
//  Copyright (c) 2013年 WOD. All rights reserved.
//

#import "WODImagePickerViewController.h"
#import "WODImagesCollectionViewController.h"
#import "WODCameraViewController.h"
#import "WODButton.h"
#import "WODAnimationManager.h"

@interface WODImagePickerViewController ()

@property (nonatomic, strong)NSDictionary * assetsGourps;
@property (nonatomic, strong)UIViewController * currentDisplayingViewPickController;
@property (nonatomic, assign)NSInteger currentIndex;
@property (nonatomic, strong)ALAssetsLibrary * assetsLibrary;
@property (nonatomic, strong) WODAnimationManager * animatorManager;

//when using camera, stop autorotation and only support portait
@property (nonatomic, assign) BOOL isUsingCamera;

@end

@implementation WODImagePickerViewController

- (id)init
{
    self = [super init];
	
    if (self)
	{
		self.view.backgroundColor = WODConstants.COLOR_VIEW_BACKGROUND;
    }
	
    return self;
}

- (WODAnimationManager *)animatorManager
{
	if (!_animatorManager)
	{
		_animatorManager = [WODAnimationManager new];
	}
	return _animatorManager;
}

- (void)dealloc
{
#ifdef DEBUGMODE
	NSLog(@"(%@,%i):deallocing..",[[NSString stringWithUTF8String:__FILE__]lastPathComponent],__LINE__);
#endif
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	[self setEdgesForExtendedLayout:UIRectEdgeNone];
	// Do any additional setup after loading the view.
	
	_tab = [[WODScrollTab alloc]init];
	self.tab.translatesAutoresizingMaskIntoConstraints = NO;
	[self.view addSubview:self.tab];
	[self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|[tab]|" options:0 metrics:nil views:@{@"tab":self.tab}]];
	[self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[tab(50)]|" options:0 metrics:nil views:@{@"tab":self.tab}]];
	
	NSMutableDictionary * dict = [NSMutableDictionary dictionary];
	
	_assetsLibrary = [[ALAssetsLibrary alloc]init];
	__weak typeof(self) weakSelf = self;
	[self.assetsLibrary enumerateGroupsWithTypes:ALAssetsGroupPhotoStream|ALAssetsGroupAlbum|ALAssetsGroupSavedPhotos usingBlock:^(ALAssetsGroup *group, BOOL *stop)
	 {
		 if (group)
		 {
			 ALAssetsFilter *onlyPhotosFilter = [ALAssetsFilter allPhotos];
			 [group setAssetsFilter:onlyPhotosFilter];
			 if ([group numberOfAssets] > 0)
			 {
				 [dict setObject:group forKey:[group valueForProperty:ALAssetsGroupPropertyName]];
			 }
		 }
		 else
		 {
			 _assetsGourps = [NSDictionary dictionaryWithDictionary:dict];
			 
			 [weakSelf setupTab];
			 
			 [weakSelf loadImageFromGroup:[weakSelf.tab keyForIndex:1]]; //camera is at the 0 index
			 [weakSelf.tab setSelectAtIndex:1 animationComplete:nil];
		 }
	 }
		failureBlock:^(NSError *error)
	 {
		 NSLog(@"error :%@",error);
	 }];
	 
	UIBarButtonItem * done = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(cancel)];
	[self.navigationItem setRightBarButtonItem:done];
}


- (void)setupTab
{
	NSMutableArray * groupButtons = [NSMutableArray array];
		
	UIButton * camera = [[UIButton alloc]init];
	[camera setImage:[[UIImage imageNamed:@"camera"]imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
	[camera setTitle:@"Camera" forState:UIControlStateNormal];
	[camera.titleLabel setFont:[UIFont systemFontOfSize:.1]];
	[camera.titleLabel setAlpha:0.0];
	[camera setTintColor:WODConstants.COLOR_TEXT_TITLE];
	[groupButtons addObject:camera];
	
	NSEnumerator * enumerator = [self.assetsGourps objectEnumerator];
	NSArray * sortedArray = [[enumerator allObjects] sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2)
	{
		if ([(ALAssetsGroup*)obj1 valueForProperty:ALAssetsGroupPropertyType]>[(ALAssetsGroup*)obj2 valueForProperty:ALAssetsGroupPropertyType])
		{
			return NSOrderedAscending;
		}
		else
		{
			return NSOrderedDescending;
		}
	}];
	
	for (ALAssetsGroup * group in sortedArray)
	{
		UIButton * button = [[UIButton alloc]init];
		[button setTitle:[group valueForProperty:ALAssetsGroupPropertyName] forState:UIControlStateNormal];
		
		[groupButtons addObject:button];
	}
	
	__weak typeof(self) weakSelf = self;
	[self.tab initScrollTabWithItems:[NSArray arrayWithArray:groupButtons] selection:^(id key,NSInteger index)
	{
		[weakSelf loadImageFromGroup:key];
	}];
}

- (void)loadImageFromGroup:(id)groupKey
{
	UIViewController * newController;
	
	BOOL showFromRight = NO;
	
	if ([@"Camera" isEqualToString:groupKey])
	{
		newController = [[WODCameraViewController alloc]init];
		[(WODCameraViewController *)newController setImagePickerViewController:self];
		[(WODCameraViewController *)newController showShutter];
		
		[self setTitle:NSLocalizedString(@"VC_TITLE_CAMERA", nil)];
	}
	else
	{
		showFromRight = [self.tab currentIndex] > self.currentIndex;
		
		newController = [[WODImagesCollectionViewController alloc]initWithCollectionViewLayout:[[UICollectionViewFlowLayout alloc]init]];
		[(WODImagesCollectionViewController *)newController setAssetsGroup:[self.assetsGourps objectForKey:groupKey]];
		[(WODImagesCollectionViewController *)newController setImagePickerViewController:self];
		
		[self setTitle:NSLocalizedString(@"VC_TITLE_IMAGEPICKER", nil)];
	}
	
	self.currentIndex = [self.tab currentIndex];
	[self setupSwipeGestureRecognizer:newController];

	__weak typeof(self) weakSelf = self;
	[self showController:newController FromRight:showFromRight completion:^{
		//when removing camera, removed the shutter on the botton of status bar
		if ([weakSelf.currentDisplayingViewPickController isKindOfClass:[WODCameraViewController class]])
		{
			[(WODCameraViewController *)weakSelf.currentDisplayingViewPickController removeShutter];
		}
		[weakSelf.currentDisplayingViewPickController.view removeFromSuperview];
		weakSelf.currentDisplayingViewPickController = nil;
		weakSelf.currentDisplayingViewPickController = newController;
	}];
}

- (void)showController:(UIViewController *)newController FromRight:(BOOL)isFromRight completion:(void(^)(void))block
{
	float startPositionHidden = isFromRight ? self.view.bounds.size.width : - self.view.bounds.size.width;
	float endPositionHidden = isFromRight ? - self.view.bounds.size.width : self.view.bounds.size.width;

	[newController.view setFrame:CGRectMake(startPositionHidden, 0, self.view.bounds.size.width, self.view.bounds.size.height - self.tab.bounds.size.height)];
	[self.view insertSubview:newController.view belowSubview:self.tab];
	
	__weak typeof(self) weakSelf = self;
	[UIView animateWithDuration:0.3 animations:^{
		[newController.view setFrame:CGRectMake(0, 0, weakSelf.view.bounds.size.width, weakSelf.view.bounds.size.height - weakSelf.tab.bounds.size.height)];
		
		if (weakSelf.currentDisplayingViewPickController != nil)
		{
			[weakSelf.currentDisplayingViewPickController.view setFrame:CGRectMake(endPositionHidden, 0, weakSelf.view.bounds.size.width, weakSelf.view.bounds.size.height - weakSelf.tab.bounds.size.height)];
		}
	} completion:^(BOOL finished)
	{
		block();
	}];
}

- (void)setupSwipeGestureRecognizer:(UIViewController *)viewController
{
	UISwipeGestureRecognizer * swipeLeft = [[UISwipeGestureRecognizer alloc]init];
	[swipeLeft setDirection:UISwipeGestureRecognizerDirectionLeft];
	[swipeLeft addTarget:self action:@selector(loadNextGroup)];
	
	UISwipeGestureRecognizer * swipeRight = [[UISwipeGestureRecognizer alloc]init];
	[swipeRight setDirection:UISwipeGestureRecognizerDirectionRight];
	[swipeRight addTarget:self action:@selector(loadLastGroup)];
	
	[viewController.view addGestureRecognizer:swipeLeft];
	[viewController.view addGestureRecognizer:swipeRight];
}

- (void)loadLastGroup
{
	if ([self.tab currentIndex] > 0)
	{
		NSInteger newIndex = [self.tab currentIndex] - 1;
		NSString * lastGroupKey = [self.tab keyForIndex:newIndex];
		[self.tab setSelectAtIndex:newIndex animationComplete:nil];
		[self loadImageFromGroup:lastGroupKey];
	}
}

- (void)loadNextGroup
{
	//make sure the next page won't expand the number of assets, and the first and second index are not assets
	if ([self.tab currentIndex] < self.assetsGourps.count)
	{
		NSInteger newIndex = [self.tab currentIndex] + 1;
		NSString * nextGroupKey = [self.tab keyForIndex:newIndex];
		[self.tab setSelectAtIndex:newIndex animationComplete:nil];
		[self loadImageFromGroup:nextGroupKey];
	}
}


- (void)cancel
{
	if ([self.delegate respondsToSelector:@selector(didCancelImagePicker:)])
	{
		[self.delegate didCancelImagePicker:self];
	}
}

@end

#pragma mark - == Implemention of WODAsset ==

@implementation WODAsset
{
	NSString * filePath;
}

- (id)initWithImage:(UIImage *)image
{
	self = [super init];
	if (self)
	{
		filePath = [self createNewFilePath];
		
		[self setFullScreenImage:[self resizeImage:image]];
		
		[self setOriginalImage:image];
	}
	return self;
}

- (void)setOriginalImage:(UIImage *)originalImage
{
	[self writeImageToFile:originalImage];
}

- (UIImage *)originalImage
{
#ifdef DEBUGMODE
	NSLog(@"get original image: %@",filePath);
#endif
	return [UIImage imageWithContentsOfFile:filePath];
}

- (void)removeOriginalImage
{
#ifdef DEBUGMODE
	NSLog(@"removing original image:%@",filePath);
#endif
	NSFileManager * fm = [NSFileManager defaultManager];
	if ([fm fileExistsAtPath:filePath])
	{
		NSError * error;
		[fm removeItemAtPath:filePath error:&error];
		if (error)
		{
			NSLog(@"******ERROR \n %@",error);
		}
	}
}

- (BOOL)writeImageToFile:(UIImage *)image
{
#ifdef DEBUGMODE
	NSLog(@"writing file to path:%@",filePath);
#endif
	return [UIImageJPEGRepresentation(image, 0) writeToFile:filePath atomically:YES];
}

- (NSString *)createNewFilePath
{
	return [NSString stringWithFormat:@"%@%@.jpg",NSTemporaryDirectory(),[[NSUUID UUID]UUIDString]];
}

- (UIImage *)resizeImage:(UIImage *)originalImage
{
	CGSize screenSize = [UIScreen mainScreen].bounds.size;
	return [WODConstants resizeImage:originalImage fitSize:screenSize];
}

- (void)dealloc
{
	[self removeOriginalImage];
}

@end
