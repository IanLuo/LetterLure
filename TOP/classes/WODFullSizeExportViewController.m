//
//  WODFullSizeExportView.m
//  TOP
//
//  Created by ianluo on 14-8-21.
//  Copyright (c) 2014年 WOD. All rights reserved.
//

#import "WODFullSizeExportViewController.h"
#import "WODTextLayerManager.h"
#import "WODOpenGLESAppEngine.h"
#import "WODExportManager.h"
#import "Flurry.h"
#import "SVProgressHUD.h"
#import "ExportToInstagramPreviewController.h"
#import "SocialControl.h"

@interface WODFullSizeExportViewController()<WODExportToOtherAppviewControllerDelegate>

@property (nonatomic, strong) WODOpenGLESAppEngine* appEngine;
@property (nonatomic, assign) CGFloat scale;
@property (nonatomic, strong) UIImage * outputImage; //image to share
@property (nonatomic, strong) UIActivityIndicatorView * activityIndicator;
@property (nonatomic, strong) UIImageView * imageView; //preview image
@property (nonatomic, strong) SocialControl * socailControl;

@end

@implementation WODFullSizeExportViewController
{
	EAGLContext * m_context;
}

- (id)init
{
    self = [super init];
    if (self)
	{
		[self.view setTintColor:[UIColor whiteColor]];
		
		_appEngine = [WODOpenGLESAppEngine new];
		_activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
		self.activityIndicator.center = CGPointMake(self.view.bounds.size.width/2, 100);
		self.view.backgroundColor = [WODConstants COLOR_VIEW_BACKGROUND];

		_imageView = [UIImageView new];
		[self.imageView setContentMode:UIViewContentModeScaleAspectFit];
		self.imageView.center = self.view.center;
		self.imageView.bounds = CGRectMake(0, 0, self.view.bounds.size.width/2, self.view.bounds.size.height/2);
		[self.view addSubview:self.imageView];
		
		[self.imageView setAlpha:0.0];
		
		_socailControl = [SocialControl new];
    }
	
    return self;
}

- (void)viewDidAppear:(BOOL)animated
{
	[super viewDidAppear:animated];
	
	if (!self.outputImage)
	{
		[self.view addSubview:self.activityIndicator];
		[self.activityIndicator startAnimating];
		
		[self shareImage];
		
		self.imageView.image = self.fullScreenImage;
		
		[UIView animateWithDuration:0.3 animations:^{
			self.imageView.alpha = 1.0;
		}];
	}
}

- (void)initRenderHirachy
{
	EAGLRenderingAPI api = kEAGLRenderingAPIOpenGLES2;
	m_context = [[EAGLContext alloc] initWithAPI:api];
	
	if (!m_context || ![EAGLContext setCurrentContext:m_context])
	{
		NSLog(@"can't init context for EAGLLayer");
		return;
	}
	
	CGSize size = self.editHomeViewController.originalImageSize;
	
	self.scale = size.width / self.editHomeViewController.openGLStageView.displaySize.width;
	
	self.appEngine->contentScale = 1;
	[self.appEngine createRenderBuffersForOffscreen:size];
	[self.appEngine createFrameBuffers:size];
}

- (void)shareImage
{
	if (!self.outputImage) {
		dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
			[self outputImageComplete:^(UIImage *image)
			 {
				 if (image)
				 {
					 //stop animation and show share buttons
					 dispatch_async(dispatch_get_main_queue(), ^{
						 [self.activityIndicator removeFromSuperview];
						 [self showImageShareActions];
					 });
					 
					 [self setOutputImage:image];
					 [self.socailControl setImage:self.outputImage];
				 }
			 }];
		});
	}
	else
	{
		[self showImageShareActions];
	}
}

- (BOOL)shouldAutorotate
{
	return NO;
}

