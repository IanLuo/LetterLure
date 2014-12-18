//
//  WODSlider.m
//  TOP
//
//  Created by ianluo on 13-12-13.
//  Copyright (c) 2013年 WOD. All rights reserved.
//

#import "WODSlider.h"
#import <QuartzCore/QuartzCore.h>

@implementation WODSlider

- (id)init
{
    self = [super init];
    if (self) {
//		[self configureFlatSliderWithTrackColor:WODConstants.COLOR_CONTROLLER_DISABLED
//									  progressColor:WODConstants.COLOR_CONTROLLER_HIGHTLIGHT
//										 thumbColor:WODConstants.COLOR_CONTROLLER_SHADOW];
//		[self addObserver:self forKeyPath:@"bounds" options:NSKeyValueObservingOptionNew context:nil];
    }
    return self;
}

- (void)dealloc
{
//	[self removeObserver:self forKeyPath:@"bounds"];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
	if ([keyPath isEqualToString:@"bounds"])
	{
		self.layer.cornerRadius = [change[@"new"] CGRectValue].size.height/2;
		
		UIImage * image = [self createThumbImage];
		[self setThumbImage:image forState:UIControlStateHighlighted];
		[self setThumbImage:image forState:UIControlStateNormal];
	}
}

- (UIImage *)createThumbImage
{
	CGSize size = CGSizeMake(self.bounds.size.height - 1, self.bounds.size.height - 1);
	UIGraphicsBeginImageContextWithOptions(size, NO, 0);
	
	UIBezierPath * path = [UIBezierPath bezierPathWithRoundedRect:CGRectMake(0, 0, size.width-1, size.height-1) cornerRadius:size.width/2];
	
	UIColor * color = color_black;
	CGContextSetFillColorWithColor(UIGraphicsGetCurrentContext(), color.CGColor);
	
	[path fill];
	
	UIImage * image = UIGraphicsGetImageFromCurrentImageContext();
	
	UIGraphicsEndImageContext();
	
	return image;
}
@end
