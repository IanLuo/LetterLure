//
//  WODTextView.h
//  TOP
//
//  Created by ianluo on 13-12-12.
//  Copyright (c) 2013年 WOD. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WODBackgroundLayer.h"
#import "WODTransformEngine.h"

@class WODTextView;

@protocol WODTextViewLayoutDelegate <NSObject>

- (NSArray *)textview:(WODTextView *)textview positionForCharacters:(NSAttributedString *)aString glyphInfo:(NSDictionary *)info;

@optional
- (CGFloat)spaceSize;
- (void)didStartRender:(WODTextView *)textview;
- (void)didEndRender:(WODTextView *)textview;

@end

@protocol WODTextViewEffectsDelegate <NSObject>

- (CGGradientRef)gradient;
- (NSArray *)fillPatterns;

- (CGFloat)strokeWidthPercentage;
- (NSArray *)strokePatterns;
- (CGGradientRef)strokeGradient;
- (CGColorRef)strokeColor;

- (CGColorRef)shadowColor;
- (CGSize)shadowOffset;
- (CGFloat)shadowBlur;

@end
/*
 
 */

typedef struct
{
	CGPoint point;
	float angle;
}CPosition;

typedef enum
{
	TypesetShapePath = 0,
	TypesetLayoutProvider,
}
Typeset;

@interface WODTextView : UIView


@property (nonatomic, assign)NSUInteger name;
@property (nonatomic, strong)NSString * cacheKey;

@property (nonatomic, assign) Typeset currentTypeSet;
@property (nonatomic, strong) __attribute__((NSObject))CGPathRef layoutShapPath;
@property (nonatomic, assign) CGFloat pathScaleFactor;

//mark the text view's content has been modified need to be regenerated
@property (nonatomic, assign) BOOL needGenerateImage;

//those properties change will automatically cauese regenerate image
@property (nonatomic, strong) id<WODTextViewLayoutDelegate> layoutProvider;
@property (atomic, strong) id<WODTextViewEffectsDelegate> effectProvider;
@property (nonatomic, strong) NSNumber * alpha;

@property (nonatomic, assign) BOOL hideFeatures;
@property (nonatomic, assign) BOOL shouldShowPath;

@property (nonatomic, strong) WODTransformEngine *transformEngine;

@property (nonatomic, copy) NSAttributedString * text;

@property (nonatomic, assign) CGFloat spaceSize;

/*
 
 */
- (id)initWithFrame:(CGRect)frame;

- (void)displayTextHideFeatures:(BOOL)hideFeatures;

- (void)displayTextHideFeatures:(BOOL)h complete:(void(^)(UIImage * image))action;

- (void)generateFullSizeImageScale:(CGFloat)scale Complete:(void(^)(UIImage * image))action;

- (WODTextView *)copyOfThisTextView;

- (CGPathRef)newScaledPath;

- (void)applyShapePath:(UIBezierPath *)path;

- (void)resetLayoutShapePath;

- (void)restoreShape;
@end

