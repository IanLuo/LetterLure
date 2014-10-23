//
//  WODRenderingEngine.h
//  TOP
//
//  Created by ianluo on 14-3-13.
//  Copyright (c) 2014年 WOD. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GLKit/GLKit.h>
#import "WODOpenGLESDrawable.h"

typedef struct RenderEnviroment RenderEnviroment;
typedef struct RenderMode RenderMode;
typedef enum Destination Destination;

enum Destination
{
	OnScreen = 0,
	OffScreen,
};

struct RenderEnviroment
{
	CGSize viewportSize;
	CGPoint viewportOrigin;
	CGSize snapshotSize;
};

struct RenderMode
{
	CGPoint scale;
	Destination destination;
};

@interface WODRenderingEngine : NSObject

@property (nonatomic, assign)BOOL needRender;

- (void)setBackgroundColor:(UIColor *)color;

- (void)initialize;
- (void)setEnviroment:(RenderEnviroment)enviroment;
- (void)render:(RenderMode)mode;

- (void)createRenderBuffers;
- (void)deleteRenderBuffers;
- (void)createRenderBuffersOffscreen:(CGSize)size;
- (void)createFramebuffers;
- (void)deleteFramebuffers;

- (void)createDrawingElement:(WODOpenGLESDrawable *)drawable;
- (void)removedDrawingElement:(WODOpenGLESDrawable *)drawable;
- (void)updateElementImage:(WODOpenGLESDrawable *)drawable;

- (void)updateElementTransform:(WODOpenGLESDrawable *)drawable;

- (void)unHighlight;
- (void)highlightElement:(NSUInteger)name;

- (UIImage *)snapshot:(CGFloat)scale;
- (UIImage *)snapshotHide:(NSArray *)hideObjs;

- (void)setGrayoutBackground:(BOOL)isGrayout;

- (void)userFilter:(NSString *)filterName;

@end
