//
//  WODEffectReader.h
//  TOP
//
//  Created by ianluo on 13-12-13.
//  Copyright (c) 2013年 WOD. All rights reserved.
//

#import <Foundation/Foundation.h>

//pattern
extern NSString * const kPatternType;
extern NSString * const kPatternIsStencil;
extern NSString * const kPatternImagePath;
extern NSString * const kPatternGeneratorKey;
extern NSString * const kPatternAlpha;// for per pattern alpha
extern NSString * const kPatternWidth;
extern NSString * const kPatternHeight;

extern NSString * const kPatternFillPatterns;
extern NSString * const kPatternFillPatternAlpha;// for total patterns alpha

extern NSString * const kPatternStrokePatterns;
extern NSString * const kPatternStrokePatternAlpha;

//gradient
extern NSString * const kGradientType;
extern NSString * const kGradient;
extern NSString * const kGradientBlendMode;
extern NSString * const kGradientRed;
extern NSString * const kGradientGreen;
extern NSString * const kGradientBlue;
extern NSString * const kGradientAlpha;
extern NSString * const kGradientLocation;
extern NSString * const kGradientColorArray;
extern NSString * const kGradientLineAttrAngle;
extern NSString * const kGradientRadialAttrCenter1XPercentage;
extern NSString * const kGradientRadialAttrCenter1YPercentage;
extern NSString * const kGradientRadialAttrCenter2XPercentage;
extern NSString * const kGradientRadialAttrCenter2YPercentage;
extern NSString * const kGradientRadialAttrRadialGradientRadius1Percentage;
extern NSString * const kGradientRadialAttrRadialGradientRadius2Percentage;

//strokeGradient
extern NSString * const kStrokeGradientType;
extern NSString * const kStrokeGradient;
extern NSString * const kStrokeGradientRed;
extern NSString * const kStrokeGradientGreen;
extern NSString * const kStrokeGradientBlue;
extern NSString * const kStrokeGradientAlpha;
extern NSString * const kStrokeGradientLocation;
extern NSString * const kStrokeGradientColorArray;
extern NSString * const kStrokeGradientLineAttrAngle;
extern NSString * const kStrokeGradientRadialAttrCenter1XPercentage;
extern NSString * const kStrokeGradientRadialAttrCenter1YPercentage;
extern NSString * const kStrokeGradientRadialAttrCenter2XPercentage;
extern NSString * const kStrokeGradientRadialAttrCenter2YPercentage;
extern NSString * const kStrokeGradientRadialAttrRadialGradientRadius1Percentage;
extern NSString * const kStrokeGradientRadialAttrRadialGradientRadius2Percentage;

//shadow
extern NSString * const kShadowColor;
extern NSString * const kShadowOffset;
extern NSString * const kShadowBlur;

//stroke
extern NSString * const kStrokeWidthPercent;
extern NSString * const kStrokeColor;

@interface WODEffectReader : NSObject

- (void)readEffect:(NSString *)fileName complete:(void(^)(NSDictionary * result))block;

@end
