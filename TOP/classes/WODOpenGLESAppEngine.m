//
//  WODOpenGLESAppEngine.m
//  TOP
//
//  Created by ianluo on 14-3-13.
//  Copyright (c) 2014年 WOD. All rights reserved.
//

#import "WODOpenGLESAppEngine.h"
#import <GLKit/GLKit.h>
#import "WODRenderingEngine.h"
#import "WODPramaticSufaceQuad.h"

@interface WODOpenGLESAppEngine()

@property (nonatomic, strong) WODRenderingEngine * renderingEngine;
@property (nonatomic, assign) NSUInteger selectedTextName;

@end

@implementation WODOpenGLESAppEngine
{
	CGSize initSize;
	RenderMode mode;
}

- (id)init
{
	self = [super init];
	
    if(self)
	{
		contentScale = [UIScreen mainScreen].scale;
		mode.scale = CGPointMake(1.0, 1.0);
	}
	return self;
}

#pragma mark - *** Public ***

#pragma mark - *** Initialize & dealloc *** -
/*
Create the renderbuffers for the rendering engine
*/
- (void)createRenderBuffers
{
	[self.renderingEngine createRenderBuffers];
}

- (void)createRenderBuffersForOffscreen:(CGSize)size
{
	[self.renderingEngine createRenderBuffersOffscreen:size];
	mode.destination = OffScreen;
}

- (void)dealloc
{
    WODDebug(@"deallocing..");
}

/*
Create framebuffer based on the render buffer's size, and attach the renderbuffers(colorbuffer, depthbuffer etc) to the framebuffer.
Set the viewport, and snapshot viewport(snapshot may only take part of the whole view)
*/
- (void)createFrameBuffers:(CGSize)size;
{
	initSize = size;
	mode.scale = CGPointMake(1.0, 1.0);
	
    [self.renderingEngine setEnviroment:[self createRenderEnviroment:size andOrigin:CGPointZero]];
	[self.renderingEngine initialize];
}

/*

*/
- (void)deleteFrameBuffers
{
	[self.renderingEngine deleteFramebuffers];
}

- (void)deleteRenderBuffers
{
	[self.renderingEngine deleteRenderBuffers];
}

#pragma mark -

- (void)addTextView:(WODTextView *)textView
{
	__block WODOpenGLESDrawable * newDrawable = [WODOpenGLESDrawable new];
	newDrawable.name = textView.name;
	
	newDrawable.scale = GLKVector2Make(textView.transformEngine.getScale, textView.transformEngine.getScale);
	newDrawable.translation = textView.transformEngine.getTranslation;
	newDrawable.rotation = textView.transformEngine.getRotation;
	newDrawable.alpha = textView.alpha;
	
	if (self.isFullSizeRender)
	{
		newDrawable.scale = GLKVector2Make(newDrawable.scale.x, newDrawable.scale.y);
        
        ws(wself);
		[textView generateFullSizeImageScale:self.fullSizeScale Complete:^(UIImage *image) {
			
            float imageScale = image.scale;
			float screenScale = contentScale;
			
			CGSize size = CGSizeMake(image.size.width * imageScale / screenScale, image.size.height * imageScale / screenScale);
			newDrawable.surface = [[WODPramaticSufaceQuad alloc]initWithSize:CGSizeMake(size.width/initSize.height, size.height/initSize.height)];
			newDrawable.frame = CGRectMake(0, 0, size.width, size.height);
			
			newDrawable.image = image;
			[wself.renderingEngine createDrawingElement:newDrawable];
		}];
	}
	else
	{
        ws(wself);
		[textView displayTextHideFeatures:textView.hideFeatures complete:^(UIImage *image) {
			float imageScale = image.scale;
			float screenScale = contentScale;
			
			CGSize size = CGSizeMake(image.size.width * imageScale / screenScale, image.size.height * imageScale / screenScale);
			newDrawable.surface = [[WODPramaticSufaceQuad alloc]initWithSize:CGSizeMake(size.width/initSize.height, size.height/initSize.height)];
			newDrawable.frame = CGRectMake(0, 0, size.width * screenScale, size.height * screenScale);
			
			newDrawable.image = image;
			[wself.renderingEngine createDrawingElement:newDrawable];
		}];
	}
}

- (void)removeTextView:(WODTextView *)textView
{
	// remove the current text view drawing object, along with it's rendering resources
	WODOpenGLESDrawable * drawable = [WODOpenGLESDrawable new];
	drawable.name = textView.name;
	
	[self.renderingEngine removedDrawingElement:drawable];
}

