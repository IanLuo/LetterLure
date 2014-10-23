//
//  EditHomeViewController.m
//  TOP
//
//  Created by ianluo on 13-12-12.
//  Copyright (c) 2013年 WOD. All rights reserved.
//

#import "EditHomeViewController.h"
#import "WODImagePickerViewController.h"
#import "WODButton.h"
#import "WODActionSheet.h"
#import "WODSimpleScrollItemPicker.h"
#import "WODEffect.h"
#import "WODFontRegisterViewController.h"
#import "SVProgressHUD.h"
#import "WODAnimationManager.h"
#import "WODUserGuide.h"
#import "WODAboutViewController.h"
#import "Flurry.h"
#import "WODBrowseTheworldViewController.h"
#import "WODFilterSelector.h"
#import "WODEditHomeActions.h"
#import "WODFullSizeExportViewController.h"
#import "kxMenu.h"

#define TAG_ACTIONSHEET_ACTION 20
#define TAG_ACTIONSHEET_ADD_IMAGE 21

@interface EditHomeViewController ()<UIGestureRecognizerDelegate,FUIAlertViewDelegate>

@property (nonatomic, strong) WODAnimationManager * animatorManager;
@property (nonatomic, strong) WODEditHomeActions * editActions;
@property (nonatomic, strong) NSMutableArray * orientationSensibleConstraints;

@end

@implementation EditHomeViewController

- (WODAnimationManager *)animatorManager
{
	if (!_animatorManager)
	{
		_animatorManager = [WODAnimationManager new];
	}
	return _animatorManager;
}

