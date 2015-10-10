//
//  WODFreeDrawViewController.m
//  TOP
//
//  Created by ianluo on 13-12-12.
//  Copyright (c) 2013年 WOD. All rights reserved.
//

#import "WODFreeDrawViewController.h"
#import "WODButton.h"
#import "WODDrawFreeLineView.h"
#import "WODDrawDotLineView.h"
#import "WODFreeLayout.h"
#import "UIImage+Generate.h"

@interface WODFreeDrawViewController ()<WODPathDrawViewDelegate>

@property (nonatomic, strong)WODButton * freeDrawButton;
@property (nonatomic, strong)WODButton * dotDrawButton;
@property (nonatomic, strong)WODFreeLayout * freeLayout;
@property (nonatomic, strong)WODPathDrawView * currentPathDrawView;
@end

@implementation WODFreeDrawViewController

- (WODFreeLayout *)freeLayout
{
	if (_freeLayout == nil)
	{
		_freeLayout = [WODFreeLayout new];
	}
	return _freeLayout;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
	
	[self setTitle:NSLocalizedString(@"VC_TITLE_TYPESETTER_FREE_DRAW", nil)];
	
	[self addObserver:self forKeyPath:@"drawMode" options:NSKeyValueObservingOptionNew context:nil];
	
	self.shouldIgnorGestures = NO;
}

- (void)dealloc
{
	[self removeObserver:self forKeyPath:@"drawMode"];
	
#ifdef DEBUGMODE
	NSLog(@"deallocing... %@",[[NSString stringWithUTF8String:__FILE__]lastPathComponent]);
#endif
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidAppear:(BOOL)animated
{
	if(self.textView.layoutProvider == nil || ![self.textView.layoutProvider isKindOfClass:[WODFreeLayout class]])
	{
		self.textView.layoutProvider = self.freeLayout;
	}
	
	self.textView.currentTypeSet = TypesetLayoutProvider;
	
	[self startDrawFreeLine:self.freeDrawButton];
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
	[self layout];
}

//overwite superclass function
- (void)setupToolbar
{
	_freeDrawButton = [WODButton new];
	[self.freeDrawButton setImage:[[UIImage imageNamed:@"typesetter_freedraw.png"]imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
	self.freeDrawButton.translatesAutoresizingMaskIntoConstraints = NO;
	[self.freeDrawButton addTarget:self action:@selector(startDrawFreeLine:) forControlEvents:UIControlEventTouchUpInside];
	
	_dotDrawButton = [WODButton new];
	[self.dotDrawButton setImage:[[UIImage imageNamed:@"typesetter_dotdraw.png"]imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
	self.dotDrawButton.translatesAutoresizingMaskIntoConstraints = NO;
	[self.dotDrawButton addTarget:self action:@selector(startDrawDotLine:) forControlEvents:UIControlEventTouchUpInside];
	
	[self.toolbar addSubview:self.dotDrawButton];
	[self.toolbar addSubview:self.freeDrawButton];
}

//overwrite superclass function
- (void)layoutMoreViews
{
	NSDictionary * views = @{@"freeDrawButton":self.freeDrawButton,@"dotDrawButton":self.dotDrawButton};
	
	UIInterfaceOrientation toInterfaceOrientation = [[UIApplication sharedApplication]statusBarOrientation];
	CGFloat itemHeight = 40;
	int insect = 5;
	
	if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
	{
		itemHeight = toInterfaceOrientation == UIInterfaceOrientationPortrait || toInterfaceOrientation == UIInterfaceOrientationPortraitUpsideDown ? 40 : 26;
		insect = toInterfaceOrientation == UIInterfaceOrientationPortrait || toInterfaceOrientation == UIInterfaceOrientationPortraitUpsideDown ? 5 : 2;
	}
	
	[self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|-insect-[freeDrawButton(dotDrawButton)]-[dotDrawButton]-insect-|" options:0 metrics:@{@"insect":@(insect)} views:views]];
	[self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-insect-[freeDrawButton]-insect-|" options:0 metrics:@{@"itemHeight":@(itemHeight),@"insect":@(insect)} views:views]];
	[self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-insect-[dotDrawButton]-insect-|" options:0 metrics:@{@"itemHeight":@(itemHeight),@"insect":@(insect)} views:views]];
}

- (void)startDrawFreeLine:(WODButton *)button
{
	[self clearLastDrawView];
			
	WODDrawFreeLineView * freeDrawView = [[WODDrawFreeLineView alloc]initWithFrame:self.openGLESStageView.frame];
	[freeDrawView setDelegate:self];
	freeDrawView.stringLength = self.textView.text.length;
	self.currentPathDrawView = freeDrawView;
	
	[self.view addSubview:freeDrawView];
	self.shouldIgnorGestures = YES;
    
    self.freeDrawButton.backgroundColor = color_gray;
}

- (void)startDrawDotLine:(WODButton *)button
{
	[self clearLastDrawView];
	
		
	WODDrawDotLineView * dotDrawView = [[WODDrawDotLineView alloc]initWithFrame:self.openGLESStageView.frame];
	[dotDrawView setDelegate:self];
	dotDrawView.stringLength = self.textView.text.length;
	self.currentPathDrawView = dotDrawView;
	
	[self.view addSubview:dotDrawView];
	self.shouldIgnorGestures = YES;
    
    self.dotDrawButton.backgroundColor = color_gray;
}

- (void)clearLastDrawView
{
	self.freeDrawButton.backgroundColor = color_black;
	self.dotDrawButton.backgroundColor = color_black;

	if (self.currentPathDrawView && self.currentPathDrawView.superview)
	{
		[self.currentPathDrawView removeFromSuperview];
		self.currentPathDrawView = nil;
		self.shouldIgnorGestures = NO;
	}
}

#pragma mark - path draw view delegate

- (void)didFinishdDrawingPathWithPoints:(NSArray *)points drawView:(WODPathDrawView *)drawView
{
	[self clearLastDrawView];
		
	[(WODFreeLayout *)self.textView.layoutProvider setAllPoints:[NSArray arrayWithArray:points]];
		
	[self.textView restoreShape];
	[self.textView setCurrentTypeSet:TypesetLayoutProvider];

	[self.textView setFrame:self.openGLESStageView.bounds];
	
	[self.textView.transformEngine restore];
	[self.openGLESStageView updateTextViewTransform:self.textView];
	
	self.textView.needGenerateImage = YES;
	[self.openGLESStageView updateTextViewImage:self.textView];
}

- (CGFloat)getAngleForPointAt:(NSUInteger)index allPoints:(NSArray *)points
{
	NSUInteger pointsCount = points.count;
	CGFloat x1,x2,y1,y2;
	CGPoint lastPoint, nextPoint;
	if (index == 0)
	{
		lastPoint = [(NSValue *)points[index] CGPointValue];
		nextPoint = [(NSValue *)points[index + 1] CGPointValue];
	}
	else if(index == pointsCount - 1)
	{
		lastPoint = [(NSValue *)points[index - 1] CGPointValue];
		nextPoint = [(NSValue *)points[index] CGPointValue];
	}
	else
	{
		lastPoint = [(NSValue *)points[index - 1] CGPointValue];
		nextPoint = [(NSValue *)points[index + 1] CGPointValue];
	}
	x1 = lastPoint.x;
	y1 = lastPoint.y;
	x2 = nextPoint.x;
	y2 = nextPoint.y;
	
	return atan2((y2 - y1),(x2 - x1));
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
	return !self.shouldIgnorGestures;
}

@end
