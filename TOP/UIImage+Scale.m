//
//  UIImage+Scale.m
//  AutoGang
//
//  Created by ian luo on 14/10/28.
//  Copyright (c) 2014年 com.qcb008.QiCheApp. All rights reserved.
//

#import "UIImage+Scale.h"

@implementation UIImage(Scale)

- (UIImage *)scaleDownToMaxSize:(CGSize)size
{
    CGSize imageSize = self.size;
    CGFloat scale = self.scale;
    
    float widthScale = 1, heightScale = 1;
    
    if (imageSize.width > size.width)
    {
        widthScale = (imageSize.width * scale) / size.width;
    }
    
    if (imageSize.height > size.width)
    {
        heightScale = (imageSize.height * scale) / size.height;
    }
    
    float outputScale = MAX(widthScale, heightScale);
    
    if (outputScale > 1)
    {
        return [self scaleToNewSize:CGSizeApplyAffineTransform(imageSize, CGAffineTransformMakeScale(1.0/outputScale, 1.0/outputScale))];
    }
    else
    {
        return self;
    }
}

- (UIImage *)scaleToNewSize:(CGSize)size
{
    UIGraphicsBeginImageContextWithOptions(size, YES, 1);
    
    [self drawInRect:CGRectMake(0, 0, size.width, size.height)];
    
    UIImage * result = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return result;
}

@end
