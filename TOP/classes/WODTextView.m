//
//  WODTextView.m
//  TOP
//
//  Created by ianluo on 13-12-12.
//  Copyright (c) 2013年 WOD. All rights reserved.
//

#import "WODTextView.h"
#import <QuartzCore/QuartzCore.h>
#import <CoreImage/CoreImage.h>
#import "WODEffect.h"
#import "WODTextViewTextLayerDelegate.h"
#import "SVProgressHUD.h"
#import "WODConstants.h"


@interface WODTextView()
//
@property (nonatomic, strong) WODTextViewTextLayerDelegate * textLayerDelegate;

@end

@implementation WODTextView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
		_pathScaleFactor = 1.0;
		
		_transformEngine = [[WODTransformEngine alloc]initWithDepth:1.0f Scale:1.0f Translation:GLKVector2Make(0.0f, 0.0f) Rotation:GLKVector3Make(0.0f, 0.0f, 0.0f)];
				
		[self addObserver:self forKeyPath:@"layoutProvider" options:0 context:nil];
		[self addObserver:self forKeyPath:@"effectProvider" options: 0 context:nil];
		[self addObserver:self forKeyPath:@"hideFeatures" options: NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld context:nil];
		[self addObserver:self forKeyPath:@"text" options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld context:nil];

		isRendering = NO;
		self.alpha = @(1.0);
    }
    return self;
}

- (void)dealloc
{
#ifdef DEBUGMODE
NSLog(@"deallocing... %@",[[NSString stringWithUTF8String:__FILE__]lastPathComponent]);
#endif

	[self removeObserver:self forKeyPath:@"layoutProvider"];
	[self removeObserver:self forKeyPath:@"effectProvider"];
	[self removeObserver:self forKeyPath:@"hideFeatures"];
	[self removeObserver:self forKeyPath:@"text"];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
	if ([keyPath isEqualToString:@"layoutProvider"]||[keyPath isEqualToString:@"effectProvider"])
	{
		self.needGenerateImage = YES;
	}
	else if([keyPath isEqualToString:@"hideFeatures"]||[keyPath isEqualToString:@"text"])
	{
		if([change valueForKey:NSKeyValueChangeNewKey] != [change valueForKey:NSKeyValueChangeOldKey])
			self.needGenerateImage = YES;
	}
}

- (WODTextViewTextLayerDelegate *)textLayerDelegate
{
	if (!_textLayerDelegate)
	{
		_textLayerDelegate = [WODTextViewTextLayerDelegate new];
		_textLayerDelegate.textView = self;
	}
	return _textLayerDelegate;
}

- (WODTextView *)copyOfThisTextView
{
	WODTextView * newCopy = [[WODTextView alloc]initWithFrame:self.frame];
	[newCopy setText:self.text];
	[newCopy setLayoutProvider:self.layoutProvider];
	[newCopy setEffectProvider:self.effectProvider];
	
	[newCopy setLayoutShapPath:self.layoutShapPath];
	[newCopy setCurrentTypeSet:self.currentTypeSet];
	[newCopy setPathScaleFactor:self.pathScaleFactor];
	[newCopy setAlpha:self.alpha];
	
	newCopy.name = self.name;
	
	newCopy.transformEngine = self.transformEngine;
	
	return newCopy;
}

- (void)setName:(NSUInteger)name
{
	_name = name;
	self.cacheKey = [NSString stringWithFormat:@"textView_%lu",(unsigned long)self.name];
	[WODConstants removeImageCacheWithKey:self.cacheKey];
}

- (void)displayTextHideFeatures:(BOOL)hideFeatures
{
	[self displayTextHideFeatures:hideFeatures complete:nil];
}

static BOOL isRendering;
static id semaphore;

- (void)displayTextHideFeatures:(BOOL)h complete:(void(^)(UIImage * image))action
{
	semaphore = [NSObject new];
	@synchronized(semaphore)
	{
		if (!isRendering)
		{
			isRendering = YES;
			
			self.hideFeatures = h;
			
			if (self.currentTypeSet == TypesetShapePath)
			{
				[self updateViewForShapeTypeset];
			}
			
			if (h)
			{
				UIImage * image = [self.textLayerDelegate renderImage];
				if (action)
				{
					action(image);
				}
				
				isRendering = NO;
			}
			else
			{
				[SVProgressHUD showProgress:-1 status:NSLocalizedString(@"EFFECT_HUD_APPLYING_EFFECT", nil)];
				__weak typeof(self) wSelf = self;
				
				dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
					UIImage * image = [wSelf.textLayerDelegate renderImage];
					isRendering = NO;
					
					dispatch_async(dispatch_get_main_queue(), ^{
						[SVProgressHUD dismiss];
						if (action)
						{
							action(image);
						}
					});
				});
			}
		}
	}
}

- (void)generateFullSizeImageScale:(CGFloat)scale Complete:(void(^)(UIImage * image))action
{
	UIImage * image = [self.textLayerDelegate renderFullSizeImage:scale];
	isRendering = NO;
	if (action)
	{
		action(image);
	}
}

- (void)applyShapePath:(UIBezierPath *)path
{
	[self restoreShape];
		
	[self setCurrentTypeSet:TypesetShapePath];
	[self setLayoutShapPath:[path CGPath]];
}

- (void)restoreShape
{
	self.pathScaleFactor = 1.0;
}

- (void)updateViewForShapeTypeset
{
	CGPathRef newPath = [self newScaledPath];
	CGRect rect = CGPathGetBoundingBox(newPath);
	
	CGAffineTransform transfrom = CGAffineTransformMakeTranslation(-rect.origin.x, -rect.origin.y);
	
	CGPathRef mPath = CGPathCreateCopyByTransformingPath(self.layoutShapPath, &transfrom);
	self.layoutShapPath = mPath;
	CGPathRelease(mPath);
	
	[self setBounds:CGRectMake(0, 0, rect.size.width, rect.size.height)];
	
	CGPathRelease(newPath);
}

- (CGPathRef)newScaledPath
{
	CGRect rect = CGPathGetBoundingBox(self.layoutShapPath);
	CGPoint center = CGPointMake(CGRectGetMidX(rect), CGRectGetMidY(rect));
	CGAffineTransform scaleTranform = CGAffineTransformScale(CGAffineTransformMakeTranslation(center.x, center.y),self.pathScaleFactor, self.pathScaleFactor);
	CGAffineTransform movebackTransfrom = CGAffineTransformTranslate(scaleTranform, -center.x, -center.y);
	CGPathRef newPath = CGPathCreateCopyByTransformingPath(self.layoutShapPath, &movebackTransfrom);
	
	return newPath;
}

#pragma mark - private

- (CGPathRef)layoutShapPath
{
	if (!_layoutShapPath)
	{
		CGMutablePathRef rectPath = CGPathCreateMutable();
		CGPathMoveToPoint(rectPath, NULL, 0, 0);
		CGPathAddLineToPoint(rectPath, NULL, self.bounds.size.width, 0);
		CGPathAddLineToPoint(rectPath, NULL, self.bounds.size.width, self.bounds.size.height);
		CGPathAddLineToPoint(rectPath, NULL, 0, self.bounds.size.height);
		CGPathCloseSubpath(rectPath);
		_layoutShapPath = rectPath;
	}
	return _layoutShapPath;
}

- (void)resetLayoutShapePath
{
	self.layoutShapPath = nil;
}

@end