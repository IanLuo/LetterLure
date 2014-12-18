//
//  WODCameraViewController.m
//  TOP
//
//  Created by ianluo on 13-12-16.
//  Copyright (c) 2013年 WOD. All rights reserved.
//

#import "WODCameraViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "WODImageScrollViewController.h"
#import "MBProgressHUD.h"

@interface WODCameraViewController ()<UINavigationControllerDelegate,UIImagePickerControllerDelegate>

@property (nonatomic, strong)UIImagePickerController * imagePicker;

@end

@implementation WODCameraViewController

- (UIImagePickerController *)imagePicker
{
	if (!_imagePicker)
	{
		_imagePicker = [[UIImagePickerController alloc]init];
		
		[self.imagePicker setDelegate:self];
		[self.imagePicker setSourceType:UIImagePickerControllerSourceTypeCamera];
		[self.imagePicker setShowsCameraControls:NO];

	}
	return _imagePicker;
}

- (id)init
{
    self = [super init];
    if (self) {
        // Custom initialization

        WODDebug(@"initing..");
        
		if (isPad())
		{
			[[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(didRotateInterface:) name:UIApplicationWillChangeStatusBarOrientationNotification object:nil];
		}
    }
    return self;
}

- (void)dealloc
{
    WODDebug(@"deallocing..");

	if (isPad())
	{
		[[NSNotificationCenter defaultCenter]removeObserver:self];
	}
}

- (void)didReceiveMemoryWarning
{
	[super didReceiveMemoryWarning];
	// Dispose of any resources that can be recreated.
}

- (void)viewDidLoad
{
//	self.edgesForExtendedLayout = UIRectEdgeNone;
}

#define shutterViewTag 999

- (void)viewDidAppear:(BOOL)animated
{
	[self loadCamera];
}

- (void)didRotateInterface:(NSNotification *)notification
{
	UIInterfaceOrientation orientation = [[notification.userInfo objectForKey:UIApplicationStatusBarOrientationUserInfoKey]intValue];
	
	float rotation = 0;
	switch (orientation)
	{
		case UIInterfaceOrientationLandscapeLeft:
			rotation = M_PI / 2;
			break;
		case UIInterfaceOrientationLandscapeRight:
			rotation = -M_PI /2;
			break;
		default:
			break;
	}
	self.imagePicker.cameraViewTransform = CGAffineTransformMakeRotation(rotation);
}

- (void)takePicture
{
	if (self.imagePicker)
	{
		[self.imagePicker takePicture];
	}
}

- (void)showShutter
{
	// change the camera button to shutter
	UIButton * camera = self.imagePickerViewController.tab.items[0];
	
	UIButton * shutterButton = [self createShutterButton];
	[shutterButton addTarget:self action:@selector(takePicture) forControlEvents:UIControlEventTouchUpInside];
	shutterButton.center = CGPointMake(camera.bounds.size.width/2,camera.bounds.size.height/2);
	
	[camera addSubview:shutterButton];
	
	shutterButton.transform = CGAffineTransformMakeScale(0.0, 0.0);
	
	[UIView animateWithDuration:0.2 animations:^{
		[camera setImage:nil forState:UIControlStateNormal];
		shutterButton.transform = CGAffineTransformIdentity;
	}];
}

- (UIButton *)createShutterButton
{
	UIButton * shutterBorder = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 38, 38)];
	shutterBorder.tag = shutterViewTag;
	shutterBorder.layer.borderColor = [UIColor whiteColor].CGColor;
	shutterBorder.layer.borderWidth = 2;
	shutterBorder.backgroundColor = [UIColor clearColor];
	shutterBorder.layer.cornerRadius = shutterBorder.bounds.size.height/2;
	
	UIView * shutterInside = [[UIView alloc]initWithFrame:CGRectMake(3, 3, 32, 32)];
	shutterInside.layer.cornerRadius = shutterInside.bounds.size.height/2;
	shutterInside.userInteractionEnabled = NO;
	shutterInside.backgroundColor = [UIColor whiteColor];
	
	[shutterBorder addSubview:shutterInside];
	
	return shutterBorder;
}

- (void)removeShutter
{
	//change the sutter button back to camera button
	UIButton * camera = self.imagePickerViewController.tab.items[0];
	
	__block UIView * shutterButton = [camera viewWithTag:shutterViewTag];
	[UIView animateWithDuration:0.2 animations:^{
		shutterButton.transform = CGAffineTransformMakeScale(0.0, 0.0);
		[camera setImage:[[UIImage imageNamed:@"camera"]imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
	} completion:^(BOOL finished) {
		[shutterButton removeFromSuperview];
		shutterButton = nil;
	}];
}

- (void)loadCamera
{
	if (![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
	{
		return;
	}
	
	[self.imagePicker.view setFrame:self.view.bounds];
	[self.view addSubview:self.imagePicker.view];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
	[MBProgressHUD showHUDAddedTo:self.view animated:YES];

	dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
		WODAsset * asset = [[WODAsset alloc]initWithImage:[info objectForKey:UIImagePickerControllerOriginalImage]];
		
		WODImageScrollViewController * chooseImageScrollView = [WODImageScrollViewController new];
		[chooseImageScrollView setImagePickerViewController:self.imagePickerViewController];
		[chooseImageScrollView setCurrentPage:0];
		[chooseImageScrollView setImages:@[asset]];
		
        ws(wself);
		dispatch_sync(dispatch_get_main_queue(), ^{
            
			[wself.imagePickerViewController.navigationController pushViewController:chooseImageScrollView animated:YES];
            
			[MBProgressHUD hideHUDForView:wself.view animated:YES];
            
		});
	});
}
@end