// when change the text, typesetter or effect, any change will effect the generation of text image other than transforms
// 1. text change
// 2. effect change
// 3. typesetter change
- (void)updateTextViewImage:(WODTextView *)textView
{
	__block WODOpenGLESDrawable * updateDrawable = [WODOpenGLESDrawable new];
	updateDrawable.name = textView.name;
	updateDrawable.alpha = textView.alpha;
	
    ws(wself);
	[textView displayTextHideFeatures:textView.hideFeatures complete:^(UIImage *image) {
		
        float imageScale = image.scale;
		float screenScale = contentScale;
		CGSize size = CGSizeMake(image.size.width * imageScale / screenScale, image.size.height * imageScale / screenScale);
		
		updateDrawable.surface = [[WODPramaticSufaceQuad alloc]initWithSize:CGSizeMake(size.width/initSize.height, size.height/initSize.height)];
		updateDrawable.frame = CGRectMake(0, 0, size.width * screenScale, size.height * screenScale);
		updateDrawable.image = image;
		[wself.renderingEngine updateElementImage:updateDrawable];
	
    }];
}

- (void)selectTextView:(WODTextView *)textView
{
	self.selectedTextName = textView.name;
	[self.renderingEngine highlightElement:self.selectedTextName];
}

- (void)preview
{
	[self.renderingEngine unHighlight];
}

- (void)removeBackgroundImage
{
	WODOpenGLESDrawable * drawable = [WODOpenGLESDrawable new];
	drawable.name = -1;
	[self.renderingEngine removedDrawingElement:drawable];
}

- (void)setBackgroundImage:(UIImage *)image
{
	WODOpenGLESDrawable * newDrawable = [WODOpenGLESDrawable new];
	float imageScale = image.scale;
	float screenScale = contentScale;
	CGSize size = CGSizeMake(image.size.width * imageScale / screenScale, image.size.height * imageScale / screenScale);

	newDrawable.frame = CGRectMake(0, 0, size.width * screenScale, size.height * screenScale);
	newDrawable.image = image;
	newDrawable.name = -1; // indicate this is the background image
	newDrawable.surface = [[WODPramaticSufaceQuad alloc]initWithSize:CGSizeMake(size.width * 2/initSize.height, size.height * 2/initSize.height)];
		
	[self.renderingEngine createDrawingElement:newDrawable];
}

- (void)userFilter:(NSString *)filterName
{
	[self.renderingEngine userFilter:filterName];
}

/*
 Perform the touch action
 */

- (void)updateTextViewTransform:(WODTextView *)textView
{
	WODOpenGLESDrawable * drawable = [WODOpenGLESDrawable new];
	drawable.scale = GLKVector2Make(textView.transformEngine.getScale, textView.transformEngine.getScale);
	drawable.translation = textView.transformEngine.getTranslation;
	drawable.rotation = textView.transformEngine.getRotation;
	drawable.name = textView.name;
	drawable.alpha = textView.alpha;
	
	[self.renderingEngine updateElementTransform:drawable];
}

#pragma mark -
/*
 Perform the render action
*/
- (void)renderView
{
	[self.renderingEngine render:mode];
}

- (UIImage *)snapScreen
{
	return [self.renderingEngine snapshot:1.0];
}

- (UIImage *)snapScreenHide:(NSArray *)hideObjs
{
	return [self.renderingEngine snapshotHide:hideObjs];
}

- (void)setGrayoutBackground:(BOOL)isGrayout
{
	[self.renderingEngine setGrayoutBackground:isGrayout];
}

- (void)setBackgroundColor:(UIColor *)color
{
	[self.renderingEngine setBackgroundColor:color];
}

#pragma mark - *** Private ***

#pragma mark - ** Helper ** -

- (WODRenderingEngine *)renderingEngine
{
	if (!_renderingEngine)
	{
		_renderingEngine = [WODRenderingEngine new];
	}
	
    return _renderingEngine;
}

- (RenderEnviroment)createRenderEnviroment:(CGSize)size andOrigin:(CGPoint)o
{
	RenderEnviroment enviroment;
	enviroment.viewportOrigin = CGPointMake(0, 0);
	enviroment.viewportSize = CGSizeApplyAffineTransform(size, CGAffineTransformMakeScale(contentScale, contentScale));
	
	return enviroment;
}

@end
