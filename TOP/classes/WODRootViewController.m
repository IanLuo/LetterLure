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
#import "UIImage+Generate.h"
#import "UIView+Appearance.h"
#import "MBProgressHUD.h"

@interface WODRootViewController ()<WODImagePickerDelegate>

@end

@implementation WODRootViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
	{
		self.view.backgroundColor = color_black;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
	
    [self loadViews];
}

- (void)loadViews
{
    [self loadButtons];
}

- (void)loadButtons
{
    CGSize buttonSize = CGSizeMake(150, 80);
    WODButton * imagePickerBtn = [WODButton new];
    [imagePickerBtn addTarget:self action:@selector(showImagePicker) forControlEvents:UIControlEventTouchUpInside];
    [imagePickerBtn setStyle:WODButtonStyleRoundCorner];
    [imagePickerBtn roundCorner:4];
    [imagePickerBtn setBackgroundImage:[UIImage squareImageWithColor:[color_gray colorWithAlphaComponent:0.5] andSize:buttonSize] forState:UIControlStateNormal];
    [imagePickerBtn setTitle:iStr(@"IMAGE_PICKER") forState:UIControlStateNormal];
    [imagePickerBtn setTitleColor:color_white forState:UIControlStateNormal];

    [self.view addSubview:imagePickerBtn];
    
    __weak typeof (self)wself = self;
    [imagePickerBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.size.mas_greaterThanOrEqualTo(buttonSize);
        make.top.greaterThanOrEqualTo(@(100));
        make.centerX.equalTo(wself.view);
        
    }];
    
    WODButton * paseteImageBtn = [WODButton new];
    [paseteImageBtn addTarget:self action:@selector(pasteImage) forControlEvents:UIControlEventTouchUpInside];
    [paseteImageBtn setStyle:WODButtonStyleRoundCorner];
    [paseteImageBtn roundCorner:4];
    [paseteImageBtn setTitle:iStr(@"PASTE_IMAGE") forState:UIControlStateNormal];
    [paseteImageBtn setBackgroundImage:[UIImage squareImageWithColor:[color_gray colorWithAlphaComponent:0.5] andSize:buttonSize] forState:UIControlStateNormal];
    [self.view addSubview:paseteImageBtn];
    
    [paseteImageBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.size.equalTo(imagePickerBtn);
        make.top.equalTo(imagePickerBtn.mas_bottom).offset(20);
        make.centerX.equalTo(wself.view);
        
    }];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - private

/*
 Image Pickers
*/
- (void)showImagePicker
{
	WODImagePickerViewController * imagePicker = [[WODImagePickerViewController alloc]init];
	imagePicker.delegate = self;
	
	UINavigationController * nav = [[UINavigationController alloc]initWithRootViewController:imagePicker];
	[nav setModalPresentationStyle:UIModalPresentationFormSheet];
	
	[self presentViewController:nav animated:YES completion:nil];
}

/*
 *Handle image from paste board
 */
- (void)pasteImage
{
	UIImage * image = [UIPasteboard generalPasteboard].image;
	if(image)
    {
        [self useOutsideImage:image];
    }
}

/*
 
 */
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

/*
 
 */
- (void)goToEditViewControllerWithFullScreenImage:(UIImage *)fullScreenImage cacheKey:(NSString *)originalImageCacheKey size:(CGSize)originalImageSize
{
	EditHomeViewController * editViewController = [EditHomeViewController new];
	
	[editViewController setOriginalImageCachKey:originalImageCacheKey];
	[editViewController setOriginalImageSize:originalImageSize];
	[editViewController setBackgroundImage:fullScreenImage];
	
    [self.navigationController setNavigationBarHidden:NO animated:YES];
	[self.navigationController pushViewController:editViewController animated:YES];
}

#pragma mark - image picker handler
- (void)didCancelImagePicker:(WODImagePickerViewController *)picker
{
	[self dismissViewControllerAnimated:YES completion:nil];
}

- (void)didFinishPickingImage:(UIImage *)fullScreenImage originalImagePath:(NSString *)cacheKey size:(CGSize)size picker:(WODImagePickerViewController *)picker
{
    ws(wself);
    
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
	[self dismissViewControllerAnimated:YES completion:^{
        
		[wself goToEditViewControllerWithFullScreenImage:fullScreenImage cacheKey:cacheKey size:size];
        
        [MBProgressHUD hideHUDForView:wself.view animated:YES];
        
	}];
}

@end
