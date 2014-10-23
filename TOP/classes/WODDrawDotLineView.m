//
//  WODDrawDotLineView.m
//  TOP
//
//  Created by ianluo on 14-1-3.
//  Copyright (c) 2014年 WOD. All rights reserved.
//

#import "WODDrawDotLineView.h"
#import "WODButton.h"

@implementation WODDrawDotLineView
{
	UIImage * incrementalImage;
	CGPoint lastPoint;
	UIBezierPath * newLine;
}

- (id)initWithFrame:(CGRect)frame
{
	self = [super initWithFrame:frame];
	
	if (self)
	{
		WODButton * closePathButton = [WODButton new];
		[closePathButton setStyle:WODButtonStyleCircle];
		[closePathButton setImage:[[UIImage imageNamed:@"check_mark"]imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
		[closePathButton setTranslatesAutoresizingMaskIntoConstraints:NO];
		[closePathButton addTarget:self action:@selector(completePath) forControlEvents:UIControlEventTouchUpInside];
		[self addSubview:closePathButton];
		
		float toolbarHeight = HEIGHT_TOOLBAR_PORTRAIT + 8;
		UIInterfaceOrientation orientation = [[UIApplication sharedApplication]statusBarOrientation];
		if (UI_USER_INTERFACE_IDIOM()==UIUserInterfaceIdiomPhone)
			toolbarHeight = orientation == UIInterfaceOrientationPortrait || orientation == UIInterfaceOrientationPortraitUpsideDown ? HEIGHT_TOOLBAR_PORTRAIT + 8 : HEIGHT_TOOLBAR_LANDSCAPE + 8;
		
		[self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"[closePathButton(size)]-8-|" options:0 metrics:@{@"size":@(control_button_size)} views:@{@"closePathButton":closePathButton}]];
		[self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[closePathButton(size)]|" options:0 metrics:@{@"toolbarHeight":@(toolbarHeight),@"size":@(control_button_size)} views:@{@"closePathButton":closePathButton}]];
	}
	
	return self;
}

- (void)drawRect:(CGRect)rect
{
	CGContextRef context = UIGraphicsGetCurrentContext();
	CGContextClearRect(context, self.bounds);
	
	CGContextSetStrokeColorWithColor(context, [UIColor grayColor].CGColor);
	
	[newLine stroke];
	[self.path stroke];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
	UITouch * touch = [touches anyObject];
	CGPoint point = [touch locationInView:self];
	
	if (CGPointEqualToPoint(lastPoint, CGPointZero))
	{
		lastPoint = point;
		[self.path moveToPoint:point];
	}
	else
	{
		newLine = [UIBezierPath bezierPath];
		[newLine setLineWidth:5];
		[newLine setLineJoinStyle:kCGLineJoinRound];
		[newLine moveToPoint:lastPoint];
		[newLine addLineToPoint:point];
		[self setNeedsDisplay];
	}
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
	UITouch * touch = [touches anyObject];
	CGPoint point = [touch locationInView:self];

	newLine = [UIBezierPath bezierPath];
	[newLine setLineWidth:5];
	[newLine setLineJoinStyle:kCGLineJoinRound];
	[newLine moveToPoint:lastPoint];
	[newLine addLineToPoint:point];
	
	[self setNeedsDisplay];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
	UITouch * touch = [touches anyObject];
	CGPoint point = [touch locationInView:self];

	lastPoint = point;
	[self.path addLineToPoint:point];
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
	[self touchesEnded:touches withEvent:event];
}


- (void)completePath
{
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
		CGRect rect = CGPathGetBoundingBox(self.path.CGPath);
		
		[self.path applyTransform:CGAffineTransformMakeScale(1.0, -1.0)];
		[self.path applyTransform:CGAffineTransformMakeTranslation(0, rect.size.height)];
		[self.delegate didFinishdDrawingPath:self.path drawView:self];
	}
}

@end
