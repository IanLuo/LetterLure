//
//  WODPathDrawView.m
//  TOP
//
//  Created by ianluo on 14-1-3.
//  Copyright (c) 2014年 WOD. All rights reserved.
//

#import "WODPathDrawView.h"
#import "MBProgressHUD.h"

@interface WODPathDrawView()

@property (nonatomic, strong)MBProgressHUD * hud;

@end

@implementation WODPathDrawView

- (id)initWithFrame:(CGRect)frame
{
	if (self = [super initWithFrame:frame])
	{
		self.path = [UIBezierPath bezierPath];
		
		[self.path setLineWidth:5];
		[self.path setLineJoinStyle:kCGLineJoinRound];

		[self setBackgroundColor:[UIColor clearColor]];
		
		[self setAutoresizingMask:UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth];
        
        _hud = [MBProgressHUD showHUDAddedTo:self animated:YES];
        self.hud.mode = MBProgressHUDModeAnnularDeterminate;
	}
	return self;
}

- (void)dealloc
{
#ifdef DEBUGMODE
	NSLog(@"deallocing... %@",[[NSString stringWithUTF8String:__FILE__]lastPathComponent]);
#endif
}

- (void)startAnimation
{
	if(CGPathIsEmpty(self.path.CGPath))
	{
		NSLog(@"invalide path");
		return;
	}
		
	if ([self.delegate respondsToSelector:@selector(didFinishdDrawingPathWithPoints:drawView:)])
	{
		cursor = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 9, 9)];
		[cursor setBackgroundColor:[UIColor clearColor]];
		
		[self addSubview:cursor];
	}
	
	float duration = self.stringLength*3/60.0;
	
	CAKeyframeAnimation *pathAnimation = [CAKeyframeAnimation animationWithKeyPath:@"position"];
	pathAnimation.delegate = self;
	pathAnimation.calculationMode = kCAAnimationPaced;
	pathAnimation.fillMode = kCAFillModeForwards;
	pathAnimation.removedOnCompletion = NO;
	pathAnimation.duration = duration;
	pathAnimation.path = self.path.CGPath;
	pathAnimation.removedOnCompletion = YES;
	
	[cursor.layer addAnimation:pathAnimation forKey:@"position"];
	
	allPoints = [NSMutableArray array];
}

static CFTimeInterval duration = 0.0;
static CFTimeInterval currentTime = 0.0;

- (void)animationDidStart:(CAAnimation *)anim
{
	dl = [CADisplayLink displayLinkWithTarget:self selector:@selector(getCurrentPoint:)];
	[dl addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
		
	cursor.hidden = NO;
	
	duration = anim.duration;
	currentTime = 0.0;
	
}

- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag
{
	[dl invalidate];
	dl = nil;
	
	[cursor removeFromSuperview];
	cursor = nil;
	
	if ([self.delegate respondsToSelector:@selector(didFinishdDrawingPathWithPoints:drawView:)])
	{
		[self.delegate didFinishdDrawingPathWithPoints:allPoints drawView:self];
	}
		
	[allPoints removeAllObjects];
	allPoints = nil;
	
	[self.path removeAllPoints];
	
    [self.hud hide:YES];
}

- (void)getCurrentPoint:(CADisplayLink *)displayLink
{
	CGPoint currentPosition = [(CALayer *)cursor.layer.presentationLayer position] ;
	currentPosition.y = self.bounds.size.height - currentPosition.y;
		
	[allPoints addObject:[NSValue valueWithCGPoint:currentPosition]];
		
	currentTime += dl.duration;
    [self.hud setProgress:currentTime/duration];
}

@end
