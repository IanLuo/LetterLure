//
//  WODActionSheet.m
//  TOP
//
//  Created by ianluo on 13-12-13.
//  Copyright (c) 2013年 WOD. All rights reserved.
//

#import "WODActionSheet.h"

@interface WODActionSheet()
{
	void (^action)(WODActionSheetItem * selectedItem);
	NSArray * actionSheetConstraints;
}

@property (nonatomic, strong)NSMutableDictionary * items;
@property (nonatomic, weak) UIView * parentView;
@property (nonatomic, strong) UIDynamicAnimator * animator;
@property (nonatomic, strong) UIView * backView;

@end

@implementation WODActionSheet
- (NSMutableDictionary *)items
{
	if (_items == nil)
	{
		_items = [NSMutableDictionary dictionary];
	}
	return _items;
}

- (id)init
{
    self = [super init];
    if (self) {
        // Initialization code
		[self addGestureRecognizer:[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(dismiss)]];
		[self setAutoresizingMask:UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth];
    }
    return self;
}

- (UIView *)backView
{
	if (!_backView)
	{
		_backView = [UIView new];
		[_backView setAutoresizingMask:UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleWidth];
		_backView.backgroundColor = color_black;
	}
	return _backView;
}

- (void)showFrom:(UIView *)view withSelection:(void (^)(WODActionSheetItem * selectedItems))block
{
	self.parentView = [view superview];
	
	self.frame = CGRectMake(0, 50, self.parentView.bounds.size.width, self.parentView.bounds.size.height);
	self.alpha = 0.0;
	[self.parentView addSubview:self];
	[self addSubview:self.backView];

	NSEnumerator * enumerator = [self.items keyEnumerator];
	NSString * key;
	NSInteger index = 0;
	while(key = [enumerator nextObject])
	{
		WODActionSheetItem * item = [WODActionSheetItem new];
		item.index = index ++;
		[item setTitle:key];
		[item setIcon:[self.items objectForKey:key]];
		[item addGestureRecognizer:[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(selected:)]];
		[self.backView addSubview:item];
	}
	
	[UIView animateWithDuration:0.25 delay:0.0 options:UIViewAnimationOptionCurveEaseOut animations:^{
		self.frame = self.parentView.bounds;
		self.alpha = 1.0;
	} completion:^(BOOL finished)
	{
		[self layoutItems];
		action = block;
	}];
}

- (void)dismiss
{
	[UIView animateWithDuration:0.25 delay:0.0 options:UIViewAnimationOptionCurveEaseOut animations:^{
		self.frame = CGRectMake(0, 50, self.parentView.bounds.size.width, self.parentView.bounds.size.height);
		self.alpha = 0.0;
	} completion:^(BOOL finished)
	 {
		 [self removeFromSuperview];
		 action(nil);
	 }];
}

- (void)layoutSubviews
{
	[super layoutSubviews];
	[self layoutItems];
}

- (void)selected:(UITapGestureRecognizer *)sender
{
	WODActionSheetItem * item = (WODActionSheetItem*)sender.view;
	action(item);
//	[self.parentView removeConstraints:actionSheetConstraints];
	[self removeFromSuperview];
}

- (void)layoutItems
{
	float width = self.bounds.size.width;
	int rows = self.items.count % 3 + 1;
	float height = rows * WODActionSheetItem.size.height;
	float seperator = 10;
	float rowContentWidth = self.items.count * WODActionSheetItem.size.width + seperator * (self.items.count -1);
	float offset = (width - rowContentWidth) / 2;
	
	UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
	
	int buttomInsets = orientation == UIInterfaceOrientationLandscapeLeft || orientation == UIInterfaceOrientationLandscapeRight ? self.edgeInsetsHorizen.bottom : self.edgeInsetsVertical.bottom;
	
	self.backView.frame = CGRectMake(0, self.bounds.size.height - buttomInsets - height, width, height);
	
	int index = 0;
	for (UIView * subView in self.backView.subviews)
	{
		if ([subView isKindOfClass:[WODActionSheetItem class]])
		{
			WODActionSheetItem * item = (WODActionSheetItem*)subView;
			item.frame = CGRectMake(offset + WODActionSheetItem.size.width * (index % 3) + seperator * (index % 3),
									height * (index / 3),
									WODActionSheetItem.size.width, WODActionSheetItem.size.height);
		}
		
		index ++;
	}
}

