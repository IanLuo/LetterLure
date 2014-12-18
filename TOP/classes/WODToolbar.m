//
//  WODToolbar.m
//  TOP
//
//  Created by ianluo on 13-12-20.
//  Copyright (c) 2013年 WOD. All rights reserved.
//

#import "WODToolbar.h"

@interface WODToolbar()<UIScrollViewDelegate>
{
	UIView * leftIndecator;
	UIView * rightIndecator;
}
@property (nonatomic,strong) UIScrollView * scrollView;

@end

@implementation WODToolbar

- (id)init
{
    self = [super init];
    if (self)
	{
		[self setTranslatesAutoresizingMaskIntoConstraints:NO];
		
		[self addSubview:self.scrollView];
		
		[[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(updateTheme) name:NOTIFICATION_THEME_CHANGED object:nil];
    }
    
    return self;
}

- (void)dealloc
{
    WODDebug(@"deallocing..");
    
	[[NSNotificationCenter defaultCenter]removeObserver:self];
}

- (void)updateTheme
{
	self.backgroundColor = color_black;
}

- (void)setItems:(NSArray *)items
{
	_items = items;
	
	if (self.scrollView.subviews)
	{
		for (UIView * sub in self.scrollView.subviews)
			[sub removeFromSuperview];
	}
	
	for (UIView * subView in self.items)
	{
		[self.scrollView addSubview:subView];
		subView.translatesAutoresizingMaskIntoConstraints = NO;
	}
	
	leftIndecator = [[UIView alloc]init];
	leftIndecator.translatesAutoresizingMaskIntoConstraints = NO;
	leftIndecator.backgroundColor = [[UIColor whiteColor]colorWithAlphaComponent:0.5];
	leftIndecator.alpha = 0.0;
	
	rightIndecator = [[UIView alloc]init];
	rightIndecator.translatesAutoresizingMaskIntoConstraints = NO;
	rightIndecator.backgroundColor = [[UIColor whiteColor]colorWithAlphaComponent:0.5];
	rightIndecator.alpha = 0.0;
	
	[self addSubview:leftIndecator];
	[self addSubview:rightIndecator];
	
	[self layoutIfNeeded];
}

- (void)layoutSubviews
{
	[super layoutSubviews];
	
	[self removeConstraints:[self constraints]];
	[self.scrollView removeConstraints:self.scrollView.constraints];
	
	[self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|[scrollView]|" options:0 metrics:nil views:@{@"scrollView":self.scrollView}]];
	[self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[scrollView]|" options:0 metrics:nil views:@{@"scrollView":self.scrollView}]];

	int seperatorWidth = 10;
	int itemWidth = ([WODConstants currentSize].width - seperatorWidth)/self.items.count - seperatorWidth;
	int totalWidth = seperatorWidth;
	int vOffset = 4;
	
	if (self.items.count > 0)
	{
		for (int i = 0; i < self.items.count - 1; i++)
		{
			UIView * subView = self.items[i];
			[self.scrollView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-leading-[subView(>=width)]" options:0 metrics:@{@"width":@(itemWidth),@"leading":@(totalWidth)} views:@{@"subView":subView}]];
			[self.scrollView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-vOffset-[subView(height)]-vOffset-|" options:NSLayoutFormatAlignAllCenterY metrics:@{@"height":@(self.viewHeight),@"vOffset":@(vOffset)} views:@{@"subView":subView}]];
			totalWidth += itemWidth + seperatorWidth;
		}
		
		UIView * lastItem = self.items[self.items.count - 1];
		[self.scrollView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-leading-[lastItem(>=width)]-seperatorWidth-|" options:0 metrics:@{@"width":@(itemWidth),@"leading":@(totalWidth),@"seperatorWidth":@(seperatorWidth)} views:@{@"lastItem":lastItem}]];
		[self.scrollView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-vOffset-[lastItem(height)]-vOffset-|" options:NSLayoutFormatAlignAllCenterY metrics:@{@"height":@(self.viewHeight),@"vOffset":@(vOffset)} views:@{@"lastItem":lastItem}]];
		totalWidth += itemWidth + seperatorWidth;
	}
	
	self.scrollView.scrollEnabled = NO;
	
	if (totalWidth > [WODConstants currentSize].width)
	{
		NSDictionary * items = NSDictionaryOfVariableBindings(leftIndecator,rightIndecator);
		[self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|[leftIndecator(5)]" options:0 metrics:nil views:items]];
		[self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"[rightIndecator(5)]|" options:0 metrics:nil views:items]];
		[self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[leftIndecator]|" options:NSLayoutFormatAlignAllLeft metrics:nil views:items]];
		[self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[rightIndecator]|" options:NSLayoutFormatAlignAllLeft metrics:nil views:items]];
		
		self.scrollView.scrollEnabled = YES;
	}
	
	[super layoutSubviews];
}

- (void)checkItemsIndecator
{
	UIButton * firstItem = self.items[0];
	UIButton * lastItem = self.items[self.items.count - 1];
	
	BOOL showLeft = self.scrollView.contentOffset.x > firstItem.bounds.size.width / 2;
	BOOL showRight = self.scrollView.contentOffset.x < self.scrollView.contentSize.width - lastItem.bounds.size.width / 2 - self.bounds.size.width;
	
	[UIView animateWithDuration:0.5 animations:^{
		leftIndecator.alpha = showLeft;
		rightIndecator.alpha = showRight;
	}];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
	[self checkItemsIndecator];
}

#pragma mark - getter

- (UIScrollView *)scrollView
{
    if (!_scrollView)
    {
        _scrollView = [[UIScrollView alloc]init];
        [self.scrollView setTranslatesAutoresizingMaskIntoConstraints:NO];
    }
    
    return _scrollView;
}
@end
