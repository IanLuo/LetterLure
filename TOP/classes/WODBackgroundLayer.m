//
//  WODBackgroundLayer.m
//  TOP
//
//  Created by ianluo on 14-1-5.
//  Copyright (c) 2014年 WOD. All rights reserved.
//


#import "WODBackgroundLayer.h"

@interface WODBackgroundLayer()


@end

@implementation WODBackgroundLayer

- (id)init
{
	self = [super init];
	if (self)
	{
		self.delegate = self;
	}
	return self;
}

- (void)fillBackgroundWithColor:(UIColor *)color andPath:(CGPathRef)path
{
	self.fillColor = color;
	self.fillPath = path;
	
	[self setNeedsDisplay];
}

- (void)drawLayer:(CALayer *)layer inContext:(CGContextRef)ctx
{
	CGContextTranslateCTM(ctx, 0, self.bounds.size.height);
    CGContextScaleCTM(ctx, 1.0, -1.0);

	CGContextClearRect(ctx, self.bounds);
	
	switch (self.fillType)
	{
		case FillTypeTransparent:
			if (self.fillColor)
			{
				if (self.fillPath)
					CGContextAddPath(ctx, self.fillPath);
				
				CGContextSetFillColorWithColor(ctx, [self.fillColor colorWithAlphaComponent:0].CGColor);
				CGContextFillPath(ctx);
			}
			break;
			
		case FillTypeHalf:
			if (self.fillColor)
			{
				if (self.fillPath)
					CGContextAddPath(ctx, self.fillPath);
				
				CGContextSetFillColorWithColor(ctx, [self.fillColor colorWithAlphaComponent:0.5].CGColor);
				CGContextFillPath(ctx);
			}
			break;
		
		case FillTypeOpaque:
			if (self.fillColor)
			{
				if (self.fillPath)
					CGContextAddPath(ctx, self.fillPath);
				
				CGContextSetFillColorWithColor(ctx, self.fillColor.CGColor);
				CGContextFillPath(ctx);
			}
			break;
			
		case FillTypeStroke:
			if (self.fillPath)
				CGContextAddPath(ctx, self.fillPath);
			
			CGContextSetLineWidth(ctx, 2);
			CGContextSetStrokeColorWithColor(ctx, self.fillColor.CGColor);
			CGContextStrokePath(ctx);
			
			break;
	}
	
	
	if (self.isShowBorder && self.fillType != FillTypeStroke)
	{
		if (self.fillPath)
			CGContextAddPath(ctx, self.fillPath);
			
		CGContextSetStrokeColorWithColor(ctx, [UIColor grayColor].CGColor);
		CGContextStrokePath(ctx);
	}
}

#pragma mark - CAAction delegate

- (id<CAAction>)actionForLayer:(CALayer *)theLayer forKey:(NSString *)theKey
{
	CATransition *theAnimation=nil;
    if ([theKey isEqualToString:@"contents"])
	{
		theAnimation = [[CATransition alloc] init];
		theAnimation.duration = 0.5;
		theAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn];
		theAnimation.type = kCATransitionFade;
    }
	else if([theKey isEqualToString:@"bounds"]||[theKey isEqualToString:@"position"])
	{
		theAnimation = [[CATransition alloc] init];
        theAnimation.duration =0;
		theAnimation.type = kCATransitionFade;
	}
	
//	NSLog(@"animation name:%@",theKey);
	
    return theAnimation;
}
@end