- (id)init
{
    self = [super init];
    if (self)
	{
		self.view.backgroundColor = WODConstants.COLOR_VIEW_BACKGROUND;
		self.automaticallyAdjustsScrollViewInsets = NO;
		self.edgesForExtendedLayout = UIRectEdgeNone;

		_textLayerManager = [WODTextLayerManager new];
		
		_toolbar = [[WODToolbar alloc]init];
		[self.toolbar setTranslatesAutoresizingMaskIntoConstraints:NO];
		[self.view addSubview:self.toolbar];
		
		_openGLStageView = [[WODOpenGLESStageView alloc]init];
		[self.openGLStageView setTranslatesAutoresizingMaskIntoConstraints:NO];
		[self.view addSubview:self.openGLStageView];
		
		_orientationSensibleConstraints = [NSMutableArray array];
						
		float toolbarHeight = [self.toolbar toolbarHeight];
		NSDictionary *viewsDictionary = @{@"openGLStageView":self.openGLStageView,@"toolbar":self.toolbar};
		[self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-10-[openGLStageView]-10-|" options:NSLayoutFormatAlignAllCenterY metrics:nil views:viewsDictionary]];
		[self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[toolbar]|" options:NSLayoutFormatAlignAllCenterY metrics:nil views:viewsDictionary]];
		
		[self.orientationSensibleConstraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-10-[openGLStageView]-10-[toolbar(toolbarHeight)]|" options:NSLayoutFormatAlignAllCenterX metrics:@{@"toolbarHeight":@(toolbarHeight)} views:viewsDictionary]];
				
		[self.view addConstraints:self.orientationSensibleConstraints];
		
		[[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(orientaitonChanged:) name:UIApplicationDidChangeStatusBarOrientationNotification object:nil];
		[[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(handleOpenGLStageViewRebuildComplete) name:kNotificationOpenGLStageViewRebuildComplete object:nil];
		[[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(handleOpenGLStageViewInitComplete) name:kNotificationOpenGLStageViewInitComplete object:nil];
		[[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(updateTheme) name:NOTIFICATION_THEME_CHANGED object:nil];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	
	_editActions = [[WODEditHomeActions alloc]init];
	self.editActions.editHomeController = self;
	
	self.view.tintColor = [UIColor whiteColor];
	
	[self.navigationItem setTitleView:[[UIImageView alloc]initWithImage:[[UIImage imageNamed:@"title"]imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate]]];
	
	UIBarButtonItem * chooseText = [[UIBarButtonItem alloc]initWithImage:[[UIImage imageNamed:@"chooseText.png"]imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] style:UIBarButtonItemStylePlain target:self.editActions action:@selector(chooseText:)];
	
	[self.navigationItem setLeftBarButtonItem:chooseText];
	
	UIBarButtonItem * action = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(action:)];
	[self.navigationItem setRightBarButtonItem:action];
		
	[self setupGestures];
	
	[self deleteSavedBackgroundImage];
	
	BOOL isIPad = UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad;
	[KxMenu setTintColor:WODConstants.COLOR_TEXT_ACTIONSHEET];
	[KxMenu setTitleFont:[UIFont boldSystemFontOfSize:isIPad ? 20 : 12]];
}

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];

	[self checkControlVisiability];
	
	//the openGEES view is not able to init when the frame is not set
	if (!CGRectEqualToRect(self.openGLStageView.frame, CGRectZero))
	{
		[self.openGLStageView setupRenderHirarchy];
	}
	
#ifdef DEBUGMODE
	NSLog(@"(%@,%i):viewWillAppear",[[NSString stringWithUTF8String:__FILE__]lastPathComponent],__LINE__);
#endif
}

- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
	
	self.navigationController.delegate = nil;
	
	[self.openGLStageView tearDownRenderHirarchy];
}

- (void)viewDidAppear:(BOOL)animated
{
	[super viewDidAppear:animated];
	
	self.navigationController.delegate = self;
	
	if (![[NSUserDefaults standardUserDefaults]objectForKey:KEY_IS_RETURN_LAUNCH])
	{
		WODUserGuide * userGuide = [WODUserGuide new];
		UINavigationController * nav = [[UINavigationController alloc] initWithRootViewController:userGuide];
		
		[nav setModalPresentationStyle:UIModalPresentationFormSheet];
		[self presentViewController:nav animated:YES completion:nil];

		[[NSUserDefaults standardUserDefaults]setObject:[NSNumber numberWithBool:YES] forKey:KEY_IS_RETURN_LAUNCH];
	}
	
#ifdef DEBUGMODE
	NSLog(@"(%@,%i):viewDidAppear",[[NSString stringWithUTF8String:__FILE__]lastPathComponent],__LINE__);
#endif
}

- (void)updateTheme
{
	[self.navigationController.navigationBar setBarTintColor:WODConstants.COLOR_NAV_BAR];
	[self.navigationItem.leftBarButtonItem configureFlatButtonWithColor:WODConstants.COLOR_CONTROLLER highlightedColor:WODConstants.COLOR_CONTROLLER_HIGHTLIGHT cornerRadius:3.0f];
	[self.navigationItem.rightBarButtonItem configureFlatButtonWithColor:WODConstants.COLOR_CONTROLLER highlightedColor:WODConstants.COLOR_CONTROLLER_HIGHTLIGHT cornerRadius:3.0f];
}

- (void)handleOpenGLStageViewRebuildComplete
{
	if(self.openGLStageView.isReadyToRender)
	{
		UIImage * bgImage = [self getSavedBackgroundImage];
		[self.openGLStageView setBackgroundImage:bgImage];
	}
}

- (void)handleOpenGLStageViewInitComplete
{
	[self.openGLStageView setBackgroundColor:WODConstants.COLOR_VIEW_BACKGROUND];
	if(self.openGLStageView.isReadyToRender)
	{
		UIImage * bgImage = [self getSavedBackgroundImage];
		[self.openGLStageView setBackgroundImage:bgImage];
	}
}

- (void)setupGestures
{
	UIPanGestureRecognizer * pan = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(pan:)];
	pan.delegate = self;
	[pan setMaximumNumberOfTouches:2];
	[pan setMinimumNumberOfTouches:1];
	[self.view addGestureRecognizer:pan];
	
	UIRotationGestureRecognizer * rotate = [[UIRotationGestureRecognizer alloc]initWithTarget:self action:@selector(rotation:)];
	rotate.delegate = self;
	[self.view addGestureRecognizer:rotate];
	
	UIPinchGestureRecognizer *pinchGesture = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(pinch:)];
	pinchGesture.delegate = self;
	[self.view addGestureRecognizer:pinchGesture];
}

- (void)dealloc
{
	[self deleteSavedBackgroundImage];
	[[NSNotificationCenter defaultCenter]removeObserver:self];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSUInteger)supportedInterfaceOrientations
{
	return UIInterfaceOrientationMaskAll;
}

- (BOOL)shouldAutorotate
{
	return YES;
}

- (void)orientaitonChanged:(NSNotification *)notification
{
	float toolbarHeight = [self.toolbar toolbarHeight];
	
	[self.view removeConstraints:self.orientationSensibleConstraints];
	[self.orientationSensibleConstraints removeAllObjects];
	
	NSDictionary *viewsDictionary = @{@"openGLStageView":self.openGLStageView,@"toolbar":self.toolbar};
	[self.orientationSensibleConstraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-10-[openGLStageView]-10-[toolbar(toolbarHeight)]|" options:NSLayoutFormatAlignAllCenterX metrics:@{@"toolbarHeight":@(toolbarHeight)} views:viewsDictionary]];
	[self.view addConstraints:self.orientationSensibleConstraints];
	
	[self.toolbar layoutIfNeeded];
}

- (NSArray *)setupInitToolbarItems
{
	WODButton * addTextButton = [[WODButton alloc]init];
	[addTextButton setStyle:WODButtonStyleClear];
	[addTextButton addTarget:self action:@selector(addText) forControlEvents:UIControlEventTouchUpInside];
	[addTextButton setImage:[[UIImage imageNamed:@"plus_mark.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
	[addTextButton setImage:[[UIImage imageNamed:@"plus_mark.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateSelected];

	return @[addTextButton];
}

- (void)addText
{
	WODInputTextViewController * textInputViewController = [WODInputTextViewController new];
	textInputViewController.editType = EditTypeNew;
	[textInputViewController setDelegate:self];
	[self fadeNavigationPush:textInputViewController];
}

- (NSArray *)setupCompleteToolbarItems
{
	WODButton * typeSetterButton = [[WODButton alloc]init];
	[typeSetterButton setImage:[[UIImage imageNamed:@"adjustment.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate]forState:UIControlStateNormal];
	[typeSetterButton addTarget:self.editActions action:@selector(typesetter:) forControlEvents:UIControlEventTouchUpInside];
	[typeSetterButton setStyle:WODButtonStyleClear];
	
	WODButton * applyEffectButton = [[WODButton alloc]init];
	[applyEffectButton setImage:[[UIImage imageNamed:@"effects.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate]forState:UIControlStateNormal];
	[applyEffectButton setStyle:WODButtonStyleClear];
	[applyEffectButton addTarget:self.editActions action:@selector(applyEffect:) forControlEvents:UIControlEventTouchUpInside];
	
	WODButton * opacity = [[WODButton alloc]init];
	[opacity setImage:[[UIImage imageNamed:@"edit_image.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate]forState:UIControlStateNormal];
	[opacity setStyle:WODButtonStyleClear];
	[opacity addTarget:self.editActions action:@selector(setOpacity:) forControlEvents:UIControlEventTouchUpInside];

	WODButton * editText = [[WODButton alloc]init];
	[editText setImage:[[UIImage imageNamed:@"pen.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate]forState:UIControlStateNormal];
	[editText setStyle:WODButtonStyleClear];
	[editText addTarget:self.editActions action:@selector(editText:) forControlEvents:UIControlEventTouchUpInside];
	
	WODButton * removeText = [[WODButton alloc]init];
	[removeText setImage:[[UIImage imageNamed:@"trash.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate]forState:UIControlStateNormal];
	[removeText setStyle:WODButtonStyleClear];
	[removeText addTarget:self.editActions action:@selector(deleteCurrentText) forControlEvents:UIControlEventTouchUpInside];
	
	return @[typeSetterButton,applyEffectButton,opacity,editText,removeText];
}

//for now, the controlls are the 'preview, edit, and delete button'
- (void)checkControlVisiability
{
	if (self.textLayerManager.allTextViews.count == 0)
	{
		[self.toolbar setItems:[self setupInitToolbarItems]];
	}
	else
	{
		[self.toolbar setItems:[self setupCompleteToolbarItems]];
	}
}

#pragma mark - select effect package delegate

- (void)didFinishSelectEffectPackage:(NSString *)currentPackageName currentEffect:(NSString *)effectXMLfilePath viewController:(WODEffectsPackageViewController *)viewController{
	__weak typeof(self) wself = self;
	[self dismissViewControllerAnimated:YES completion:^{
		[wself.editActions applyEffect:wself.toolbar.items[2]];
	}];
	
	if(effectXMLfilePath)
	{
		WODEffect * effect = [[WODEffect new] initWithXMLFilePath:effectXMLfilePath];
		if(self.textLayerManager.currentTextView.effectProvider != effect)
		{
			[effect prepare:^{
				self.textLayerManager.currentTextView.effectProvider = nil;
				[self.textLayerManager.currentTextView setEffectProvider:effect];
				[self.openGLStageView updateTextViewImage:self.textLayerManager.currentTextView];
			}];
		}
	}
}

#pragma mark - handle background image
- (UIImage *)getSavedBackgroundImage
{
	return [UIImage imageWithContentsOfFile:[NSTemporaryDirectory() stringByAppendingString:@"backgroundImage.png"]];
}

- (void)deleteSavedBackgroundImage
{
	NSString * path = [NSTemporaryDirectory() stringByAppendingString:@"backgroundImage.png"];
	if ([[NSFileManager defaultManager] fileExistsAtPath:path])
	{
		NSError * error;
		[[NSFileManager defaultManager]removeItemAtPath:path error:&error];
		if (error)
		{
#ifdef DEBUGMODE
			NSLog(@"errro when deleting saved background image:%@",error);
#endif
		}
	}
}

- (void)action:(UIBarButtonItem *)item
{
	NSMutableArray * items = [NSMutableArray new];
	KxMenuItem * shareItem = [KxMenuItem menuItem:@"share" image:[[UIImage imageNamed:@"paper_plane.png"]imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] target:self action:@selector(shareImage)];
	[items addObject:shareItem];
	KxMenuItem * restartItem = [KxMenuItem menuItem:@"restart" image:[[UIImage imageNamed:@"plus_mark.png"]imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] target:self action:@selector(restart)];
	[items addObject:restartItem];
	
	[KxMenu showMenuInView:self.view fromRect:CGRectMake(self.view.bounds.size.width - 30, 0, 0, 0) menuItems:items];
}

- (void)willPresentActionSheet:(UIActionSheet *)actionSheet
{
    for (UIView *subview in actionSheet.subviews) {
        if ([subview isKindOfClass:[UIButton class]]) {
            UIButton *button = (UIButton *)subview;
            [button setTitleColor:WODConstants.COLOR_TEXT_ACTIONSHEET forState:UIControlStateNormal];
			[button setTitleColor:WODConstants.COLOR_TEXT_ACTIONSHEET forState:UIControlStateHighlighted];
        }
    }
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
	switch (actionSheet.tag)
	{
//		case TAG_ACTIONSHEET_ADD_IMAGE:
//		{
//			switch (buttonIndex)
//			{
//				case 0:
//				{
//					[self showImagePicker];
//					break;
//				}
//				case 1:
//				{
//					UIImage * image = [UIPasteboard generalPasteboard].image;
//					if(image)
//						[self useOutsideImage:image];
//					break;
//				}
//			}
//			break;
//		}
			
		case TAG_ACTIONSHEET_ACTION:
		{
			switch (buttonIndex)
			{
				case 0:
				{
					WODUserGuide * userGuide = [WODUserGuide new];
					UINavigationController * nav = [[UINavigationController alloc] initWithRootViewController:userGuide];
					
					[nav setModalPresentationStyle:UIModalPresentationFormSheet];
					[self presentViewController:nav animated:YES completion:nil];
					break;
				}
				case 1:
				{
					WODFontRegisterViewController * fontRegisterViewController = [WODFontRegisterViewController new];
					UINavigationController * nav = [[UINavigationController alloc] initWithRootViewController:fontRegisterViewController];
					
					[nav setModalPresentationStyle:UIModalPresentationFormSheet];
					[self presentViewController:nav animated:YES completion:nil];
					break;
				}
				case 2:
				{
//					[self shareImage];
//					break;
				}
				case 3:
				{
//					[self restart];
//					break;
				}
				case 4:
				{
//					[self changeTheme];
//					break;
				}
				case 5:
				{
					WODAboutViewController * about = [WODAboutViewController new];
					UINavigationController * nav = [[UINavigationController alloc]initWithRootViewController:about];
					[nav setModalPresentationStyle:UIModalPresentationFormSheet];
					
					[self presentViewController:nav animated:YES completion:nil];
					break;
				}
				case 6:
				{
					WODBrowseTheworldViewController * brows = [WODBrowseTheworldViewController new];
					UINavigationController * nav = [[UINavigationController alloc]initWithRootViewController:brows];
					[nav setModalPresentationStyle:UIModalPresentationFormSheet];
					
					[self presentViewController:nav animated:YES completion:nil];
					break;
				}
			}
			break;
		}
	}
}

- (void)changeTheme
{
	if (self.currentItemPicker)
	{
		[self.currentItemPicker dismiss];
	}

	WODSimpleScrollItemPicker * picker = [WODSimpleScrollItemPicker new];
	picker.distansFromBottomLandscape = 30;
	picker.distansFromBottomPortrait = 50;
	[picker setPosition:BarPostionBotton];
	
	picker.selectedIndex = [[NSUserDefaults standardUserDefaults]objectForKey:KEY_SAVED_THEME_INDEX] ? [[[NSUserDefaults standardUserDefaults]objectForKey:KEY_SAVED_THEME_INDEX] intValue] : 0;
	
	NSArray * themes = [WODConstants themes];
	for (NSArray * theme in themes)
	{
		if (theme > 0)
		{
			UIColor * color = theme[0];
			UIView * view = [UIView new];
			view.backgroundColor = color;
			[picker addItemWithView:view];
		}
	}
	
	[picker showFrom:self.view withSelection:^(WODSimpleScrollItemPickerItem *selectedItem) {
		if (selectedItem)
		{
			[WODConstants setUpUITheme:(int)selectedItem.index];
			
			[[NSUserDefaults standardUserDefaults]setObject:@(selectedItem.index) forKey:KEY_SAVED_THEME_INDEX];
			[[NSUserDefaults standardUserDefaults]synchronize];
		}
	}];
}

- (void)restart
{
	FUIAlertView *alertView = [[FUIAlertView alloc]initWithTitle:NSLocalizedString(@"ALERTVIEW_NEW", nil) message:NSLocalizedString(@"ALERTVIEW_NEW_MSG", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"CANCEL", nil) otherButtonTitles:NSLocalizedString(@"OK", nil),nil];
	alertView.titleLabel.textColor = [UIColor cloudsColor];
	alertView.titleLabel.font = [UIFont boldFlatFontOfSize:16];
	alertView.messageLabel.textColor = [UIColor cloudsColor];
	alertView.messageLabel.font = [UIFont flatFontOfSize:14];
	alertView.backgroundOverlay.backgroundColor = [[UIColor cloudsColor] colorWithAlphaComponent:0.8];
	alertView.alertContainer.backgroundColor = WODConstants.COLOR_DIALOG_BACKGROUND;
	alertView.defaultButtonColor = [UIColor cloudsColor];
	alertView.defaultButtonShadowColor = [UIColor asbestosColor];
	alertView.defaultButtonFont = [UIFont boldFlatFontOfSize:16];
	alertView.defaultButtonTitleColor = [UIColor asbestosColor];
	[alertView show];
}

- (void)performRestartAction
{
	[self deleteSavedBackgroundImage];
	[self.openGLStageView removeBackgroundImage];
	
	for (WODTextView * textView in self.textLayerManager.allTextViews)
	{
		[self.textLayerManager removeTextView:textView];
		[self.openGLStageView removeTextView:textView];
	}
	
	[self.navigationController popToRootViewControllerAnimated:YES];
}

- (void)shareImage
{
	WODFullSizeExportViewController * fullSizeExportViewController = [WODFullSizeExportViewController new];
	fullSizeExportViewController.editHomeViewController = self;
	fullSizeExportViewController.fullScreenImage = [self.openGLStageView snapshotScreen];
	
	[self.navigationController pushViewController:fullSizeExportViewController animated:YES];
}

- (void)alertView:(FUIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
	if (buttonIndex == 1)
	{
		[self performRestartAction];
	}
}

#pragma mark - text input delegate

- (void)didFinishInputtingText:(WODInputTextViewController *)inputTextViewController text:(NSAttributedString *)attrString
{
	WODTextView * textview = nil;
	[inputTextViewController.textView sizeToFit];
	CGSize textViewSize = (CGSize){inputTextViewController.textView.bounds.size.width, inputTextViewController.textView.bounds.size.height};
	
	if (inputTextViewController.editType == EditTypeNew)
	{
		textview = [[WODTextView alloc]initWithFrame:CGRectMake(0, 0, textViewSize.width, textViewSize.height)];
		textview.text = attrString;
		[self addTextView:textview];
		[self selectTextView:textview];
	}
	else
	{
		textview = self.textLayerManager.currentTextView;
		textview.bounds = CGRectMake(0, 0, textViewSize.width, textViewSize.height);
		textview.text = attrString;

		/*TODO:fix in further versoin
		 if the typesetter provider is not path, say if it's a bend or free draw, the result after editing will be messed up, because the result will be in accurate for the value was calculated based on the old letters.
		*/
		textview.currentTypeSet = TypesetShapePath;
		[textview resetLayoutShapePath];
		
		textview.hideFeatures = NO;
		[self.openGLStageView updateTextViewImage:textview];
	}
	
	[self fadeNavigationPop];
	
#ifdef DEBUGMODE
	NSLog(@"(%@,%i):didFinishInputtingText",[[NSString stringWithUTF8String:__FILE__]lastPathComponent],__LINE__);
#endif
}

- (void)didCancelInputtingText:(WODInputTextViewController *)inputTextViewController
{
	[self fadeNavigationPop];
}

#pragma mark - typesetter edit delegate

- (void)didFinishTypeSetterEdit:(WODTypeSetterViewController *)typeSetterViewController newTextView:(WODTextView *)textView
{
	[self fadeNavigationPop];
	
	[self removeTextView:textView];
	
	[textView setHideFeatures:NO];
	
	[self addTextView:textView];
	[self selectTextView:textView];
}

- (void)didCancelTypeSetterEdit:(WODTypeSetterViewController *)typeSetterViewController
{
	[self fadeNavigationPop];
}

#pragma mark - textview layer management

- (void)addTextView:(WODTextView *)textView
{
	textView.hideFeatures = NO;
	
	[self.textLayerManager addTextView:textView];
	[self.openGLStageView addTextView:textView];
	
	[self checkControlVisiability];
}

- (void)removeTextView:(WODTextView *)textView
{
	[self.textLayerManager removeTextView:self.textLayerManager.currentTextView];
	[self.openGLStageView removeTextView:textView];
}

- (void)selectTextView:(WODTextView *)textView
{
	[self.textLayerManager selectTextView:textView];
	[self.openGLStageView selectTextView:self.textLayerManager.currentTextView];
}

- (void)setBackgroundImage:(UIImage *)image
{
	if (self.openGLStageView.isReadyToRender)
	{
		[self.openGLStageView setBackgroundImage:image];
	}
	
	if (image)
	{
		dispatch_sync(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
			
			NSError * error;
			[UIImagePNGRepresentation(image) writeToFile:[NSTemporaryDirectory() stringByAppendingString:@"backgroundImage.png"] options:0 error:&error];
			if (error)
			{
				NSLog(@"ERROR %s \n %@",__PRETTY_FUNCTION__,error);
			}
		});
	}
}

# pragma mark - Gestures

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    // Begin transformations
    [self.textLayerManager.currentTextView.transformEngine start];
}

- (void)pan:(UIPanGestureRecognizer *)sender
{
    // Pan (1 Finger)
    if((sender.numberOfTouches == 1) &&
	   ((self.textLayerManager.currentTextView.transformEngine.state == S_NEW) || (self.textLayerManager.currentTextView.transformEngine.state == S_TRANSLATION)))
    {
        CGPoint translation = [sender translationInView:sender.view];
        float x = translation.x/sender.view.frame.size.width;
        float y = translation.y/sender.view.frame.size.height;
        [self.textLayerManager.currentTextView.transformEngine translate:GLKVector2Make(x, y) withMultiplier:1.0f];
		[self.openGLStageView updateTextViewTransform:self.textLayerManager.currentTextView];
    }
    
    // Pan (2 Fingers)
    else if((sender.numberOfTouches == 2) &&
			((self.textLayerManager.currentTextView.transformEngine.state == S_NEW) || (self.textLayerManager.currentTextView.transformEngine.state == S_ROTATION)))
    {
        const float m = GLKMathDegreesToRadians(0.5f);
        CGPoint rotation = [sender translationInView:sender.view];
        [self.textLayerManager.currentTextView.transformEngine rotate:GLKVector3Make(rotation.x, rotation.y, 0.0f) withMultiplier:m];
		[self.openGLStageView updateTextViewTransform:self.textLayerManager.currentTextView];
    }
}

- (void)pinch:(UIPinchGestureRecognizer *)sender
{
    // Pinch
    if((self.textLayerManager.currentTextView.transformEngine.state == S_NEW) || (self.textLayerManager.currentTextView.transformEngine.state == S_SCALE)|| (self.textLayerManager.currentTextView.transformEngine.state == S_ROTATION))
    {
        float scale = [sender scale];
        [self.textLayerManager.currentTextView.transformEngine scale:scale];
		[self.openGLStageView updateTextViewTransform:self.textLayerManager.currentTextView];
    }
}

- (void)rotation:(UIRotationGestureRecognizer *)sender
{
    // Rotation
    if((self.textLayerManager.currentTextView.transformEngine.state == S_NEW) || (self.textLayerManager.currentTextView.transformEngine.state == S_ROTATION)|| (self.textLayerManager.currentTextView.transformEngine.state == S_SCALE))
    {
        float rotation = [sender rotation];
        [self.textLayerManager.currentTextView.transformEngine rotate:GLKVector3Make(0.0f, 0.0f, rotation) withMultiplier:1.0f];
		[self.openGLStageView updateTextViewTransform:self.textLayerManager.currentTextView];
    }
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
	if (CGRectContainsPoint(self.toolbar.frame, [touch locationInView:gestureRecognizer.view]))
	{
		return NO;
	}
	if ([touch.view isKindOfClass: [UISlider class]])
	{
		return NO;
	}
	return YES;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
	// if the gesture recognizers are on different views, don't allow simultaneous recognition
	if (gestureRecognizer.view != otherGestureRecognizer.view)    return NO;// if either of the gesture recognizers is the long press, don't allow simultaneous recognition
	if ([gestureRecognizer isKindOfClass:[UIPanGestureRecognizer class]] || [otherGestureRecognizer isKindOfClass:[UIPanGestureRecognizer class]])
		return NO;
	return YES;
}

#pragma mark - **** animation transitioning ****

- (void)fadeNavigationPush:(UIViewController *)controller
{
	customNavigationTransition = YES;
	[self.navigationController pushViewController:controller animated:YES];
}

- (void)fadeNavigationPop
{
	customNavigationTransition = YES;
	[self.navigationController popViewControllerAnimated:YES];
}

-(id<UIViewControllerAnimatedTransitioning>)navigationController:(UINavigationController *)navigationController animationControllerForOperation:(UINavigationControllerOperation)operation fromViewController:(UIViewController *)fromVC toViewController:(UIViewController *)toVC
{
	if (!customNavigationTransition)
	{
		return nil;
	}
	
	CEReversibleAnimationController * animationController = [self.animatorManager animatorWithType:AnimatorCorssfadeAnimator];
	animationController.duration = 0.3;
	
	switch (operation)
	{
        case UINavigationControllerOperationPush:
            animationController.reverse = NO;
        case UINavigationControllerOperationPop:
            animationController.reverse = YES;
        default: break;
    }
	
	customNavigationTransition = NO;
	return animationController;
}
@end
