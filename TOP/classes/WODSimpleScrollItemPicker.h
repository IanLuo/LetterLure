//
//  WODSimpleScrollItemPicker.h
//  TOP
//
//  Created by ianluo on 13-12-25.
//  Copyright (c) 2013年 WOD. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WODItemPicker.h"

typedef enum
{
	BarPostionBotton = 1,
	BarPostionLeft = 1 << 1,
	BarPostionRight = 1 << 2,
}BarPostion;

typedef enum
{
	DisplayStyleNormal = 0,
	DisplayStylePermenante,
}DisplayStyle;

@class WODSimpleScrollItemPickerItem;
@interface WODSimpleScrollItemPicker : WODItemPicker

- (void)showFrom:(UIView *)view withSelection:(void (^)(WODSimpleScrollItemPickerItem * selectedItem))block;
- (void)dismiss;
- (void)addItem:(NSString *)title;
- (void)addItemWithView:(UIView *)view;
- (void)addItemWithTitle:(NSString *)title andView:(UIView *)view;

@property (nonatomic, strong)UICollectionView * itemsCollectionView;

@property (nonatomic, assign)CGFloat distansFromBottomPortrait;
@property (nonatomic, assign)CGFloat distansFromBottomLandscape;
@property (nonatomic, assign)CGFloat contentSizeShortSide;
@property (nonatomic, assign)CGFloat itemOffset;

@property (nonatomic, strong)NSArray * controlItemIndexs;
@property (nonatomic, assign)BarPostion position;
@property (nonatomic, assign)NSUInteger selectedIndex;
@property (nonatomic, assign)BOOL hideBorder;
@property (nonatomic, assign) DisplayStyle displayStyle;

@end

@interface WODSimpleScrollItemPickerItem : UIView

@property (nonatomic, assign)NSUInteger index;
@property (nonatomic, strong)NSString * title;
@property (nonatomic, strong)UIView * customView;
@property (nonatomic, assign)BOOL isControlItem;
@property (nonatomic, assign)BOOL isSelected;
@property (nonatomic, assign)BOOL hideBorder;
- (void)setAppearence;
- (void)setDisplayView:(id)display;
@end
