//
//  WODRootViewController.m
//  TOP
//
//  Created by ianluo on 14-8-25.
//  Copyright (c) 2014年 WOD. All rights reserved.
//

#import "WODRootViewController.h"
#import "WODButton.h"
#import "EditHomeViewController.h"
#import "WODImagePickerViewController.h"

@interface WODRootViewController ()<WODImagePickerDelegate>

@end

@implementation WODRootViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
	{
		self.view.backgroundColor = WODConstants.COLOR_VIEW_BACKGROUND;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
	
	CGSize buttonSize = CGSizeMake(100, 80);
	WODButton * imagePicker = [WODButton new];
	[imagePicker addTarget:self action:@selector(showImagePicker) forControlEvents:UIControlEventTouchUpInside];
	[imagePicker setStyle:WODButtonStyleRoundCorner];
	[imagePicker setFrame:CGRectMake(self.view.bounds.size.width/2 - buttonSize.width/2, self.view.bounds.size.height * 0.6, buttonSize.width, buttonSize.height)];
	[imagePicker setImage:[[UIImage imageNamed:@"images"]imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
	[self.view addSubview:imagePicker];
	
	WODButton * paseteImage = [WODButton new];
	[paseteImage addTarget:self action:@selector(pasteImage) forControlEvents:UIControlEventTouchUpInside];
	[paseteImage setStyle:WODButtonStyleRoundCorner];
	[paseteImage setFrame:CGRectMake(self.view.bounds.size.width/2 - buttonSize.width/2, self.view.bounds.size.height * 0.4, buttonSize.width, buttonSize.height)];
	[paseteImage setImage:[[UIImage imageNamed:@"images"]imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
	[self.view addSubview:paseteImage];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)showImagePicker
{
	WODImagePickerViewController * imagePicker = [[WODImagePickerViewController alloc]init];
	imagePicker.delegate = self;
	
	UINavigationController * nav = [[UINavigationController alloc]initWithRootViewController:imagePicker];
	[nav setModalPresentationStyle:UIModalPresentationFormSheet];
	
	[self presentViewController:nav animated:YES completion:nil];
}

- (void)pasteImage
{
	UIImage * image = [UIPasteboard generalPasteboard].image;
	if(image)
		[self useOutsideImage:image];
}


- (void)goToEditViewControllerWithFullScreenImage:(UIImage *)fullScreenImage cacheKey:(NSString *)originalImageCacheKey size:(CGSize)originalImageSize
{
	EditHomeViewController * editViewController = [EditHomeViewController new];
	
	[editViewController setOriginalImageCachKey:originalImageCacheKey];
	[editViewController setOriginalImageSize:originalImageSize];
	[editViewController setBackgroundImage:fullScreenImage];
	
	[self.navigationController pushViewController:editViewController animated:YES];
}

// import image
// pasete image
// guide
// support
// rate
// manage font

#pragma mark - image handler

- (void)didCancelImagePicker:(WODImagePickerViewController *)picker
{
	[self dismissViewControllerAnimated:YES completion:nil];
}

- (void)didFinishPickingImage:(UIImage *)fullScreenImage originalImagePath:(NSString *)cacheKey size:(CGSize)size picker:(WODImagePickerViewController *)picker
{
	[self dismissViewControllerAnimated:YES completion:^{
		[self goToEditViewControllerWithFullScreenImage:fullScreenImage cacheKey:cacheKey size:size];
	}];
}

- (void)useOutsideImage:(UIImage *)image
{
	image = [WODConstants resizeImage:image maxSide:2048];
	NSString * cacheKey = (NSString *)[NSUUID UUID];
	[WODConstants addOrUpdateImageCache:image forKey:cacheKey];
	
//	[self setOriginalImageCachKey:cacheKey];
//	[self setOriginalImageSize:CGSizeApplyAffineTransform(image.size, CGAffineTransformMakeScale(image.scale, image.scale))];
//	[self setBackgroundImage:[WODConstants resizeImageToFullScreenSize:image]];
	
	[self goToEditViewControllerWithFullScreenImage:[WODConstants resizeImageToFullScreenSize:image] cacheKey:cacheKey size:CGSizeApplyAffineTransform(image.size, CGAffineTransformMakeScale(image.scale, image.scale))];
}

@end
