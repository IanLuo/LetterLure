//
//  WODOpenGLESAppEngine.h
//  TOP
//
//  Created by ianluo on 14-3-13.
//  Copyright (c) 2014年 WOD. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WODTextView.h"

@interface WODOpenGLESAppEngine : NSObject
{
@public
	CGFloat contentScale;
}

@property (nonatomic, assign)CGFloat fullSizeScale;
@property (nonatomic, assign)BOOL isFullSizeRender;

- (void)addTextView:(WODTextView *)textView;
- (void)removeTextView:(WODTextView *)textView;
- (void)updateTextViewImage:(WODTextView *)textView;

- (void)selectTextView:(WODTextView *)textView;

- (void)preview;

- (void)setBackgroundImage:(UIImage *)image;

- (void)createRenderBuffers;
- (void)deleteRenderBuffers;

- (void)createRenderBuffersForOffscreen:(CGSize)size;

- (void)createFrameBuffers:(CGSize)size;
- (void)deleteFrameBuffers;

- (void)renderView;

- (UIImage *)snapScreen;

- (UIImage *)snapScreenHide:(NSArray *)hideObjs;

- (void)setGrayoutBackground:(BOOL)isGrayout;

- (void)setBackgroundColor:(UIColor *)color;
- (void)removeBackgroundImage;

- (void)userFilter:(NSString *)filterName;

#pragma mark transform

- (void)updateTextViewTransform:(WODTextView *)textView;

@end
