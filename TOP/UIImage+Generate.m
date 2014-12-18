//
//  UIImage+Generate.m
//  AutoGang
//
//  Created by ian luo on 14/11/7.
//  Copyright (c) 2014年 com.qcb008.QiCheApp. All rights reserved.
//

#import "UIImage+Generate.h"

@implementation UIImage(Generate)

+ (UIImage *)squareImageWithColor:(UIColor *)color andSize:(CGSize)size
{
    UIGraphicsBeginImageContextWithOptions(size, YES, 0);
    CGContextSetFillColorWithColor(UIGraphicsGetCurrentContext(), color.CGColor);
    CGContextFillRect(UIGraphicsGetCurrentContext(), CGRectMake(0, 0, ceil(size.width), ceil(size.height)));
    UIImage * image  = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

+ (UIImage *)underLineSquarImageWithBGColor:(UIColor *)color1 lineColor:(UIColor *)color2 andSize:(CGSize)size
{
    UIGraphicsBeginImageContextWithOptions(size, YES, 0);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(UIGraphicsGetCurrentContext(), color1.CGColor);
    CGContextFillRect(context, CGRectMake(0, 0, ceil(size.width), ceil(size.height)));
    
    CGContextSetFillColorWithColor(context, color2.CGColor);
    CGContextFillRect(context, CGRectMake(0, size.height - 4, size.width, 4));
    
    UIImage * image  = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

@end
