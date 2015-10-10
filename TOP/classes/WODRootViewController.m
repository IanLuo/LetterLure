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
@property (strong, nonatomic) IBOutlet UILabel *label_chooseImage;
@property (strong, nonatomic) IBOutlet UILabel *label_paste;
@property (strong, nonatomic) IBOutlet UILabel *label_manageFont;
@property (strong, nonatomic) IBOutlet UILabel *label_instagram;
@property (strong, nonatomic) IBOutlet UILabel *label_userGuide;
@property (strong, nonatomic) IBOutlet UILabel *label_feedback;

@end

@implementation WODRootViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
  self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
  if (self) {
    self.view.backgroundColor = color_black;
  }
  return self;
}

- (void)viewDidLoad
{
  [super viewDidLoad];
  // Do any additional setup after loading the view.
  self.label_chooseImage.text = iStr(@"IMAGE_PICKER");
  self.label_paste.text = iStr(@"PASTE_IMAGE");
  self.label_manageFont.text = iStr(@"EDIT_HOME_MANAGE_FONT");
  self.label_instagram.text = iStr(@"INSTAGRAM");
  self.label_userGuide.text = iStr(@"USERGUIDE");
  self.label_feedback.text = iStr(@"ABOUT");
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - private

- (IBAction)showBrowseTheWorld
{
    WODBrowseTheworldViewController * brows = [WODBrowseTheworldViewController new];
    UINavigationController * nav = [[UINavigationController alloc]initWithRootViewController:brows];
    [nav setModalPresentationStyle:UIModalPresentationFormSheet];
    
    [self presentViewController:nav animated:YES completion:nil];
}

- (IBAction)showAbout
{
    WODAboutViewController * about = [WODAboutViewController new];
    UINavigationController * nav = [[UINavigationController alloc]initWithRootViewController:about];
    [nav setModalPresentationStyle:UIModalPresentationFormSheet];
    
    [self presentViewController:nav animated:YES completion:nil];
}

/*
show font manager
*/

- (IBAction)showFontManager
{
    WODFontRegisterViewController * fontRegisterViewController = [WODFontRegisterViewController new];
    UINavigationController * nav = [[UINavigationController alloc] initWithRootViewController:fontRegisterViewController];
    
    [nav setModalPresentationStyle:UIModalPresentationFormSheet];
    [self presentViewController:nav animated:YES completion:nil];
}

- (IBAction)showUserGuide
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
- (IBAction)showImagePicker
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
- (IBAction)pasteImage
{
	UIImage * image = [UIPasteboard generalPasteboard].image;
	if(image) {
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
