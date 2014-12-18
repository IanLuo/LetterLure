//
//  UIImage+Scale.h
//  AutoGang
//
//  Created by ian luo on 14/10/28.
//  Copyright (c) 2014年 com.qcb008.QiCheApp. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UIImage(Scale)

- (UIImage *)scaleDownToMaxSize:(CGSize)size;

- (UIImage *)scaleToNewSize:(CGSize)size;

@end
