//
//  WODScrollTab.h
//  TOP
//
//  Created by ianluo on 13-12-13.
//  Copyright (c) 2013年 WOD. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WODScrollTab : UIView

@property (nonatomic, strong)NSArray * items;

- (void)initScrollTabWithItems:(NSArray *)items selection:(void(^)(id key,NSInteger index))block;

- (NSInteger)currentIndex;

- (id)keyForIndex:(NSInteger)index;

- (void)setSelectAtIndex:(NSInteger)index animationComplete:(void(^)())block;

@end
