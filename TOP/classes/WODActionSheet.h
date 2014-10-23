//
//  WODActionSheet.h
//  TOP
//
//  Created by ianluo on 13-12-13.
//  Copyright (c) 2013年 WOD. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WODItemPicker.h"

@class WODActionSheetItem;
@interface WODActionSheet : WODItemPicker

- (void)showFrom:(UIView *)view withSelection:(void (^)(WODActionSheetItem * selectedItem))block;
- (void)dismiss;
- (void)addItem:(NSString *)title icon:(UIImage *)icon;
@property (nonatomic, assign) UIEdgeInsets edgeInsetsHorizen;
@property (nonatomic, assign) UIEdgeInsets edgeInsetsVertical;

@end

@interface WODActionSheetItem : UIView

@property (nonatomic, copy) NSString * title;
@property (nonatomic, strong) UIImage * icon;
@property (nonatomic, assign) NSInteger index;

+ (CGSize)size;

@end
