//
//  WODScrollTab.m
//  TOP
//
//  Created by ianluo on 13-12-13.
//  Copyright (c) 2013年 WOD. All rights reserved.
//

#import "WODScrollTab.h"
#import <QuartzCore/QuartzCore.h>

#define BUTTON_BOUNDS_NORMAL CGRectMake(0,0,100,50)

@interface WODScrollTab()<UIScrollViewDelegate>
{
	void (^selectionBlock)(id key,NSInteger index);
	
	NSInteger selectIndex;
	NSInteger lastSelectIndex;
	
	UIImageView * leftIndecator;
	UIImageView * rightIndecator;
}

@property (nonatomic,strong) UIScrollView * scrollView;

@end

@implementation WODScrollTab

- (id)init
{
    self = [super init];
    if (self)
	{
		_scrollView = [[UIScrollView alloc]init];
		self.scrollView.delegate = self;
		self.scrollView.translatesAutoresizingMaskIntoConstraints = NO;
		[self addSubview:self.scrollView];
		
		self.backgroundColor = WODConstants.COLOR_TAB_BACKGROUND;
		
		leftIndecator = [[UIImageView alloc]init];
		leftIndecator.translatesAutoresizingMaskIntoConstraints = NO;
		leftIndecator.tintColor = WODConstants.COLOR_CONTROLLER;
		leftIndecator.contentMode = UIViewContentModeScaleAspectFit;
		leftIndecator.image = [[UIImage imageNamed:@"arrow_left2"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
		
		rightIndecator = [[UIImageView alloc]init];
		rightIndecator.translatesAutoresizingMaskIntoConstraints = NO;
		rightIndecator.tintColor = WODConstants.COLOR_CONTROLLER;
		rightIndecator.contentMode = UIViewContentModeScaleAspectFit;
		rightIndecator.image = [[UIImage imageNamed:@"arrow_right2"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
		
		[self addSubview:leftIndecator];
		[self addSubview:rightIndecator];
    }
    return self;
}

- (void)dealloc
{
	for (UIView * item in self.items)
	{
		[item removeObserver:self forKeyPath:@"selected"];
	}
	
#ifdef DEBUGMODE
	NSLog(@"(%@,%i):deallocing...",[[NSString stringWithUTF8String:__FILE__]lastPathComponent],__LINE__);
#endif
}

- (void)initScrollTabWithItems:(NSArray *)items selection:(void(^)(id key,NSInteger index))block
{
	selectionBlock = block;
	
	[self setItems:items];

	[self createButtons:items];
}

- (void)layoutSubviews
{
	[super layoutSubviews];
	
	[self removeConstraints:[self constraints]];
	[self.scrollView removeConstraints:self.scrollView.constraints];
	
	[self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|-5-[scrollView]-5-|" options:0 metrics:nil views:@{@"scrollView":self.scrollView}]];
	[self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[scrollView]|" options:0 metrics:nil views:@{@"scrollView":self.scrollView}]];
	
	float totalWidth = 0.0;
	float itemWidth = BUTTON_BOUNDS_NORMAL.size.width;
	
	if (self.items.count > 0)
	{
		for (int i = 0; i < self.items.count - 1; i++)
		{
			UIView * subView = self.items[i];
			[self.scrollView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-leading-[subView(>=width)]" options:0 metrics:@{@"width":@(itemWidth),@"leading":@(totalWidth)} views:@{@"subView":subView}]];
			[self.scrollView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-2-[subView(height)]-2-|" options:NSLayoutFormatAlignAllCenterY metrics:@{@"height":@(46)} views:@{@"subView":subView}]];
			totalWidth += itemWidth;
		}
		
		UIView * lastItem = self.items[self.items.count - 1];
		[self.scrollView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-leading-[lastItem(>=width)]|" options:0 metrics:@{@"width":@(itemWidth),@"leading":@(totalWidth)} views:@{@"lastItem":lastItem}]];
		[self.scrollView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-2-[lastItem(height)]-2-|" options:NSLayoutFormatAlignAllCenterY metrics:@{@"height":@(46)} views:@{@"lastItem":lastItem}]];
		totalWidth += itemWidth;
	}
	
	self.scrollView.scrollEnabled = NO;
	
	if (totalWidth > BUTTON_BOUNDS_NORMAL.size.width)
	{
		NSDictionary * items = NSDictionaryOfVariableBindings(leftIndecator,rightIndecator);
		[self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|[leftIndecator(5)]" options:0 metrics:nil views:items]];
		[self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"[rightIndecator(5)]|" options:0 metrics:nil views:items]];
		[self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[leftIndecator]|" options:NSLayoutFormatAlignAllLeft metrics:nil views:items]];
		[self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[rightIndecator]|" options:NSLayoutFormatAlignAllRight metrics:nil views:items]];
		
		self.scrollView.scrollEnabled = YES;
	}
	
	[super layoutSubviews];
	
	[self checkItemsIndecator];
}

- (void)setItems:(NSArray *)items
{
	_items = items;
	
	for (UIView * subView in _items)
	{
		subView.translatesAutoresizingMaskIntoConstraints = NO;
		[subView addObserver:self forKeyPath:@"selected" options:NSKeyValueObservingOptionNew context:nil];
		[self.scrollView addSubview:subView];
	}
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
	if ([keyPath isEqualToString:@"selected"])
	{
		UIButton * button = (UIButton *)object;
		if (button.isSelected)
		{
//			[(UIButton *)object setBackgroundColor:COLOR_NAV_BAR];
		}
		else
		{
//			[(UIButton *)object setBackgroundColor:[UIColor clearColor]];
		}
	}
}


- (NSInteger)currentIndex
{
	return selectIndex;
}

- (id)keyForIndex:(NSInteger)index
{
	if (self.items.count > index)
		return [(UIButton *)[self.items objectAtIndex:index] titleLabel].text;
	else
		return nil;
}

- (void)setSelectAtIndex:(NSInteger)index animationComplete:(void(^)())block
{
	lastSelectIndex = selectIndex;
	selectIndex = index;
	
	for (int i = 0; i< self.items.count; i++)
	{
		UIButton * item = (UIButton *)self.items[i];
		[item setSelected:i==index];
		
//		item.titleLabel.font = [UIFont fontWithName:FONT_NAME_LABEL size:item.isSelected ? 18:12];
		if (item.isSelected)
		{
			item.titleLabel.font = [UIFont flatFontOfSize:item.isSelected ? 14:12];
			item.backgroundColor = WODConstants.COLOR_CONTROLLER_HIGHTLIGHT;
			[self scrollRectToCenter:item.frame animated:YES];
		}
		if (i == lastSelectIndex)
		{
			item.titleLabel.font = [UIFont flatFontOfSize:item.isSelected ? 14:12];
			item.backgroundColor = WODConstants.COLOR_TOOLBAR_BACKGROUND;
		}
		
//		[UIView animateWithDuration:0.3 animations:^{
//			if (item.isSelected || i == lastSelectIndex)
//			{
//				[UIView animateWithDuration:0.3 animations:^{
//					item.titleLabel.transform = CGAffineTransformIdentity;
//				} completion:^(BOOL finished) {
					if (block)
					{
						block();
					}
//				}];
//			}
//		}];
	}
	
	[self checkItemsIndecator];
}

- (void)scrollRectToCenter:(CGRect)visibleRect animated:(BOOL)animated
{
	CGRect centeredRect = CGRectMake(visibleRect.origin.x + visibleRect.size.width/2.0 - self.frame.size.width/2.0 ,
									 visibleRect.origin.y + visibleRect.size.height/2.0 - self.frame.size.height/2.0,
									 self.frame.size.width,
									 self.frame.size.height);
	[self.scrollView scrollRectToVisible:centeredRect
					 animated:animated];
}

- (void)createButtons:(NSArray *)items
{
	for (int i = 0; i< items.count; i++)
	{
		UIButton * item = (UIButton *)items[i];
		[item setSelected:i==0];
		item.tag = i;
		[item addTarget:self action:@selector(buttonTouched:) forControlEvents:UIControlEventTouchUpInside];
		item.titleLabel.font = [UIFont fontWithName:@"HelveticaNeue-UltraLight" size:item.isSelected ? 18:10];
		item.titleLabel.textColor = WODConstants.COLOR_TEXT_TITLE;
		
		item.layer.cornerRadius = 5;
		item.layer.masksToBounds = YES;
				
		[self.scrollView addSubview:item];
	}
	
	lastSelectIndex = 0;
	selectIndex = 0;
	
	[self layoutIfNeeded];
}

- (void)buttonTouched:(UIButton *)sender
{
	if (sender.tag != self.currentIndex)
	{
		[self setSelectAtIndex:sender.tag animationComplete:^{
		}];
		selectionBlock(sender.titleLabel.text,sender.tag);
	}
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
@end
