//
//  UIView+Appearance.m
//  AutoGang
//
//  Created by luoxu on 14/11/12.
//  Copyright (c) 2014年 com.qcb008.QiCheApp. All rights reserved.
//

#import "UIView+Appearance.h"

@implementation UIView(Appearance)

- (void)roundCorner:(NSUInteger)raduis
{
    self.layer.cornerRadius = raduis;
    self.layer.masksToBounds = YES;
}

- (void)border:(UIColor *)color width:(NSUInteger)width
{
    self.layer.borderColor = color.CGColor;
    self.layer.borderWidth = width;
}

- (void)topBorder:(UIColor *)color width:(NSUInteger)width
{
    CALayer * topBorder = [CALayer new];
    topBorder.frame = CGRectMake(0, -1, self.viewWidth, width);
    topBorder.backgroundColor = color.CGColor;
    [self.layer addSublayer:topBorder];
}

@end
