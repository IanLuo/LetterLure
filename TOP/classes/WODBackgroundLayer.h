//
//  WODBackgroundLayer.h
//  TOP
//
//  Created by ianluo on 14-1-5.
//  Copyright (c) 2014年 WOD. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

typedef enum
{
	FillTypeOpaque,
	FillTypeHalf,
	FillTypeTransparent,
	FillTypeStroke,
}FillType;

@interface WODBackgroundLayer : CALayer

@property (nonatomic, strong)UIColor * fillColor;
@property (nonatomic, strong)__attribute__((NSObject)) CGPathRef fillPath;
@property (nonatomic, assign)BOOL isShowBorder;
@property (nonatomic, assign)FillType fillType;

- (void)fillBackgroundWithColor:(UIColor *)color andPath:(CGPathRef)path;

@end
