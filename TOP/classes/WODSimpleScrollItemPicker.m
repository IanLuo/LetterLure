//
//  WODSimpleScrollItemPicker.m
//  TOP
//
//  Created by ianluo on 13-12-25.
//  Copyright (c) 2013年 WOD. All rights reserved.
//

#import "WODSimpleScrollItemPicker.h"

@interface WODSimpleScrollItemPicker()<UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout,UIGestureRecognizerDelegate>
{
	void (^selectionAction)(WODSimpleScrollItemPickerItem * selectedItem);
	NSArray * simpleScrollItemPickerConstraints;
}

@property (nonatomic, strong) NSMutableArray * items;
@property (nonatomic, weak) UIView * parentView;
@property (nonatomic, assign)BOOL shouldIgnorEventOnBackView;

@end

@implementation WODSimpleScrollItemPicker

- (id)init
{
    self = [super init];
    if (self) {
        _items = [NSMutableArray array];
					
		UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(dismiss)];
		[tap setDelegate:self];
		[self addGestureRecognizer:tap];
		[self setAutoresizingMask:UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth];
		
		self.distansFromBottomPortrait = 50;
		self.distansFromBottomLandscape = 30;
		self.contentSizeShortSide = 44;
		self.itemOffset = 3;
		
		UICollectionViewFlowLayout * flowLayout = [UICollectionViewFlowLayout new];
		
		_itemsCollectionView = [[UICollectionView alloc]initWithFrame:CGRectZero collectionViewLayout:flowLayout];
		self.itemsCollectionView.translatesAutoresizingMaskIntoConstraints = NO;
		[self.itemsCollectionView setDataSource:self];
		[self.itemsCollectionView setDelegate:self];
		[self.itemsCollectionView setContentInset:UIEdgeInsetsMake(0, 10, 0, 10)];
		[self.itemsCollectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"itemID"];
		[self.itemsCollectionView setBackgroundColor:[WODConstants.COLOR_ITEM_PICKER colorWithAlphaComponent:0.7]];
		[self addSubview:self.itemsCollectionView];
		
		self.position = BarPostionBotton;
		self.hideBorder = NO;
		
		[[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(updateColors) name:NOTIFICATION_THEME_CHANGED object:nil];
    }
    return self;
}

- (void)dealloc
{
#ifdef DEBUGMODE
	NSLog(@"(%@,%i):deallocing...",[[NSString stringWithUTF8String:__FILE__]lastPathComponent],__LINE__);
#endif
	[[NSNotificationCenter defaultCenter]removeObserver:self];
}

- (void)updateColors
{
	[self.itemsCollectionView setBackgroundColor:WODConstants.COLOR_ITEM_PICKER];
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
	if (touch.view != self || self.shouldIgnorEventOnBackView)
		return NO;
	else
		return YES;
}

- (void)setDisplayStyle:(DisplayStyle)displayStyle
{
	if (displayStyle == DisplayStyleNormal)
	{
		self.shouldIgnorEventOnBackView = NO;
	}
	else
	{
		self.shouldIgnorEventOnBackView = YES;
	}
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
	return self.items.count;
}

#define itemViewTag  99

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
	UICollectionViewCell * cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"itemID" forIndexPath:indexPath];
	
	WODSimpleScrollItemPickerItem * item = (WODSimpleScrollItemPickerItem *)[cell viewWithTag:itemViewTag];
	if (!item)
	{
		item = [WODSimpleScrollItemPickerItem new];
		item.translatesAutoresizingMaskIntoConstraints = NO;
		[item setTag:itemViewTag];
		[cell addSubview:item];
		[cell addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|-offset-[item]-offset-|" options:0 metrics:@{@"offset":@(self.itemOffset)} views:@{@"item":item}]];
		[cell addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-offset-[item]-offset-|" options:0 metrics:@{@"offset":@(self.itemOffset)} views:@{@"item":item}]];
	}
	
	item.isControlItem = NO;
	item.index = indexPath.row;
	item.isSelected = self.selectedIndex == item.index;
	item.hideBorder = self.hideBorder;//this option only work for non-control items
			
	[item setDisplayView:self.items[indexPath.row]];
	
	[self.controlItemIndexs enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop)
	{
		if (indexPath.row == [(NSNumber *)obj intValue])
		{
			item.isControlItem = YES;
			BOOL isStop = YES;
			stop = &isStop;
		}
	}];
	
	[item setAppearence];
	
	return cell;
}


- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
	return CGSizeMake(self.contentSizeShortSide, self.contentSizeShortSide);
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
	WODSimpleScrollItemPickerItem * selectedItem = (WODSimpleScrollItemPickerItem *)[[collectionView cellForItemAtIndexPath:indexPath]viewWithTag:itemViewTag];
	
	self.selectedIndex = indexPath.row;
	
	NSMutableArray * visiblePaths = [NSMutableArray array];
	for (UICollectionViewCell * cell in [collectionView visibleCells])
	{
		[visiblePaths addObject:[collectionView indexPathForCell:cell]];
	}
	[collectionView reloadItemsAtIndexPaths:visiblePaths];
	
	if (selectionAction)
		selectionAction(selectedItem);
}

- (void)layoutSubviews
{
	[super layoutSubviews];
		
	//clear old constraints for inner content view
	[self removeConstraints:self.constraints];
		
	//calculate the distance away from bottom of the view, based on orientation
	UIInterfaceOrientation toInterfaceOrientation = [[UIApplication sharedApplication]statusBarOrientation];
	float toolbarHeight = self.distansFromBottomPortrait;
	
	if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
		toolbarHeight = toInterfaceOrientation == UIInterfaceOrientationPortrait || toInterfaceOrientation == UIInterfaceOrientationPortraitUpsideDown ? self.distansFromBottomPortrait : self.distansFromBottomLandscape;
		
	if(self.position & BarPostionLeft)
	{
		float topOffset = 0;//UI_USER_INTERFACE_IDIOM()==UIUserInterfaceIdiomPhone ?30 : 44;
		
		if ((toInterfaceOrientation == UIInterfaceOrientationLandscapeLeft || toInterfaceOrientation == UIInterfaceOrientationLandscapeRight)||!(self.position & BarPostionBotton))
		{
			[(UICollectionViewFlowLayout *)self.itemsCollectionView.collectionViewLayout setScrollDirection:UICollectionViewScrollDirectionVertical];
			
			[self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|[collectionView(contentSizeShortSide)]" options:0 metrics:@{@"contentSizeShortSide":@(self.contentSizeShortSide)} views:@{@"collectionView":self.itemsCollectionView}]];
			[self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-topOffset-[collectionView]-toolbarHeight-|" options:0 metrics:@{@"toolbarHeight":@(toolbarHeight),@"topOffset":@(topOffset)} views:@{@"collectionView":self.itemsCollectionView}]];
		}
	}
	else if(self.position & BarPostionRight)
	{
		float topOffset = 0;//UI_USER_INTERFACE_IDIOM()==UIUserInterfaceIdiomPhone ?30 : 44;
		
		if ((toInterfaceOrientation == UIInterfaceOrientationLandscapeLeft || toInterfaceOrientation == UIInterfaceOrientationLandscapeRight)||!(self.position & BarPostionBotton))
		{
			[(UICollectionViewFlowLayout *)self.itemsCollectionView.collectionViewLayout setScrollDirection:UICollectionViewScrollDirectionVertical];
			[self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"[collectionView(contentSizeShortSide)]|" options:0 metrics:@{@"contentSizeShortSide":@(self.contentSizeShortSide)} views:@{@"collectionView":self.itemsCollectionView}]];
			[self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-topOffset-[collectionView]-toolbarHeight-|" options:0 metrics:@{@"toolbarHeight":@(toolbarHeight),@"topOffset":@(topOffset)} views:@{@"collectionView":self.itemsCollectionView}]];
		}
	}
	
	if (self.position & BarPostionBotton)
	{
		if (!(self.position & BarPostionLeft || self.position & BarPostionRight)
			|| (toInterfaceOrientation == UIInterfaceOrientationPortrait || toInterfaceOrientation == UIInterfaceOrientationPortraitUpsideDown))
		{
			[(UICollectionViewFlowLayout *)self.itemsCollectionView.collectionViewLayout setScrollDirection:UICollectionViewScrollDirectionHorizontal];
			[self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|[collectionView]|" options:0 metrics:nil views:@{@"collectionView":self.itemsCollectionView}]];
			[self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[collectionView(collectionViewHeight)]-toolbarHeight-|" options:0 metrics:@{@"collectionViewHeight":@(self.contentSizeShortSide),@"toolbarHeight":@(toolbarHeight)} views:@{@"collectionView":self.itemsCollectionView}]];
		}
	}
	
	[super layoutSubviews];
}

- (void)showFrom:(UIView *)view withSelection:(void (^)(WODSimpleScrollItemPickerItem * selectedItem))block
{
	self.parentView = view;
	
	if (self.position & BarPostionLeft)
	{
		self.frame = CGRectMake(-self.contentSizeShortSide, 0, view.bounds.size.width, view.bounds.size.height);
	}
	else if(self.position & BarPostionRight)
	{
		self.frame = CGRectMake(self.contentSizeShortSide, 0, view.bounds.size.width, view.bounds.size.height);
	}
	else
	{
		self.frame = CGRectMake(0, self.contentSizeShortSide, view.bounds.size.width, view.bounds.size.height);
	}
	
	self.alpha = 0.0;
	
	[self.parentView addSubview:self];
	
	[UIView animateWithDuration:0.25 delay:0.0 options:UIViewAnimationOptionCurveEaseOut animations:^{
		self.frame = CGRectMake(0, 0, view.bounds.size.width, view.bounds.size.height);
		self.alpha = 1.0;
	} completion:^(BOOL finished)
	{
		selectionAction = block;
	}];
	
}

- (void)dismiss
{
	UIView * view = self.parentView;
	if(self.superview)
	{
		[UIView animateWithDuration:0.3 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
			if (self.position & BarPostionLeft)
			{
				self.frame = CGRectMake(-self.contentSizeShortSide, 0, view.bounds.size.width, view.bounds.size.height);
			}
			else if(self.position & BarPostionRight)
			{
				self.frame = CGRectMake(self.contentSizeShortSide, 0, view.bounds.size.width, view.bounds.size.height);
			}
			else
			{
				self.frame = CGRectMake(0, self.contentSizeShortSide, view.bounds.size.width, view.bounds.size.height);
			}
			
			self.alpha = 0.0;

		} completion:^(BOOL finished) {
			[self removeFromSuperview];
			if (selectionAction)
			{
				selectionAction(nil);
			}
			self.parentView = nil;
		}];
	}
}

- (void)addItem:(NSString *)title
{
	[self.items addObject:title];
}

- (void)addItemWithView:(UIView *)view
{
	[self.items addObject:view];
}

- (void)addItemWithTitle:(NSString *)title andView:(UIView *)view
{
	
}

@end

#pragma mark - implementation of WODSimpleScrollItemPickerItem

typedef enum
{
	ItemViewTypeText,
	ItemViewTypeImage,
}ItemViewType;

@interface WODSimpleScrollItemPickerItem()

@property (nonatomic, strong)UILabel * titleLabel;
@property (nonatomic, assign)ItemViewType itemViewType;

@end

@implementation WODSimpleScrollItemPickerItem

- (id)init
{
	self = [super init];
	if (self)
	{
		[self addObserver:self forKeyPath:@"bounds" options:0 context:nil];
		self.hideBorder = NO;
		self.backgroundColor = [UIColor clearColor];
		self.contentMode = UIViewContentModeScaleAspectFill;
	}
	return self;
}

- (UILabel *)titleLabel
{
	if (!_titleLabel)
	{
		_titleLabel = [UILabel new];
		_titleLabel.translatesAutoresizingMaskIntoConstraints = NO;
		_titleLabel.font = [UIFont flatFontOfSize:18];
		_titleLabel.textAlignment = NSTextAlignmentCenter;
	}
	return _titleLabel;
}

- (void)dealloc
{
	[self removeObserver:self forKeyPath:@"bounds"];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
	if ([keyPath isEqualToString:@"bounds"])
	{
		[self setAppearence];
	}
}

- (void)setAppearence
{
	self.layer.masksToBounds = YES;
	self.layer.borderWidth = 0;
	self.layer.cornerRadius = self.bounds.size.height * 0.5;
	
	if (!self.isControlItem)
	{
		if (!self.hideBorder)
		{
			if (self.isSelected)
			{
				self.layer.borderColor = WODConstants.COLOR_TEXT_TITLE.CGColor;
				self.layer.borderWidth = 2;
			}
			else
			{
				self.layer.borderWidth = 0;
				self.layer.borderColor = WODConstants.COLOR_TEXT_TITLE.CGColor;
			}
		}
		else
		{
			self.layer.borderWidth = 0;
		}
		
		self.tintColor = WODConstants.COLOR_TEXT_TITLE;
		self.titleLabel.textColor = WODConstants.COLOR_TEXT_TITLE;
		self.backgroundColor = WODConstants.COLOR_ITEM_PICKER_CUSTOM_ITEM;
	}
	else
	{
		self.tintColor = WODConstants.COLOR_TEXT_TITLE;
		self.layer.borderColor = WODConstants.COLOR_TEXT_TITLE.CGColor;
		self.titleLabel.textColor = WODConstants.COLOR_TEXT_TITLE;
		self.backgroundColor = WODConstants.COLOR_ITEM_PICKER_CONTROL_ITEM;
	}
}

- (void)layoutSubviews
{
	[super layoutSubviews];
	
	[self removeConstraints:self.constraints];
	
	if (self.itemViewType == ItemViewTypeText)
	{
		if (self.titleLabel.superview == self)
		{
			[self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|[title]|" options:0 metrics:nil views:@{@"title":self.titleLabel}]];
			[self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[title]|" options:0 metrics:nil views:@{@"title":self.titleLabel}]];
		}
	}
	
	if (self.itemViewType == ItemViewTypeImage)
	{
		// when reusing customView, sometimes the custome view is not for this view but the link is still pointing to that view
		if (self.customView.superview == self)
		{			
			[self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|[customView]|" options:0 metrics:nil views:@{@"customView":self.customView}]];
			[self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[customView]|" options:0 metrics:nil views:@{@"customView":self.customView}]];
			self.customView.layer.cornerRadius = self.bounds.size.height/2;
			self.customView.layer.masksToBounds = YES;
		}
	}
	
	[self setAppearence];
	[super layoutSubviews];
}

- (void)setDisplayView:(id)display
{
	if ([display isKindOfClass:[NSString class]])
	{
		[self setTitle:display];
	}
	
	if ([display isKindOfClass:[UIView class]])
	{
		[self setCustomView:display];
	}
}

- (void)setTitle:(NSString *)title
{
	for (UIView * sub in self.subviews)
	{
		[sub removeFromSuperview];
	}
	
	self.itemViewType = ItemViewTypeText;
	
	_title = title;
	self.titleLabel.text = title;
	
	[self addSubview:self.titleLabel];
}

- (void)setCustomView:(UIView *)view
{
	for (UIView * sub in self.subviews)
	{
		[sub removeFromSuperview];
	}
	
	self.itemViewType = ItemViewTypeImage;
	
	_customView = view;
	_customView.translatesAutoresizingMaskIntoConstraints = NO;

	[self addSubview:self.customView];
}
@end
