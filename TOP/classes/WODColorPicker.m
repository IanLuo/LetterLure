//
//  WODColorPickerViewController.m
//  TOP
//
//  Created by ianluo on 13-12-12.
//  Copyright (c) 2013年 WOD. All rights reserved.
//

#import "WODColorPicker.h"
#import <QuartzCore/QuartzCore.h>

@interface WODColorPicker ()<UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout>

@property (nonatomic, strong)UICollectionView * colorsView;
@property (nonatomic, strong)NSArray * items;

@end

#define ID_CELL @"itemCell"

@implementation WODColorPicker

- (id)init
{
	self = [super init];
	if (self)
	{
		
		UICollectionViewLayout * layout = [UICollectionViewFlowLayout new];
		_colorsView = [[UICollectionView alloc]initWithFrame:CGRectZero collectionViewLayout:layout];
		self.colorsView.translatesAutoresizingMaskIntoConstraints = NO;
		[self.colorsView setCollectionViewLayout:layout];
		[self.colorsView setDelegate:self];
		[self.colorsView setDataSource:self];
		[self addSubview:self.colorsView];
		
		[self.colorsView registerClass:[WODColorPickerCell class] forCellWithReuseIdentifier:ID_CELL];
		
		[self setItems:[self colorArray]];
		
		self.colorsView.backgroundColor = WODConstants.COLOR_VIEW_BACKGROUND;
	}
	return self;
}

#define k_lastUsingColor @"last_using_color"

- (UIColor *)defaultColor
{
	UIColor * color = nil;
	if ([[NSUserDefaults standardUserDefaults]objectForKey:k_lastUsingColor])
	{
		NSArray * colorComponents = [[NSUserDefaults standardUserDefaults]objectForKey:k_lastUsingColor];
		color = [UIColor colorWithRed:[(NSNumber *)colorComponents[0] doubleValue] green:[(NSNumber *)colorComponents[1] doubleValue] blue:[(NSNumber *)colorComponents[2] doubleValue] alpha:1];
	}
	return  color? color : WODConstants.COLOR_CONTROLLER;
}

- (void)saveLastUsingColor:(UIColor *)color
{
	CGFloat r,g,b,a;
	[color getRed:&r green:&g blue:&b alpha:&a];
	[[NSUserDefaults standardUserDefaults]setObject:@[@(r),@(g),@(b)] forKey:k_lastUsingColor];
	[[NSUserDefaults standardUserDefaults]synchronize];
}

- (NSArray *)colorArray
{
	NSMutableArray * colors = [NSMutableArray array];
	
	[colors addObject:[UIColor colorWithRed:0.0 green:0/.0 blue:0.0 alpha:1]];
	[colors addObject:[UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:1]];

	for (float i = 1.0; i < 200.0; i++)
	{
		float r = arc4random() % 255;
		float g = arc4random() % 255;
		float b = arc4random() % 255;
		[colors addObject:[UIColor colorWithRed:r/255.0 green:g/255.0 blue:b/255.0 alpha:1]];
	}
	
	return [NSArray arrayWithArray:colors];
}

- (void)layoutSubviews
{
	[super layoutSubviews];
	
	[self removeConstraints:self.constraints];
	
	[self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|[colorsView]|" options:0 metrics:nil views:@{@"colorsView":self.colorsView}]];
	[self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[colorsView]|" options:0 metrics:nil views:@{@"colorsView":self.colorsView}]];
	
	[super layoutSubviews];
}

#pragma - collection view datasource and delegate

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
	return self.items.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
	WODColorPickerCell * cell = (WODColorPickerCell *)[collectionView dequeueReusableCellWithReuseIdentifier:ID_CELL forIndexPath:indexPath];
	
	cell.backgroundColor = (UIColor *)[self.items objectAtIndex:indexPath.row];
	
	return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
	[self saveLastUsingColor:self.items[indexPath.row]];
	
	if ([self.delegate respondsToSelector:@selector(didFinishPickingColor:picker:)])
	{
		[self.delegate didFinishPickingColor:self.items[indexPath.row] picker:self];
	}
}

#pragma - layout delegate

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
	return CGSizeMake(40, 40);
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
	return UIEdgeInsetsMake(10, 10, 10, 10);
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section
{
	return 10;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section
{
	return 10;
}

@end


#pragma  - * WODColorPickerCell implementation *

@implementation WODColorPickerCell

- (id)initWithFrame:(CGRect)frame
{
	self = [super initWithFrame:frame];
	if (self)
	{
		self.layer.cornerRadius = 20;
		self.layer.masksToBounds = YES;
	}
	return self;
}

@end