- (void)showImageShareActions
{
	UIView * buttonsView = [UIView new];
	[self.view addSubview:buttonsView];
	
	CGPoint buttonSlots[8];
	
	BOOL isIpad = UI_USER_INTERFACE_IDIOM()==UIUserInterfaceIdiomPad;
	
	float height = isIpad ? 200 : 100;
	float width = self.view.bounds.size.width;
	float vPart = width / 5;
	float hPart = height / 2;
	float iconSideLength = isIpad ? 60 : 30;
	int numPerRow = 4;
	float x, y;
	
	buttonsView.frame = CGRectMake(0, self.view.bounds.size.height - height - (isIpad ? 20 : 10), width, height);
	
	for (int i = 0; i < 8; i ++)
	{
		x = vPart * (i % numPerRow + 1);
		y = hPart/2 + hPart * (i / numPerRow);
		buttonSlots[i] = CGPointMake(x, y);
	}
	
	UIButton * saveToRoll = [UIButton new];
	[saveToRoll setImage:[[UIImage imageNamed:@"save.png"]imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
	[saveToRoll addTarget:self action:@selector(saveToRoll) forControlEvents:UIControlEventTouchUpInside];
	[saveToRoll setCenter:buttonSlots[0]];
	[saveToRoll setBounds:CGRectMake(0, 0, iconSideLength, iconSideLength)];
	[buttonsView addSubview:saveToRoll];
	
	UIButton * shareWithEmail = [UIButton new];
	[shareWithEmail setImage:[[UIImage imageNamed:@"envelop.png"]imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
	[shareWithEmail addTarget:self action:@selector(shareWithEmail) forControlEvents:UIControlEventTouchUpInside];
	[shareWithEmail setCenter:buttonSlots[1]];
	[shareWithEmail setBounds:CGRectMake(0, 0, iconSideLength, iconSideLength)];
	[buttonsView addSubview:shareWithEmail];
	
	UIButton * shareWithFacebook = [UIButton new];
	[shareWithFacebook setImage:[[UIImage imageNamed:@"facebook.png"]imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
	[shareWithFacebook addTarget:self action:@selector(shareToFacebook) forControlEvents:UIControlEventTouchUpInside];
	[shareWithFacebook setCenter:buttonSlots[2]];
	[shareWithFacebook setBounds:CGRectMake(0, 0, iconSideLength, iconSideLength)];
	[buttonsView addSubview:shareWithFacebook];
	
	UIButton * shareWithTwitter = [UIButton new];
	[shareWithTwitter setImage:[[UIImage imageNamed:@"twitter.png"]imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
	[shareWithTwitter addTarget:self action:@selector(shareToTwitter) forControlEvents:UIControlEventTouchUpInside];
	[shareWithTwitter setCenter:buttonSlots[3]];
	[shareWithTwitter setBounds:CGRectMake(0, 0, iconSideLength, iconSideLength)];
	[buttonsView addSubview:shareWithTwitter];
	
	UIButton * shareWithInstagram = [UIButton new];
	[shareWithInstagram setImage:[[UIImage imageNamed:@"instagram.png"]imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
	[shareWithInstagram addTarget:self action:@selector(shareToInstagram) forControlEvents:UIControlEventTouchUpInside];
	[shareWithInstagram setCenter:buttonSlots[4]];
	[shareWithInstagram setBounds:CGRectMake(0, 0, iconSideLength, iconSideLength)];
	[buttonsView addSubview:shareWithInstagram];
	
	UIButton * shareWithWeibo = [UIButton new];
	[shareWithWeibo setImage:[[UIImage imageNamed:@"weibo.png"]imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
	[shareWithWeibo addTarget:self action:@selector(shareToWeibo) forControlEvents:UIControlEventTouchUpInside];
	[shareWithWeibo setCenter:buttonSlots[5]];
	[shareWithWeibo setBounds:CGRectMake(0, 0, iconSideLength, iconSideLength)];
	[buttonsView addSubview:shareWithWeibo];
	
	UIButton * openInOtherApps = [UIButton new];
	[openInOtherApps setImage:[[UIImage imageNamed:@"more.png"]imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
	[openInOtherApps addTarget:self action:@selector(openInOtherApp) forControlEvents:UIControlEventTouchUpInside];
	[openInOtherApps setCenter:buttonSlots[6]];
	[openInOtherApps setBounds:CGRectMake(0, 0, iconSideLength, iconSideLength)];
	[buttonsView addSubview:openInOtherApps];
	
	buttonsView.alpha = 0.0;
	[self.view addSubview:buttonsView];
	
	[UIView animateWithDuration:0.5 delay:0.0 options:UIViewAnimationOptionCurveEaseOut animations:^{
		buttonsView.alpha = 1.0;
	} completion:nil];
}

- (void)completeExportingToOtherApp:(WODExportToOtherAppviewController *)controller
{
	[self dismissViewControllerAnimated:YES completion:nil];
}

- (void)outputImageComplete:(void(^)(UIImage * image))action
{
	[self initRenderHirachy];

	[self.appEngine setIsFullSizeRender:YES];
	[self.appEngine setFullSizeScale:self.scale];
	
	[self.appEngine setBackgroundImage:[WODConstants getCachedImageForKey:self.editHomeViewController.originalImageCachKey]];
	
	for (WODTextView * textView in self.editHomeViewController.textLayerManager.allTextViews)
	{
		[textView setNeedGenerateImage:YES];
		[self.appEngine addTextView:textView];
	}
	
	if (action)
	{
		[self.appEngine renderView];
		action([self.appEngine snapScreen]);
	}
}

- (void)saveToRoll
{
	[self.socailControl saveToImageRoll:nil];
}

- (void)shareWithEmail
{
	[self.socailControl shareToEmail:nil];
}

- (void)shareToFacebook
{
	[self.socailControl shareToFacebook:nil];
}

- (void)shareToTwitter
{
	[self.socailControl shareToTwitter:nil];
}

- (void)shareToWeibo
{
	[self.socailControl shareToWeibo:nil];
}

//- (void)shareToWeixin
//{
//	[self.socailControl shareToWeChat:nil];
//}

- (void)shareToInstagram
{
	ExportToInstagramPreviewController * etovc = [ExportToInstagramPreviewController new];
	etovc.image = self.outputImage;
	etovc.delegate = self;
	UINavigationController * nav = [[UINavigationController alloc]initWithRootViewController:etovc];
	[self presentViewController:nav animated:YES completion:nil];
}

- (void)openInOtherApp
{
	WODExportToOtherAppviewController * etovc = [WODExportToOtherAppviewController new];
	etovc.image = self.outputImage;
	etovc.delegate = self;
	UINavigationController * nav = [[UINavigationController alloc]initWithRootViewController:etovc];
	[self presentViewController:nav animated:YES completion:nil];
}

@end
