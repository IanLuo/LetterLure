//
//  WODTypeSetterViewController.m
//  TOP
//
//  Created by ianluo on 13-12-13.
//  Copyright (c) 2013年 WOD. All rights reserved.
//

#import "WODTypeSetterViewController.h"
#import "WODButton.h"

@interface WODTypeSetterViewController()
{
	BOOL needUpdateUIAfterLayout;
}

//@property (nonatomic, strong)WODButton * previewButton;

@end

@implementation WODTypeSetterViewController

- (id)init
{
	self = [super init];
	
	if (self)
	{
		self.view.backgroundColor = color_black;
		needUpdateUIAfterLayout = YES;
	}
	
	return self;
}

- (void)dealloc
{
    WODDebug(@"deallocing..");

	[[NSNotificationCenter defaultCenter]removeObserver:self];
}

- (void)viewDidLoad
{
	[super viewDidLoad];
	
    [self setAutomaticallyAdjustsScrollViewInsets:NO];
	
	UIBarButtonItem * cancel = [[UIBarButtonItem alloc]initWithImage:[[UIImage imageNamed:@"cross_mark.png"]imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] style:UIBarButtonItemStylePlain target:self action:@selector(cancel)];
	[self.navigationItem setLeftBarButtonItem:cancel];
	
	UIBarButtonItem * apply = [[UIBarButtonItem alloc]initWithImage:[[UIImage imageNamed:@"check_mark.png"]imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] style:UIBarButtonItemStylePlain target:self action:@selector(apply)];
	[self.navigationItem setRightBarButtonItem:apply];
	
	_toolbar = [UIView new];
	self.toolbar.translatesAutoresizingMaskIntoConstraints = NO;
	self.toolbar.backgroundColor = color_black;
	[self.view addSubview:self.toolbar];
	
	[[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(handleOpengleStageRebuildComplete) name:kNotificationOpenGLStageViewRebuildComplete object:nil];
	[[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(handleOpengleStageRebuildComplete) name:kNotificationOpenGLStageViewInitComplete object:nil];
		
	[self setupToolbar];
		
	[self setupGestures];
}

- (void)startPreview
{
	[self.openGLESStageView setGrayoutBackground:NO];
}

- (void)stopPreview
{
	[self.openGLESStageView setGrayoutBackground:YES];
}


- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
	needUpdateUIAfterLayout = YES;
}

- (void)viewWillLayoutSubviews
{
}

- (void)viewWillAppear:(BOOL)animated
{
	_openGLESStageView = [[WODOpenGLESStageView alloc]init];
	self.openGLESStageView.translatesAutoresizingMaskIntoConstraints = NO;
	[self.view addSubview:self.openGLESStageView];

	[self layout];
	
	[self layoutMoreViews];
}

- (void)handleOpengleStageRebuildComplete
{
	if(self.openGLESStageView.isReadyToRender)
	{
		[self initContent];
	}
}

- (void)setupToolbar
{
	//over written by sub class to do the setup
}

- (void)layoutMoreViews
{
	//overwritten by sub class to do the layout
}

- (void)layout
{
	[self.view removeConstraints:self.view.constraints];
	[self.toolbar removeConstraints:self.toolbar.constraints];
	
	UIInterfaceOrientation toInterfaceOrientation = [[UIApplication sharedApplication]statusBarOrientation];
	float toolbarHeight = 50;
	
	if (!isPad())
		toolbarHeight = toInterfaceOrientation == UIInterfaceOrientationPortrait || toInterfaceOrientation == UIInterfaceOrientationPortraitUpsideDown ? 50 : 30;
    
    NSUInteger topOffset = HEIGHT_STATUS_AND_NAV_BAR;
    if (isVertical())
    {
        topOffset = HEIGHT_STATUS_AND_NAV_BAR_LANDSCAPE;
    }
	
//	[self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|[toolbar]|" options:0 metrics:nil views:@{@"toolbar":self.toolbar}]];
//    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|-topOffset-[openGLESStageView]-10-|" options:0 metrics:@{@"topOffset":@(topOffset)} views:@{@"openGLESStageView":self.openGLESStageView}]];
//	[self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-topOffset-[openGLESStageView]-10-[toolbar(hight)]|" options:0 metrics:@{@"hight":@(toolbarHeight),@"topOffset":@(topOffset)} views:@{@"toolbar":self.toolbar,@"openGLESStageView":self.openGLESStageView}]];

    [self.toolbar mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.width.equalTo(self.view.mas_width);
        make.height.mas_equalTo(@(toolbarHeight));
        make.bottom.equalTo(self.view.mas_bottom);
        
    }];
    
    [self.openGLESStageView mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.width.equalTo(self.view.mas_width).offset(20);
        make.height.equalTo(self.view.mas_height).offset(-toolbarHeight-topOffset);
        make.top.mas_equalTo(@(0));
        
    }];
    
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

