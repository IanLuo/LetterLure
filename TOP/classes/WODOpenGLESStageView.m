//
//  WODOpenGLESStageView.m
//  TOP
//
//  Created by ianluo on 14-3-9.
//  Copyright (c) 2014年 WOD. All rights reserved.
//

#import "WODOpenGLESStageView.h"
#import "WODTextLayerManager.h"
#import "WODOpenGLESAppEngine.h"

NSString * const kNotificationOpenGLStageViewRebuildComplete = @"kNotificationOpenGLStageViewRebuildComplete";
NSString * const kNotificationOpenGLStageViewInitComplete = @"kNotificationOpenGLStageViewInitComplete";

@interface WODOpenGLESStageView()
{
	EAGLContext * m_context;
	
    float m_timestamp;
	
	BOOL inited;
	
	CADisplayLink * displayLink;
	
	BOOL rotated;
}

@property (nonatomic, strong) WODOpenGLESAppEngine* appEngine;

@end

@implementation WODOpenGLESStageView

- (WODOpenGLESAppEngine *)appEngine
{
	if (!_appEngine)
	{
		_appEngine = [WODOpenGLESAppEngine new];
	}
	return _appEngine;
}

+(Class)layerClass
{
	return [CAEAGLLayer class];
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
	{
		inited = NO;
		rotated = NO;
		EAGLRenderingAPI api = kEAGLRenderingAPIOpenGLES2;
		m_context = [[EAGLContext alloc] initWithAPI:api];
		
		[[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(deviceRotated:) name:UIApplicationDidChangeStatusBarOrientationNotification object:nil];
    }
    return self;
}

- (void)dealloc
{
	[[NSNotificationCenter defaultCenter]removeObserver:self];
#ifdef DEBUGMODE
	NSLog(@"deallocing %@...",[[NSString stringWithUTF8String: __FILE__] lastPathComponent]);
#endif
}

- (void)layoutSubviews
{
	[super layoutSubviews];
	
	//frame will be available here
	[self initCAEAGL];
	
	[super layoutSubviews];
	
	if (rotated)
	{
		if(self.isReadyToRender)
		{
			[self tearDownRenderHirarchy];
			[self setupRenderHirarchy];
			
			rotated = NO;
			[[NSNotificationCenter defaultCenter]postNotificationName:kNotificationOpenGLStageViewRebuildComplete object:nil userInfo:nil];
		}
	}
}

- (void)deviceRotated:(NSNotification *)notification
{
	rotated = YES;
}

- (void)initCAEAGL
{
	CAEAGLLayer* eaglLayer = (CAEAGLLayer*) self.layer;
	eaglLayer.drawableProperties = @{kEAGLDrawablePropertyRetainedBacking: [NSNumber numberWithBool:YES],
									 kEAGLDrawablePropertyColorFormat: kEAGLColorFormatRGBA8};
	eaglLayer.opaque = NO;
	
	float scale = [UIScreen mainScreen].scale;
	self.contentScaleFactor = scale;
	eaglLayer.contentsScale = scale;
			
	[self setupRenderHirarchy];
	
	[[NSNotificationCenter defaultCenter]postNotificationName:kNotificationOpenGLStageViewInitComplete object:nil];
}

- (void)setupRenderHirarchy
{
	if (inited)
		return;
		
	if (!m_context || ![EAGLContext setCurrentContext:m_context])
	{
		NSLog(@"can't init context for EAGLLayer");
		return;
	}
	
	[self.appEngine createRenderBuffers];
	[m_context renderbufferStorage:GL_RENDERBUFFER fromDrawable: (CAEAGLLayer*)self.layer];
	[self.appEngine createFrameBuffers:self.frame.size];
	
	displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(drawView:)];
	[displayLink addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
	[self drawView:nil];
	
	inited = YES;
}

- (void)tearDownRenderHirarchy
{
	[displayLink removeFromRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
	[displayLink invalidate];
	displayLink = nil;
	
	[self.appEngine deleteRenderBuffers];
	[self.appEngine deleteFrameBuffers];
		
	inited = NO;
}

- (void)drawView:(CADisplayLink *)displayLink
{
	[self.appEngine renderView];
	[m_context presentRenderbuffer:GL_RENDERBUFFER];
}

- (BOOL)isReadyToRender
{
	return inited;
}

- (void)setBackgroundColor:(UIColor *)backgroundColor
{
	[super setBackgroundColor:backgroundColor];
	
	if ([self isReadyToRender])
	{
		[self.appEngine setBackgroundColor:backgroundColor];
	}
}

- (void)userFilter:(NSString *)filterName
{
	[self.appEngine userFilter:filterName];
}

#pragma mark - manage text view
- (void)addTextView:(WODTextView *)textView
{
	[self.appEngine addTextView:textView];
}
- (void)removeTextView:(WODTextView *)textView
{
	[self.appEngine removeTextView:textView];
}
- (void)selectTextView:(WODTextView *)textView
{
	[self.appEngine selectTextView:textView];
}

- (void)updateTextViewImage:(WODTextView *)textView
{
	[self.appEngine updateTextViewImage:textView];
}

- (void)setBackgroundImage:(UIImage *)image
{
	if (image == nil || image.CGImage == NULL)
		return;
	else
	{
		float scale = [UIScreen mainScreen].scale;
		UIImage * resizedImage = [WODConstants resizeImage:image fitSize:CGSizeApplyAffineTransform(self.bounds.size, CGAffineTransformMakeScale(scale, scale))];
		[self.appEngine setBackgroundImage:resizedImage];
		self.displaySize = CGSizeApplyAffineTransform(resizedImage.size, CGAffineTransformMakeScale(resizedImage.scale, resizedImage.scale));
	}
}

- (void)removeBackgroundImage
{
	[self.appEngine removeBackgroundImage];
}

- (void)preview
{
	[self.appEngine preview];
}

#pragma mark - handle touch

- (void)updateTextViewTransform:(WODTextView *)textView
{
	[self.appEngine updateTextViewTransform:textView];
}

- (UIImage *)snapshotScreen
{
	return [self.appEngine snapScreen];
}

- (UIImage *)snapeshotScreenHide:(NSArray *)hideObjs
{
	return [self.appEngine snapScreenHide:hideObjs];
}

- (void)setGrayoutBackground:(BOOL)isGrayout
{
	[self.appEngine setGrayoutBackground:isGrayout];
}

@end
