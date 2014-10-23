//
//  WODFilterSelector.m
//  TOP
//
//  Created by ianluo on 14-5-19.
//  Copyright (c) 2014年 WOD. All rights reserved.
//

#import "WODFilterSelector.h"

@implementation WODFilterSelector

- (id)init
{
    self = [super init];
    if (self) {
		[self setAutoresizingMask:UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth];
		
		_filterNames = @[@"none",@"emboss",@"refraction"];
		
		UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(dismiss)];
		[tap setDelegate:self];
		[self addGestureRecognizer:tap];
	
		UICollectionViewFlowLayout * flowLayout = [UICollectionViewFlowLayout new];
		flowLayout.minimumInteritemSpacing = 0.0;
		flowLayout.minimumLineSpacing = 0.0;
		[flowLayout setScrollDirection:UICollectionViewScrollDirectionHorizontal];
		
        _filtersView = [[UICollectionView alloc]initWithFrame:CGRectZero collectionViewLayout:flowLayout];
		self.filtersView.backgroundColor = [WODConstants COLOR_TOOLBAR_BACKGROUND];
		self.filtersView.delegate = self;
		self.filtersView.dataSource = self;
		self.filtersView.translatesAutoresizingMaskIntoConstraints = NO;
		[self.filtersView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"cell"];
		
		[self addSubview:self.filtersView];
		
		int titleHeight = UIUserInterfaceIdiomPad == UI_USER_INTERFACE_IDIOM() ? 60 : 80 ;

		[self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|[filtersView]|" options:0 metrics:nil views:@{@"filtersView":self.filtersView}]];
		[self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[filtersView(height)]|" options:0 metrics:@{@"height":@(titleHeight)} views:@{@"filtersView":self.filtersView}]];
    }
    return self;
}

- (void)showFiltersViewIn:(UIView *)view WithComplete:(void (^)(NSString * filterName))action
{
	self.frame = CGRectMake(0, 100, view.bounds.size.width, view.bounds.size.height);
	self.alpha = 0.0;
	
	[view addSubview:self];
	
	[UIView animateWithDuration:0.25 delay:0.0 options:UIViewAnimationOptionCurveEaseOut animations:^{
		self.frame = CGRectMake(0, 0, view.bounds.size.width, view.bounds.size.height);
		self.alpha = 1.0;
	} completion:^(BOOL finished)
	 {
		 completeAction = action;
	 }];
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
	if (touch.view != self)
		return NO;
	else
		return YES;
}

- (void)dismiss
{
	[self removeFromSuperview];
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
	return self.filterNames.count;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
	if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
	{
		return CGSizeMake(100, 50);
	}
	else
	{
		return CGSizeMake(100, 50);
	}
}

// The cell that is returned must be retrieved from a call to -dequeueReusableCellWithReuseIdentifier:forIndexPath:
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
	UICollectionViewCell * cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"cell" forIndexPath:indexPath];
	
	if (cell.contentView.subviews.count > 0)
	{
		for (UIView * sub in cell.contentView.subviews)
		{
			if ([sub isKindOfClass:[FilterCell class]])
			{
				FilterCell * cell = (FilterCell *)sub;
				
				[cell.title setText:self.filterNames[indexPath.row]];
				
				break;
			}
		}
	}
	else
	{
		FilterCell * filterCell =  [[FilterCell alloc]initWithFrame:CGRectMake(0, 0, 100, 80)];
		[filterCell.title setText:self.filterNames[indexPath.row]];
		[cell.contentView addSubview:filterCell];
	}
	
	return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
	if (completeAction)
	{
		completeAction(self.filterNames[indexPath.row]);
	}
}

@end

@implementation FilterCell

- (id)initWithFrame:(CGRect)frame
{
	self = [super initWithFrame:frame];
	
	if (self)
	{
		_title = [UILabel new];
		[self.title setTextAlignment:NSTextAlignmentCenter];
		[self.title setBackgroundColor:[[WODConstants COLOR_CONTROLLER]colorWithAlphaComponent:0.5]];
		[self.title setTextColor:[WODConstants COLOR_TEXT_TITLE]];
		_title.translatesAutoresizingMaskIntoConstraints = NO;
		
		_imageView  = [UIImageView new];
		_imageView.translatesAutoresizingMaskIntoConstraints = NO;
		
		[self addSubview:self.title];
		[self addSubview:self.imageView];
		
		int titleHeight = UIUserInterfaceIdiomPad == UI_USER_INTERFACE_IDIOM() ? 20 : 40 ;
		
		[self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|[title]|" options:0 metrics:nil views:@{@"title":self.title}]];
		[self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[title(titleHeight)]-|" options:0 metrics:@{@"titleHeight":@(titleHeight)} views:@{@"title":self.title}]];
		
		[self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[image]|" options:0 metrics:nil views:@{@"image":self.imageView}]];
		[self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|[image]|" options:0 metrics:nil views:@{@"image":self.imageView}]];
	}
	return self;
}


@end
