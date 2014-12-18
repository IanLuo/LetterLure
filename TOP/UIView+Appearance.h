//
//  UIView+Appearance.h
//  AutoGang
//
//  Created by luoxu on 14/11/12.
//  Copyright (c) 2014年 com.qcb008.QiCheApp. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UIView(Appearance)

- (void)roundCorner:(NSUInteger)raduis;

- (void)border:(UIColor *)color width:(NSUInteger)width;

- (void)topBorder:(UIColor *)color width:(NSUInteger)width;

@end
