//
//  WODEffect.h
//  TOP
//
//  Created by ianluo on 13-12-13.
//  Copyright (c) 2013年 WOD. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WODTextView.h"

@class WODEffect_Gradient;

@interface WODEffect : NSObject<WODTextViewEffectsDelegate>

@property (nonatomic, assign) CGSize renderSize;

@property (nonatomic, strong) NSArray * fillPatterns;
@property (nonatomic, assign) CGFloat fillPatternAlpha;
@property (nonatomic, strong) WODEffect_Gradient * gradient;

@property (nonatomic, assign) CGFloat strokeWidthPercentage;
@property (nonatomic, strong) __attribute((NSObject)) CGColorRef strokeColor;
@property (nonatomic, strong) NSArray * strokePatterns;
@property (nonatomic, assign) CGFloat strokePatternAlpha;
@property (nonatomic, strong) WODEffect_Gradient * strokeGradient;

@property (nonatomic, strong) __attribute((NSObject)) CGColorRef shadowColor;
@property (nonatomic, assign) CGSize shadowOffset;
@property (nonatomic, assign) CGFloat shadowBlur;

@property (nonatomic, assign) BOOL hasPattern;
@property (nonatomic, assign) BOOL hasGradient;
@property (nonatomic, assign) BOOL hasStrokePattern;
@property (nonatomic, assign) BOOL hasStrokGradient;

@property (nonatomic, copy) NSString * effectXMLFilePath;


- (id)initWithXMLFilePath:(NSString *)xmlFilePath;

- (void)prepare:(void(^)(void))complte;

- (CGPatternRef)createFillPattern:(float)renderScale;

- (CGPatternRef)createStrokPattern:(float)renderScale;

- (void)clearCache;

@end
