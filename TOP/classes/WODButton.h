//
//  WODButton.h
//  TOP
//
//  Created by ianluo on 13-12-13.
//  Copyright (c) 2013年 WOD. All rights reserved.
//

typedef enum
{
	WODButtonStyleNormal,
	WODButtonStyleRoundCorner,
	WODButtonStyleCircle,
	WODButtonStyleClear,
}WODButtonStyle;

#import <UIKit/UIKit.h>

@interface WODButton : UIButton
{
	UIColor * _buttonColor;
}

@property (nonatomic, strong)UIColor * borderColor;

- (void)showBorder:(BOOL)show;

@property (nonatomic, assign)WODButtonStyle style;

@end
