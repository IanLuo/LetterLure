//
//  WODShapeViewController.m
//  TOP
//
//  Created by ianluo on 13-12-12.
//  Copyright (c) 2013年 WOD. All rights reserved.
//

#import "WODShapeViewController.h"
#import "WODButton.h"
#import "WODSlider.h"
#import "WODSimpleScrollItemPicker.h"
#import "WODPathDrawView.h"
#import "WODDrawFreeLineView.h"
#import "WODDrawDotLineView.h"
#import "WODShapePatchCollection.h"

@interface WODShapeViewController ()<WODPathDrawViewDelegate>

@property (nonatomic, strong)WODButton * chooseShapeButton;
@property (nonatomic, strong)WODButton * chooseFillButton;
@property (nonatomic, strong)WODSlider * sizeSlider;
@property (nonatomic, assign)float sizeValue;
@property (nonatomic, strong)NSTimer * timer;

@property (nonatomic, strong)UIView * currentPathDrawView;

@property (nonatomic, strong)WODSimpleScrollItemPicker * shapePicker;
@property (nonatomic, strong)WODSimpleScrollItemPicker * fillPicker;

@end

@interface WODShapeViewController()

@property (nonatomic, strong)WODShapePatchCollection * pathCollection;

@end

@implementation WODShapeViewController

- (void)dealloc
{
#ifdef DEBUGMODE
	NSLog(@"deallocing... %@",[[NSString stringWithUTF8String:__FILE__]lastPathComponent]);
#endif
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
	
	[self setTitle:NSLocalizedString(@"VC_TITLE_TYPESETTER_SHAPE", nil)];
}

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
	[super viewDidAppear:animated];
	 
	self.textView.shouldShowPath = YES;
	
	[self chooseShape:nil];
}

- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
	
	if([self.timer isValid])
	{
		[self.timer invalidate];
	}
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - layout

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
	[self layout];
}

