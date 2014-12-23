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
#import "WODFontRegisterViewController.h"
#import "WODBrowseTheworldViewController.h"
#import "WODAboutViewController.h"
#import "WODUserGuide.h"

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
        make.top.equalTo(@(60));
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
    
    
    WODButton * fontManageButton = [WODButton new];
    [fontManageButton addTarget:self action:@selector(showFontManager) forControlEvents:UIControlEventTouchUpInside];
    [fontManageButton setStyle:WODButtonStyleRoundCorner];
    [fontManageButton roundCorner:4];
    [fontManageButton setTitle:iStr(@"EDIT_HOME_MANAGE_FONT") forState:UIControlStateNormal];
    [fontManageButton setBackgroundImage:[UIImage squareImageWithColor:[color_gray colorWithAlphaComponent:0.5] andSize:buttonSize] forState:UIControlStateNormal];
    [self.view addSubview:fontManageButton];
    
    WODButton * userGuideButton = [WODButton new];
    [userGuideButton addTarget:self action:@selector(showUserGuide) forControlEvents:UIControlEventTouchUpInside];
    [userGuideButton setStyle:WODButtonStyleRoundCorner];
    [userGuideButton roundCorner:4];
    [userGuideButton setTitle:iStr(@"USERGUIDE") forState:UIControlStateNormal];
    [userGuideButton setBackgroundImage:[UIImage squareImageWithColor:[color_gray colorWithAlphaComponent:0.5] andSize:buttonSize] forState:UIControlStateNormal];
    [self.view addSubview:userGuideButton];
    
    WODButton * aboutButton = [WODButton new];
    [aboutButton addTarget:self action:@selector(showAbout) forControlEvents:UIControlEventTouchUpInside];
    [aboutButton setStyle:WODButtonStyleRoundCorner];
    [aboutButton roundCorner:4];
    [aboutButton setTitle:iStr(@"ABOUT") forState:UIControlStateNormal];
    [aboutButton setBackgroundImage:[UIImage squareImageWithColor:[color_gray colorWithAlphaComponent:0.5] andSize:buttonSize] forState:UIControlStateNormal];
    [self.view addSubview:aboutButton];
    
    WODButton * examplesButton = [WODButton new];
    [examplesButton addTarget:self action:@selector(showBrowseTheWorld) forControlEvents:UIControlEventTouchUpInside];
    [examplesButton setStyle:WODButtonStyleRoundCorner];
    [examplesButton roundCorner:4];
    [examplesButton setTitle:iStr(@"INSTAGRAM") forState:UIControlStateNormal];
    [examplesButton setBackgroundImage:[UIImage squareImageWithColor:[color_gray colorWithAlphaComponent:0.5] andSize:buttonSize] forState:UIControlStateNormal];
    [self.view addSubview:examplesButton];
    
    [aboutButton mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.width.mas_equalTo(@((self.view.viewWidth - 60) / 2));
        make.height.mas_equalTo(@((self.view.viewWidth - 60) / 2));
        make.bottom.equalTo(self.view.mas_bottom).offset(-20);
        make.left.mas_equalTo(@(20));
        
    }];
    
    [examplesButton mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.width.equalTo(aboutButton.mas_width);
        make.height.equalTo(aboutButton.mas_height);
        make.right.mas_equalTo(@(-20));
        make.bottom.equalTo(self.view.mas_bottom).offset(-20);
        
    }];
    
    [fontManageButton mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.bottom.equalTo(aboutButton.mas_top).offset(-20);
        make.height.equalTo(aboutButton.mas_height);
        make.width.equalTo(aboutButton.mas_width);
        make.left.equalTo(aboutButton.mas_left);
        
    }];
    
    [userGuideButton mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.bottom.equalTo(examplesButton.mas_top).offset(-20);
        make.right.equalTo(examplesButton.mas_right);
        make.height.equalTo(examplesButton.mas_height);
        make.width.equalTo(examplesButton.mas_width);
        
    }];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - private

- (void)showBrowseTheWorld
{
    WODBrowseTheworldViewController * brows = [WODBrowseTheworldViewController new];
    UINavigationController * nav = [[UINavigationController alloc]initWithRootViewController:brows];
    [nav setModalPresentationStyle:UIModalPresentationFormSheet];
    
    [self presentViewController:nav animated:YES completion:nil];
}

- (void)showAbout
{
    WODAboutViewController * about = [WODAboutViewController new];
    UINavigationController * nav = [[UINavigationController alloc]initWithRootViewController:about];
    [nav setModalPresentationStyle:UIModalPresentationFormSheet];
    
    [self presentViewController:nav animated:YES completion:nil];
}

/*
show font manager
*/

- (void)showFontManager
{
    WODFontRegisterViewController * fontRegisterViewController = [WODFontRegisterViewController new];
    UINavigationController * nav = [[UINavigationController alloc] initWithRootViewController:fontRegisterViewController];
    
    [nav setModalPresentationStyle:UIModalPresentationFormSheet];
    [self presentViewController:nav animated:YES completion:nil];
}

- (void)showUserGuide
{
    WODUserGuide * userGuide = [WODUserGuide new];
    UINavigationController * nav = [[UINavigationController alloc] initWithRootViewController:userGuide];
    
    [nav setModalPresentationStyle:UIModalPresentationFormSheet];
    [self presentViewController:nav animated:YES completion:nil];
    
    [[NSUserDefaults standardUserDefaults]setObject:[NSNumber numberWithBool:YES] forKey:KEY_IS_RETURN_LAUNCH];
}

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
