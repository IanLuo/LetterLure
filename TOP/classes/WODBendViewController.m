//
//  WODBendViewController.m
//  TOP
//
//  Created by ianluo on 13-12-12.
//  Copyright (c) 2013年 WOD. All rights reserved.
//

#import "WODBendViewController.h"
#import "WODButton.h"
#import "WODSlider.h"
#import "WODBendLayout.h"

@interface WODBendViewController ()

@property (nonatomic, strong)WODSlider * bendSlider;
@property (nonatomic, strong)WODButton * resetButton;
@property (nonatomic, strong)WODBendLayout * bendLayout;
@property (nonatomic, strong)UILabel * bendValueLabel;
@property (nonatomic, strong)NSTimer * timer;
@property (nonatomic, assign)float bendValue;

@end

@implementation WODBendViewController

- (void)dealloc
{
#ifdef DEBUGMODE
	NSLog(@"deallocing... %@",[[NSString stringWithUTF8String:__FILE__]lastPathComponent]);
#endif
}

- (WODBendLayout *)bendLayout
{
	if (_bendLayout == nil)
	{
		_bendLayout = [WODBendLayout new];
		_bendLayout.bendAngle = self.bendSlider.value;
	}
	return _bendLayout;
}

- (UILabel *)bendValueLabel
{
	if (!_bendValueLabel)
	{
		_bendValueLabel = [UILabel new];
		_bendValueLabel.backgroundColor = [WODConstants.COLOR_CONTROLLER_HIGHTLIGHT colorWithAlphaComponent:0.7];
		_bendValueLabel.textColor = WODConstants.COLOR_TEXT_TITLE;
		_bendValueLabel.font = [UIFont boldFlatFontOfSize:16];
		_bendValueLabel.layer.borderWidth = 1.0;
		_bendValueLabel.layer.borderColor = WODConstants.COLOR_LINE_COLOR.CGColor;
		_bendValueLabel.textAlignment = NSTextAlignmentCenter;
	}
	return _bendValueLabel;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
	
	[self setTitle:NSLocalizedString(@"VC_TITLE_TYPESETTER_BEND", nil)];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
	
	if([self.timer isValid])
	{
		[self.timer invalidate];
	}
}

- (void)viewDidLayoutSubviews
{
	if(self.textView.layoutProvider == nil || ![self.textView.layoutProvider isKindOfClass:[WODBendLayout class]])
	{
		self.textView.layoutProvider = self.bendLayout;
	}
	else
	{
		self.bendSlider.value = [(WODBendLayout *)self.textView.layoutProvider bendAngle];
	}
	
	self.textView.currentTypeSet = TypesetLayoutProvider;

	[super viewDidLayoutSubviews];
}

//overwirte superclass function
- (void)setupToolbar
{
	_bendSlider = [WODSlider new];
	_bendSlider.translatesAutoresizingMaskIntoConstraints = NO;
	[self.bendSlider setMinimumValue:-360.0];
	[self.bendSlider setMaximumValue:360.0];
	[self.bendSlider setValue:0.0];
	[self.bendSlider addTarget:self action:@selector(bendAngleChanged:) forControlEvents:UIControlEventValueChanged];
	[self.bendSlider addTarget:self action:@selector(bendAngleChangeComplete:) forControlEvents:UIControlEventTouchUpInside];
	[self.bendSlider addTarget:self action:@selector(bendAngleChangeComplete:) forControlEvents:UIControlEventTouchDown];

	[self.bendSlider addTarget:self action:@selector(bendAngleChangeBegin:) forControlEvents:UIControlEventTouchDown];
	
	_resetButton = [WODButton new];
	[self.resetButton setImage:[[UIImage imageNamed:@"bend_reset.png"]imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
	self.resetButton.translatesAutoresizingMaskIntoConstraints = NO;
	[self.resetButton setSelected:NO];
	[self.resetButton addTarget:self action:@selector(resetBendAngle) forControlEvents:UIControlEventTouchUpInside];
	
	[self.toolbar addSubview:self.bendSlider];
	[self.toolbar addSubview:self.resetButton];
}

//overwrite supper class function
- (void)layoutMoreViews
{
	UIInterfaceOrientation toInterfaceOrientation = [[UIApplication sharedApplication]statusBarOrientation];
	float itemHeight = 40;
	float buttonHeight = 40;
	float insect = 5;
	
	if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
	{
		itemHeight = toInterfaceOrientation == UIInterfaceOrientationPortrait || toInterfaceOrientation == UIInterfaceOrientationPortraitUpsideDown ? 40 : 26;
		insect = toInterfaceOrientation == UIInterfaceOrientationPortrait || toInterfaceOrientation == UIInterfaceOrientationPortraitUpsideDown ? 5 : 2;
		buttonHeight = toInterfaceOrientation == UIInterfaceOrientationPortrait || toInterfaceOrientation == UIInterfaceOrientationPortraitUpsideDown ? 40 : 26;
	}
	
	float resetButtonWidth = buttonHeight;
	
	[self.toolbar addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|-[slider]-20-[resetButton(resetButtonWidth)]-|" options:0 metrics:@{@"resetButtonWidth":@(resetButtonWidth)} views:@{@"slider":self.bendSlider,@"resetButton":self.resetButton}]];
	[self.toolbar addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-insect-[slider(hight)]-insect-|" options:0 metrics:@{@"hight":@(itemHeight),@"insect":@(insect)} views:@{@"slider":self.bendSlider,@"resetButton":self.resetButton}]];
	[self.toolbar addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-insect-[resetButton(hight)]-insect-|" options:0 metrics:@{@"hight":@(itemHeight),@"insect":@(insect)} views:@{@"slider":self.bendSlider,@"resetButton":self.resetButton}]];
}

- (void)resetBendAngle
{
	self.bendSlider.value = 0;
	self.bendValue = 0.0;
	[self applyBend];
}

- (void)bendAngleChangeBegin:(WODSlider *)bendSlider
{
	if([self.timer isValid])
	{
		[self.timer invalidate];
	}
	
	self.timer = [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(applyBend) userInfo:nil repeats:YES];
}

- (void)bendAngleChanged:(WODSlider *)bendSlider
{
	WODBendLayout * bendLayout = (WODBendLayout *)self.textView.layoutProvider;
	[bendLayout setBendAngle:bendSlider.value];
	
	self.bendValue = bendSlider.value;
	
	[self showSlideValueLabel:bendSlider.value];
}

- (void)showSlideValueLabel:(float)value
{
	self.bendValueLabel.center = self.view.center;
	self.bendValueLabel.bounds = CGRectMake(0, 0, 80, 80);
	self.bendValueLabel.text = [NSString stringWithFormat:@"%.0f °",value];
	self.bendValueLabel.layer.cornerRadius = self.bendValueLabel.bounds.size.width/2;
	self.bendValueLabel.layer.masksToBounds = YES;
	
	if (!self.bendValueLabel.superview)
	{
		[self.view addSubview:self.bendValueLabel];
	}
}

- (void)hideSlideValueLabel
{
	if (self.bendValueLabel.superview)
	{
		[self.bendValueLabel removeFromSuperview];
	}
}

- (void)applyBend
{
	[(WODBendLayout *)self.textView.layoutProvider setBendAngle:self.bendValue];
	self.textView.needGenerateImage = YES;
	[self.openGLESStageView updateTextViewImage:self.textView];
}

- (void)bendAngleChangeComplete:(WODSlider *)bendSlider
{
	[self hideSlideValueLabel];
	
	[self applyBend];
	
	if (self.timer.isValid)
	{
		[self.timer invalidate];
	}
}

@end