//overwrite superclass function
- (void)setupToolbar
{
	_chooseShapeButton = [WODButton new];
	[self.chooseShapeButton setImage:[[UIImage imageNamed:@"arrow_up"]imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
	[self.chooseShapeButton setTranslatesAutoresizingMaskIntoConstraints:NO];
	[self.chooseShapeButton addTarget:self action:@selector(chooseShape:) forControlEvents:UIControlEventTouchUpInside];
	
//	_chooseFillButton = [WODButton new];
//	[self.chooseFillButton setTitle:@"Fill" forState:UIControlStateNormal];
//	[self.chooseFillButton setTranslatesAutoresizingMaskIntoConstraints:NO];
//	[self.chooseFillButton showBorder:YES];
//	[self.chooseFillButton addTarget:self action:@selector(chooseFill:) forControlEvents:UIControlEventTouchUpInside];
	
	_sizeSlider = [WODSlider new];
	[self.sizeSlider setMaximumValue:3.0];
	[self.sizeSlider setMinimumValue:0.5];
	[self.sizeSlider setTranslatesAutoresizingMaskIntoConstraints:NO];
	[self.sizeSlider addTarget:self action:@selector(shapeSizeChanged:) forControlEvents:UIControlEventValueChanged];
	[self.sizeSlider addTarget:self action:@selector(shapeSizeChangeComplete:) forControlEvents:UIControlEventTouchUpInside];
	[self.sizeSlider addTarget:self action:@selector(shapeSizeChangeComplete:) forControlEvents:UIControlEventTouchUpOutside];
	[self.sizeSlider addTarget:self action:@selector(shapeSizeBegin:) forControlEvents:UIControlEventTouchDown];
	
	[self.toolbar addSubview:self.chooseShapeButton];
//	[self.toolbar addSubview:self.chooseFillButton];
	[self.toolbar addSubview:self.sizeSlider];
	
}

//overwrite superclass function
- (void)layoutMoreViews
{
	UIInterfaceOrientation toInterfaceOrientation = [[UIApplication sharedApplication]statusBarOrientation];
	CGFloat itemSize = 40;
	CGFloat insect = 5;
	CGFloat buttonHeight = 40;
	
	if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
	{
		itemSize = toInterfaceOrientation == UIInterfaceOrientationPortrait || toInterfaceOrientation == UIInterfaceOrientationPortraitUpsideDown ? 40 : 26;
		insect = toInterfaceOrientation == UIInterfaceOrientationPortrait || toInterfaceOrientation == UIInterfaceOrientationPortraitUpsideDown ? 5 : 2;
		buttonHeight = toInterfaceOrientation == UIInterfaceOrientationPortrait || toInterfaceOrientation == UIInterfaceOrientationPortraitUpsideDown ? 40 : 26;
	}
	
	NSDictionary * items = @{@"shapeButton":self.chooseShapeButton,@"slider":self.sizeSlider};
	
	[self.toolbar addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|-insect-[shapeButton(buttonHeight)]-[slider]-insect-|" options:0 metrics:@{@"buttonHeight":@(buttonHeight),@"insect":@(insect)} views:items]];
	[self.toolbar addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-insect-[shapeButton(buttonHeight)]-insect-|" options:0 metrics:@{@"buttonHeight":@(buttonHeight),@"insect":@(insect)} views:items]];
//	[self.toolbar addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-insect-[fillButton]-insect-|" options:0 metrics:@{@"insect":@(insect)} views:items]];
	[self.toolbar addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-insect-[slider]-insect-|" options:0 metrics:@{@"insect":@(insect)} views:items]];
}

#pragma mark - actions

- (WODSimpleScrollItemPicker *)shapePicker
{
	if(!_shapePicker)
	{
		_shapePicker = [WODSimpleScrollItemPicker new];
		UIImageView * freeDrawImageView = [[UIImageView alloc]initWithImage:[[UIImage imageNamed:@"typesetter_freedraw.png"]imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate]];
		[freeDrawImageView setContentMode:UIViewContentModeCenter];
		[_shapePicker addItemWithView:freeDrawImageView];
		
		UIImageView * dotDrawImageView = [[UIImageView alloc]initWithImage:[[UIImage imageNamed:@"typesetter_dotdraw.png"]imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate]];
		[dotDrawImageView setContentMode:UIViewContentModeCenter];
		[_shapePicker addItemWithView:dotDrawImageView];
						
		_shapePicker.position = BarPostionBotton;
		[_shapePicker setControlItemIndexs:@[@(0),@(1)]];
		
		_pathCollection = [WODShapePatchCollection new];
		NSDictionary * pathWithIconNames = [self.pathCollection allShapePathWithIconNames];
		for (NSString * pathKey in [self.pathCollection allShapePathKeys])
		{
			UIImageView * imageView = [[UIImageView alloc] initWithImage:[[UIImage imageNamed:[pathWithIconNames objectForKey:pathKey]]imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate]];
			[imageView setContentMode:UIViewContentModeCenter];
			[_shapePicker addItemWithView:imageView];
		}
	}
	
	return _shapePicker;
}

- (void)chooseShape:(UIButton *)button
{
	__weak WODSimpleScrollItemPicker * simpleScrollItemPicker = self.shapePicker;
	
	__weak WODShapeViewController * weakSelf = self;
	
	[simpleScrollItemPicker showFrom:self.view withSelection:^(WODSimpleScrollItemPickerItem *selectedItem)
	{
		if (selectedItem)
		{
			if (selectedItem.index == 0)
			{
				[weakSelf startDrawFreeLine];
				[simpleScrollItemPicker dismiss];
			}
			else if (selectedItem.index == 1)
			{
				[weakSelf startDrawDotLine];
				[simpleScrollItemPicker dismiss];
			}
			else
			{
				[weakSelf.sizeSlider setValue:1.0];
				UIBezierPath * path = [weakSelf.pathCollection pathWithKey:[self.pathCollection allShapePathKeys][selectedItem.index - 2] forRect:weakSelf.textView.bounds];
				[weakSelf.textView applyShapePath:path];
				
				[weakSelf.textView setNeedGenerateImage:YES];
				[weakSelf.openGLESStageView updateTextViewImage:weakSelf.textView];
			}
		}
		else// dismissed
		{
			[self.chooseShapeButton setImage:[[UIImage imageNamed:@"arrow_up"]imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
			[self.chooseShapeButton addTarget:self action:@selector(chooseShape:) forControlEvents:UIControlEventTouchUpInside];
		}

	}];
	
	[self.view bringSubviewToFront:self.toolbar];
	[self.chooseShapeButton setImage:[[UIImage imageNamed:@"arrow_down"]imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
	[self.chooseShapeButton addTarget:self action:@selector(dismissChooseShape) forControlEvents:UIControlEventTouchUpInside];
}

- (void)dismissChooseShape
{
	[self.shapePicker dismiss];
}

- (WODSimpleScrollItemPicker *)fillPicker
{
	if (!_fillPicker)
	{
		_fillPicker = [WODSimpleScrollItemPicker new];
		[_fillPicker addItem:@"Transperant"];
		[_fillPicker addItem:@"Half"];
		[_fillPicker addItem:@"Opaque"];
		[_fillPicker addItem:@"Stroke"];
		
		_fillPicker.contentSizeShortSide = 50;
		_fillPicker.itemOffset = 5;
		
		if (UI_USER_INTERFACE_IDIOM()==UIUserInterfaceIdiomPad)
		{
			_fillPicker.position = BarPostionRight;
		}
		else
		{
			_fillPicker.position = BarPostionBotton|BarPostionRight;
		}
		
		[_fillPicker setControlItemIndexs:@[@(0),@(1),@(2),@(3)]];
		
		for (float i = 1.0; i < 100.0; i++)
		{
			float r = arc4random() % 256;
			float g = arc4random() % 256;
			float b = arc4random() % 256;
			
			UIView * colorView = [UIView new];
			colorView.backgroundColor = [UIColor colorWithRed:r/256.0 green:g/256.0 blue:b/256.0 alpha:1];
			
			[_fillPicker addItemWithView:colorView];
		}
	}
	return _fillPicker;
}

- (void)chooseFill:(WODButton *)button
{
//	__block WODSimpleScrollItemPicker * simpleScrollItemPicker = self.fillPicker;
//	
//	__block WODShapeViewController * weakSelf = self;
//	
//	[simpleScrollItemPicker showFrom:self.view withSelection:^(WODSimpleScrollItemPickerItem *selectedItem)
//	 {
//		 if (selectedItem)
//		 {
//			 if (selectedItem.index == 0)
//			 {
//				 weakSelf.textView.backgroundLayer.fillType = FillTypeTransparent;
//				 
//				 CGPathRef scaledPath = weakSelf.textView.createScaledPath;
//				 [weakSelf.textView.backgroundLayer fillBackgroundWithColor:weakSelf.textView.backgroundLayer.fillColor andPath:scaledPath];
//				 CGPathRelease(scaledPath);
//			 }
//			 else if (selectedItem.index == 1)
//			 {
//				 weakSelf.textView.backgroundLayer.fillType = FillTypeHalf;
//				 
//				 CGPathRef scaledPath = weakSelf.textView.createScaledPath;
//				 [weakSelf.textView.backgroundLayer fillBackgroundWithColor:weakSelf.textView.backgroundLayer.fillColor andPath:scaledPath];
//				 
//				 CGPathRelease(scaledPath);
//			 }
//			 else if (selectedItem.index == 2)
//			 {
//				 weakSelf.textView.backgroundLayer.fillType = FillTypeOpaque;
//				 
//				 CGPathRef scaledPath = weakSelf.textView.createScaledPath;
//				 [weakSelf.textView.backgroundLayer fillBackgroundWithColor:weakSelf.textView.backgroundLayer.fillColor andPath:scaledPath];
//				 
//				 CGPathRelease(scaledPath);
//			 }
//			 else if (selectedItem.index == 3)
//			 {
//				 weakSelf.textView.backgroundLayer.fillType = FillTypeStroke;
//				 
//				 CGPathRef scaledPath = weakSelf.textView.createScaledPath;
//				 [weakSelf.textView.backgroundLayer fillBackgroundWithColor:weakSelf.textView.backgroundLayer.fillColor andPath:scaledPath];
//				 
//				 CGPathRelease(scaledPath);
//			 }
//			 else
//			 {
//				 CGPathRef scaledPath = weakSelf.textView.createScaledPath;
//				 
//				 [weakSelf.textView.backgroundLayer fillBackgroundWithColor:selectedItem.customView.backgroundColor andPath:scaledPath];
//				 
//				 CGPathRelease(scaledPath);
//			 }
//		 }
//	 }];
}

- (void)applyShapeSize
{
	[self.textView setPathScaleFactor:self.sizeValue];
	[self.textView setNeedGenerateImage:YES];
	[self.openGLESStageView updateTextViewImage:self.textView];
}

- (void)shapeSizeBegin:(WODSlider *)slider
{
	self.sizeValue = slider.value;
	
	if (self.timer.isValid)
	{
		[self.timer invalidate];
	}
	
	self.timer = [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(applyShapeSize) userInfo:nil repeats:YES];
}

- (void)shapeSizeChanged:(WODSlider *)slider
{
	self.sizeValue = slider.value;
}

- (void)shapeSizeChangeComplete:(WODSlider *)slider
{
	[self applyShapeSize];
	
	if (self.timer.isValid)
	{
		[self.timer invalidate];
	}
}

#pragma mark - draw shape path

- (void)didFinishdDrawingPath:(UIBezierPath *)path drawView:(WODPathDrawView *)drawView
{
	[self.sizeSlider setValue:1.0];

	[self clearLastDrawView];
	
	[self.textView applyShapePath:path];
	
	[self.textView.transformEngine restore];
	[self.openGLESStageView updateTextViewTransform:self.textView];
	
	[self.textView setNeedGenerateImage:YES];
	[self.openGLESStageView updateTextViewImage:self.textView];
}

- (void)startDrawFreeLine
{
	[self clearLastDrawView];
	
	WODDrawFreeLineView * freeDrawView = [[WODDrawFreeLineView alloc]initWithFrame:self.openGLESStageView.frame];
	[freeDrawView setDelegate:self];
	freeDrawView.autoClosePath = YES;
	freeDrawView.stringLength = self.textView.text.length;
	
	self.currentPathDrawView = freeDrawView;
	
	[self.view addSubview:freeDrawView];
	
	[self setShouldIgnorGestures:YES];
}

- (void)startDrawDotLine
{
	[self clearLastDrawView];
	
	WODDrawDotLineView * dotDrawView = [[WODDrawDotLineView alloc]initWithFrame:self.openGLESStageView.frame];
	[dotDrawView setDelegate:self];
	dotDrawView.autoClosePath = YES;
	dotDrawView.stringLength = self.textView.text.length;
	self.currentPathDrawView = dotDrawView;
	
	[self.view addSubview:dotDrawView];
	[self setShouldIgnorGestures:YES];
}

- (void)clearLastDrawView
{
	if (self.currentPathDrawView && self.currentPathDrawView.superview)
	{
		[self.currentPathDrawView removeFromSuperview];
		self.currentPathDrawView = nil;
		[self setShouldIgnorGestures:NO];
	}
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
	if (self.shouldIgnorGestures)
	{
		return NO;
	}
	else
		return [super gestureRecognizer:gestureRecognizer shouldReceiveTouch:touch];
}

@end