- (void)cancel
{
	[self recoveryOriginalCacheImage:self.textView];
	
	[self.openGLESStageView tearDownRenderHirarchy];

	if ([self.delegate respondsToSelector:@selector(didCancelTypeSetterEdit:)])
	{
		[self.delegate didCancelTypeSetterEdit:self];
	}
}

- (void)apply
{
	[self.openGLESStageView tearDownRenderHirarchy];
	
	if([self.delegate respondsToSelector:@selector(didFinishTypeSetterEdit:newTextView:)])
	{
		self.textView.shouldShowPath = NO; // hide the shape border, if there is any
		[self.delegate didFinishTypeSetterEdit:self newTextView:self.textView];
	}
}


- (void)setTextView:(WODTextView *)textView
{
	[self backupOriginalCacheImage:textView];
	_textView = [textView copyOfThisTextView];
	self.textView.transformEngine  = [[WODTransformEngine alloc]initWithDepth:1.0f Scale:1.0f Translation:GLKVector2Make(0.0f, 0.0f) Rotation:GLKVector3Make(0.0f, 0.0f, 0.0f)];
}

- (void)backupOriginalCacheImage:(WODTextView *)textView
{
	[WODConstants addOrUpdateImageCache:[WODConstants getCachedImageForKey:textView.cacheKey] forKey:[textView.cacheKey stringByAppendingString:@"_bak"]];
}

- (void)recoveryOriginalCacheImage:(WODTextView *)textView
{
	[WODConstants addOrUpdateImageCache:[WODConstants getCachedImageForKey:[textView.cacheKey stringByAppendingString:@"_bak"]] forKey:textView.cacheKey];
}

- (void)initContent
{
	__weak typeof(self) wSelf = self;
	dispatch_async(dispatch_get_main_queue(), ^{
		[self.openGLESStageView setBackgroundImage:wSelf.image];
		[self.openGLESStageView addTextView:wSelf.textView];
		[self.openGLESStageView setGrayoutBackground:YES];
	});
}

#pragma mark - gesture handler
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    // Begin transformations
    [self.textView.transformEngine start];
}

- (void)pan:(UIPanGestureRecognizer *)sender
{
    // Pan (1 Finger)
    if((sender.numberOfTouches == 1) &&
	   ((self.textView.transformEngine.state == S_NEW) || (self.textView.transformEngine.state == S_TRANSLATION)))
    {
        CGPoint translation = [sender translationInView:sender.view];
        float x = translation.x/sender.view.frame.size.width;
        float y = translation.y/sender.view.frame.size.height;
        [self.textView.transformEngine translate:GLKVector2Make(x, y) withMultiplier:1.0f];
		[self.openGLESStageView updateTextViewTransform:self.textView];
    }
    
    // Pan (2 Fingers)
    else if((sender.numberOfTouches == 2) &&
			((self.textView.transformEngine.state == S_NEW) || (self.textView.transformEngine.state == S_ROTATION)))
    {
        const float m = GLKMathDegreesToRadians(0.5f);
        CGPoint rotation = [sender translationInView:sender.view];
        [self.textView.transformEngine rotate:GLKVector3Make(rotation.x, rotation.y, 0.0f) withMultiplier:m];
		[self.openGLESStageView updateTextViewTransform:self.textView];
    }
	
	if(sender.state == UIGestureRecognizerStateBegan)
	{
		[self startPreview];
	}
	else if((sender.state == UIGestureRecognizerStateEnded)||(sender.state == UIGestureRecognizerStateCancelled))
	{
		[self stopPreview];
	}
	
}

- (void)pinch:(UIPinchGestureRecognizer *)sender
{
    // Pinch
    if((self.textView.transformEngine.state == S_NEW) || (self.textView.transformEngine.state == S_SCALE)|| (self.textView.transformEngine.state == S_ROTATION))
    {
        float scale = [sender scale];
        [self.textView.transformEngine scale:scale];
		[self.openGLESStageView updateTextViewTransform:self.textView];
    }
}

- (void)rotation:(UIRotationGestureRecognizer *)sender
{
    // Rotation
    if((self.textView.transformEngine.state == S_NEW) || (self.textView.transformEngine.state == S_ROTATION)|| (self.textView.transformEngine.state == S_SCALE))
    {
        float rotation = [sender rotation];
        [self.textView.transformEngine rotate:GLKVector3Make(0.0f, 0.0f, rotation) withMultiplier:1.0f];
		[self.openGLESStageView updateTextViewTransform:self.textView];
    }
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
	// if the gesture recognizers are on different views, don't allow simultaneous recognition
	if (gestureRecognizer.view != otherGestureRecognizer.view)    return NO;// if either of the gesture recognizers is the long press, don't allow simultaneous recognition
	if ([gestureRecognizer isKindOfClass:[UIPanGestureRecognizer class]] || [otherGestureRecognizer isKindOfClass:[UIPanGestureRecognizer class]])
		return NO;
	
	return YES;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
	CGPoint point = [touch locationInView:gestureRecognizer.view];
	if (CGRectContainsPoint(self.toolbar.frame, point))
		return NO;
	else
		return YES;
}

@end
