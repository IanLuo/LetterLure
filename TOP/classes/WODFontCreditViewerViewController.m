//
//  WODFontCreditViewerViewController.m
//  TOP
//
//  Created by ianluo on 14-4-24.
//  Copyright (c) 2014年 WOD. All rights reserved.
//

#import "WODFontCreditViewerViewController.h"
#import "WODFontManager.h"
#import <CoreText/CoreText.h>

@interface WODFontCreditViewerViewController ()

@property (nonatomic, strong)WODFontManager * fontManager;
@property (nonatomic, strong)NSAttributedString * creditString;
@property (nonatomic, strong)UITextView * infoView;

@end

@implementation WODFontCreditViewerViewController
- (WODFontManager *)fontManager
{
	if (!_fontManager)
	{
		_fontManager = [WODFontManager new];
	}
	return _fontManager;
}

- (UITextView *)infoView
{
	if (!_infoView)
	{
		_infoView = [[UITextView alloc]initWithFrame:self.view.bounds];
		[_infoView setShowsHorizontalScrollIndicator:NO];
		[_infoView setAlwaysBounceHorizontal:NO];
		_infoView.backgroundColor = WODConstants.COLOR_VIEW_BACKGROUND;
		_infoView.attributedText = self.creditString;
		_infoView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
		[_infoView setEditable:NO];
	}
	return _infoView;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	
	[self.view addSubview:self.infoView];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setFontName:(NSString *)fontName
{
	_fontName = fontName;
	
	self.title = fontName;
	
	NSString * credit = [self.fontManager getExtroFontCredit:fontName];
	UIFont *font = [UIFont fontWithName:fontName size:20];
	
	if (credit)
	{
		self.creditString = [[NSAttributedString alloc]initWithString:credit
		attributes:@{NSFontAttributeName:font, NSForegroundColorAttributeName:WODConstants.COLOR_TEXT_CONTENT}];
	}
}
@end
