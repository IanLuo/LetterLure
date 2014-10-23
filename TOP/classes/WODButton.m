//
//  WODButton.m
//  TOP
//
//  Created by ianluo on 13-12-13.
//  Copyright (c) 2013年 WOD. All rights reserved.
//

#import "WODButton.h"

@implementation WODButton

- (id)initWithFrame:(CGRect)frame
{
	self = [super initWithFrame:frame];
	if (self)
	{
		[self setContentMode:UIViewContentModeScaleAspectFit];
		[self.imageView setContentMode:UIViewContentModeScaleAspectFit];
		[self setContentEdgeInsets:UIEdgeInsetsMake(5, 5, 5, 5)];
		
		[self addObserver:self forKeyPath:@"selected" options:NSKeyValueObservingOptionNew context:nil];
		[self addObserver:self forKeyPath:@"bounds" options:NSKeyValueObservingOptionNew context:nil];
		
		self.buttonColor = WODConstants.COLOR_CONTROLLER;
		self.cornerRadius = 6.0f;
		self.titleLabel.font = [UIFont boldFlatFontOfSize:16];
		[self setTitleColor:[UIColor cloudsColor] forState:UIControlStateNormal];
		[self setTitleColor:[UIColor cloudsColor] forState:UIControlStateHighlighted];
		[self setTintColor:[UIColor cloudsColor]];
		
		[[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(updateTheme) name:NOTIFICATION_THEME_CHANGED object:nil];
    }
	
    return self;
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
	if (self.style == WODButtonStyleClear)
	{
		return;
	}
	
	if ([keyPath isEqualToString:@"selected"])
	{
		if ([[change valueForKey:NSKeyValueChangeNewKey]boolValue])
		{
			self.buttonColor = WODConstants.COLOR_CONTROLLER_SELECTED;
		}
		else
		{
			self.buttonColor = WODConstants.COLOR_CONTROLLER;
		}
	}
	else if ([keyPath isEqualToString:@"bounds"])
	{
		CGRect bounds = [[change valueForKey:NSKeyValueChangeNewKey]CGRectValue];
		
		if (self.style == WODButtonStyleCircle)
		{
			self.layer.cornerRadius = bounds.size.width/2;
			self.layer.masksToBounds = YES;
		}
	}
}

- (void)updateTheme
{
	if (self.style == WODButtonStyleClear)
	{
		return;
	}
	
	if (self.isSelected)
	{
		self.buttonColor = WODConstants.COLOR_CONTROLLER_SELECTED;
	}
	else
	{
		self.buttonColor = WODConstants.COLOR_CONTROLLER;
	}
}

- (void)setStyle:(WODButtonStyle)style
{
	if (style == WODButtonStyleCircle)
	{
		self.layer.cornerRadius = self.bounds.size.width/2;
		self.layer.masksToBounds = YES;
	}
	else if (style == WODButtonStyleRoundCorner)
	{
		self.layer.cornerRadius = self.bounds.size.height/2;
		self.layer.masksToBounds = YES;
	}
	else if(style == WODButtonStyleClear)
	{
		self.buttonColor = [UIColor clearColor];
	}
	_style = style;
}

- (void)dealloc
{
	[self removeObserver:self forKeyPath:@"selected"];
	[self removeObserver:self forKeyPath:@"bounds"];
	[[NSNotificationCenter defaultCenter]removeObserver:self];
}

- (void)setBorderColor:(UIColor *)borderColor
{
	_borderColor = borderColor;
	self.layer.borderColor = self.borderColor.CGColor;
}

- (void)showBorder:(BOOL)show
{
	if (show)
	{
//		self.layer.borderWidth = 1.0;
//		self.layer.borderColor = self.borderColor ? self.borderColor.CGColor : COLOR_LINE_COLOR.CGColor;
	}
	else
	{
//		self.layer.borderWidth = 0.0;
	}
}
@end
