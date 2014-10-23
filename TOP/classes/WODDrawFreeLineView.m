//
//  WODDrawLinerTextPathView.m
//  TextAppPOC
//
//  Created by ianluo on 13-10-29.
//  Copyright (c) 2013年 WOD. All rights reserved.
//

#import "WODDrawFreeLineView.h"

@implementation WODDrawFreeLineView
{
	UIImage * incrementalImage;
	CGPoint pts[5];
	uint ctr;
	
	CGPoint firstPoint;
}

- (void)drawRect:(CGRect)rect
{
	CGContextRef context = UIGraphicsGetCurrentContext();
	CGContextClearRect(context, self.bounds);
	
	CGContextSetStrokeColorWithColor(context, [UIColor grayColor].CGColor);
		
	[self.path stroke];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
	ctr = 0;
    UITouch * touch = [touches anyObject];
	CGPoint point = [touch locationInView:self];
	pts[0] = point;
	[self.path moveToPoint:point];
	firstPoint = point;
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
	UITouch * touch = [touches anyObject];
	CGPoint point = [touch locationInView:self];
	
	ctr++;
	pts[ctr] = point;
	
	if (ctr == 4)
	{
		pts[3] = CGPointMake((pts[2].x + pts[4].x)/2.0, (pts[2].y + pts[4].y)/2.0);
//		[path moveToPoint:pts[0]];
		[self.path addCurveToPoint:pts[3] controlPoint1:pts[1] controlPoint2:pts[2]];
		
		[self setNeedsDisplay];
		pts[0] = pts[3];
		pts[1] = pts[4];
		ctr = 1;
	}
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{

//	[self drawBitmap];
	
	if (self.autoClosePath)
	{
		[self.path closePath];
	}

	
	if ([self.delegate respondsToSelector:@selector(didFinishdDrawingPathWithPoints:drawView:)])
	{
		[self startAnimation];
	}
	
	if([self.delegate respondsToSelector:@selector(didFinishdDrawingPath:drawView:)])
	{
		//flip to user's coordinate, the delegate above have done that in the 'animation complete method'
		CGRect rect = CGPathGetBoundingBox(self.path.CGPath);
		[self.path applyTransform:CGAffineTransformMakeScale(1.0, -1.0)];
		[self.path applyTransform:CGAffineTransformMakeTranslation(0, rect.size.height)];
		
		if ([self.delegate respondsToSelector:@selector(didFinishdDrawingPath:drawView:)])
		{
			[self.delegate didFinishdDrawingPath:self.path drawView:self];
		}
	}

	ctr = 0;
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
	[self touchesEnded:touches withEvent:event];
}

@end
