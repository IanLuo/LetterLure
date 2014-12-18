//
//  UIImage+Generate.h
//  AutoGang
//
//  Created by ian luo on 14/11/7.
//  Copyright (c) 2014年 com.qcb008.QiCheApp. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UIImage(Generate)

+ (UIImage *)squareImageWithColor:(UIColor *)color andSize:(CGSize)size;

+ (UIImage *)underLineSquarImageWithBGColor:(UIColor *)color1 lineColor:(UIColor *)color2 andSize:(CGSize)size;

@end