- (void)addItem:(NSString *)title icon:(UIImage *)icon
{
	icon = icon == nil ? [UIImage new] : icon;
	[self.items setObject:icon forKey:title];
}

@end


#pragma mark - - WODActionSheetItem Implementation -

@interface WODActionSheetItem()

@property (nonatomic, strong)UIImageView * iconView;
@property (nonatomic, strong)UILabel * titleView;

@end

@implementation WODActionSheetItem

- (id)init
{
	self = [super init];
	if (self)
	{
		_iconView = [UIImageView new];
		self.iconView.translatesAutoresizingMaskIntoConstraints = NO;
		_titleView = [UILabel new];
		[self.titleView setTextAlignment:NSTextAlignmentCenter];
		self.titleView.translatesAutoresizingMaskIntoConstraints = NO;
		self.titleView.textColor = color_white;
		self.tintColor = color_white;
		
		[self addSubview:self.iconView];
		[self addSubview:self.titleView];
		
		self.translatesAutoresizingMaskIntoConstraints = NO;
		
		self.backgroundColor = color_black;
	}
	return self;
}

+ (CGSize)size
{
	return UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad ? CGSizeMake(100, 80) : CGSizeMake(100, 80);
}

- (void)setTitle:(NSString *)title
{
	_title = title;
	self.titleView.text = NSLocalizedString(_title, nil);
}

- (void)setIcon:(UIImage *)icon
{
	_icon = icon;
	self.iconView.image = icon;
}

#define insects UIEdgeInsetsMake(5, 20, 5, 20)

- (void)layoutSubviews
{
	[super layoutSubviews];
	
	[self removeConstraints:self.constraints];
	
	UIInterfaceOrientation toInterfaceOrientation = [[UIApplication sharedApplication]statusBarOrientation];
	float iconSideLength = UIInterfaceOrientationPortrait || toInterfaceOrientation == UIInterfaceOrientationPortraitUpsideDown ? 40 : 30;
	float lableHeight = UIInterfaceOrientationPortrait || toInterfaceOrientation == UIInterfaceOrientationPortraitUpsideDown ? 20 : 15;
	
	int seperation = UIInterfaceOrientationPortrait || toInterfaceOrientation == UIInterfaceOrientationPortraitUpsideDown ? 5 : 5;
	
	[self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|-leading-[icon(iconSideLength)]-ascend-|" options:0 metrics:@{@"leading":@(insects.left),@"ascend":@(insects.right),@"iconSideLength":@(iconSideLength)} views:@{@"icon":self.iconView}]];
	[self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|[title]|" options:0 metrics:@{@"iconSideLength":@(iconSideLength)} views:@{@"title":self.titleView}]];
	
	[self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-top-[icon(iconSideLength)]-(seperation)-[title(lableHeight)]-bot-|" options:0 metrics:@{@"top":@(insects.top),@"bot":@(insects.bottom),@"seperation":@(seperation),@"iconSideLength":@(iconSideLength),@"lableHeight":@(lableHeight)} views:@{@"icon":self.iconView,@"title":self.titleView}]];
		
	float fontSize = 12;//toInterfaceOrientation == UIInterfaceOrientationPortrait || toInterfaceOrientation == UIInterfaceOrientationPortraitUpsideDown ? 16 : 14;
	self.titleView.font = [UIFont systemFontOfSize:fontSize];
	
	[super layoutSubviews];
}

@end
