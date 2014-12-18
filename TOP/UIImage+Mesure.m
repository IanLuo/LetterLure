//
//  UIImage+Mesure.m
//  AutoGang
//
//  Created by ian luo on 14/10/24.
//  Copyright (c) 2014年 com.qcb008.QiCheApp. All rights reserved.
//

#import "UIImage+Mesure.h"

@implementation UIImage(Messure)

- (CGFloat)byteSize
{
    return CGImageGetBytesPerRow(self.CGImage) * CGImageGetHeight(self.CGImage);
}

@end
