//
//  WODSystemPatternGenerator.h
//  TOP
//
//  Created by ianluo on 14-1-8.
//  Copyright (c) 2014年 WOD. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString *const kPatternGrid;
extern NSString *const kPatternGrid ;
extern NSString *const kPatternDotBig;
extern NSString *const kPatternDotMid;
extern NSString *const kPatternDotSmall;

@interface WODSystemPatternGenerator : NSObject

- (void)generatePatternWithKey:(NSString *)patternKey size:(CGSize)size inContext:(CGContextRef)context;

@end
