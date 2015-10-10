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
#import "WODAnimationManager.h"
#import "Flurry.h"
#import "WODFilterSelector.h"
#import "WODEditHomeActions.h"
#import "WODFullSizeExportViewController.h"
#import "CEReversibleAnimationController.h"
#import <BlocksKit/BlocksKit+UIKit.h>
#import "WODUserGuide.h"

#define TAG_ACTIONSHEET_ACTION 20
#define TAG_ACTIONSHEET_ADD_IMAGE 21

@interface EditHomeViewController ()<UIGestureRecognizerDelegate>

@property (nonatomic, strong) WODAnimationManager * animatorManager;
@property (nonatomic, strong) WODEditHomeActions * editActions;

@end

@implementation EditHomeViewController

- (id)init
{
    self = [super init];
    
    if (self)
	{
		self.view.backgroundColor = color_black;
        
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(handleOpenGLStageViewRebuildComplete) name:kNotificationOpenGLStageViewRebuildComplete object:nil];
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(handleOpenGLStageViewInitComplete) name:kNotificationOpenGLStageViewInitComplete object:nil];

        self.automaticallyAdjustsScrollViewInsets = NO;

		_textLayerManager = [WODTextLayerManager new];
    }
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	
	_editActions = [[WODEditHomeActions alloc]init];
	self.editActions.editHomeController = self;
	
	self.view.tintColor = color_white;
	
	[self.navigationItem setTitleView:[[UIImageView alloc]initWithImage:[[UIImage imageNamed:@"title"]imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate]]];
	
	UIBarButtonItem * chooseText = [[UIBarButtonItem alloc]initWithImage:[[UIImage imageNamed:@"chooseText.png"]imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] style:UIBarButtonItemStylePlain target:self.editActions action:@selector(chooseText:)];
	
	[self.navigationItem setLeftBarButtonItem:chooseText];
	
	UIBarButtonItem * action = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(action:)];
	[self.navigationItem setRightBarButtonItem:action];
		
	[self setupGestures];
    
	[self deleteSavedBackgroundImage];
    
    _toolbar = [[WODToolbar alloc]init];

    [self.view addSubview:self.toolbar];
    
    ws(wself);
    
    _openGLStageView = [[WODOpenGLESStageView alloc]init];
    [self.view addSubview:self.openGLStageView];

    [self.openGLStageView mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.edges.equalTo(wself.view).with.insets(UIEdgeInsetsMake(HEIGHT_STATUS_AND_NAV_BAR + 10, 10, 60, 10));
        
    }];
    
    [self.toolbar mas_makeConstraints:^(MASConstraintMaker *make) {
      
        make.left.equalTo(wself.view);
        make.width.equalTo(wself.view.mas_width);
        make.top.equalTo(wself.openGLStageView.mas_bottom).offset(10);
        make.bottom.equalTo(wself.view.mas_bottom);
        
    }];
    
    [self checkControlVisiability];
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    NSUInteger topOffset = HEIGHT_STATUS_AND_NAV_BAR;
    if (!isVertical())
    {
        topOffset = HEIGHT_STATUS_AND_NAV_BAR_LANDSCAPE;
    }
    
    ws(wself);
    
    [self.openGLStageView mas_updateConstraints:^(MASConstraintMaker *make) {
        
        make.edges.equalTo(wself.view).with.insets(UIEdgeInsetsMake(topOffset + 10, 10, 60, 10));
        
    }];
    
    [self.toolbar mas_updateConstraints:^(MASConstraintMaker *make) {
        
        make.width.equalTo(wself.view.mas_width);
        make.top.equalTo(wself.openGLStageView.mas_bottom).offset(10);
        make.bottom.equalTo(wself.view.mas_bottom);
        
    }];
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
	
    WODDebug(@"viewWillAppear");
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
	
    WODDebug(@"OG View Frame: %@",NSStringFromCGRect(self.openGLStageView.frame));
    WODDebug(@"Toolbar Frame: %@", NSStringFromCGRect(self.toolbar.frame));
}

- (void)viewDidLayoutSubviews
{
    WODDebug(@"OG View Frame: %@",NSStringFromCGRect(self.openGLStageView.frame));
    WODDebug(@"Toolbar Frame: %@", NSStringFromCGRect(self.toolbar.frame));
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
	[self.openGLStageView setBackgroundColor:color_black];
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

- (NSArray *)setupInitToolbarItems
{
	WODButton * addTextButton = [[WODButton alloc]init];
	[addTextButton setStyle:WODButtonStyleClear];
	[addTextButton addTarget:self action:@selector(addText) forControlEvents:UIControlEventTouchUpInside];
	[addTextButton setImage:[[UIImage imageNamed:@"plus_mark.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
	[addTextButton setImage:[[UIImage imageNamed:@"plus_mark.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateSelected];

	return @[addTextButton];
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

- (void)addText
{
    WODInputTextViewController * textInputViewController = [WODInputTextViewController new];
    textInputViewController.editType = EditTypeNew;
    [textInputViewController setDelegate:self];
    [self fadeNavigationPush:textInputViewController];
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
            WODDebug(@"errro when deleting saved background image:%@",error);
		}
	}
}

- (void)action:(UIBarButtonItem *)item
{
    ws(wself);
    UIActionSheet * actionsAS = [UIActionSheet new];

    [actionsAS setTitle:iStr(@"Actions")];
    
    [actionsAS bk_addButtonWithTitle:iStr(@"SAVE_IMAGE") handler:^{
        
        [wself shareImage];
        
    }];
    
    [actionsAS bk_setDestructiveButtonWithTitle:iStr(@"ACTION_SHEET_NEW") handler:^{
        
        [wself restart];
        
    }];
    
    [actionsAS bk_setCancelButtonWithTitle:iStr(@"CANCEL") handler:nil];
    
    [actionsAS showInView:self.view];
}


- (void)restart
{
	UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:NSLocalizedString(@"ALERTVIEW_NEW", nil) message:NSLocalizedString(@"ALERTVIEW_NEW_MSG", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"CANCEL", nil) otherButtonTitles:nil];

    ws(wself);
    [alertView bk_addButtonWithTitle:iStr(@"OK") handler:^{
        
        [wself performRestartAction];
        
    }];
    
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
	
    WODDebug(@"didFinishInputtingText");
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

#pragma mark - *** textview layer management ***

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
                WODError(@"ERROR:\n%@",error.description);
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

#pragma mark - getter

- (WODAnimationManager *)animatorManager
{
    if (!_animatorManager)
    {
        _animatorManager = [WODAnimationManager new];
    }
    return _animatorManager;
}

@end


