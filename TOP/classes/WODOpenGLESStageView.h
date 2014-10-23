//
//  WODOpenGLESStageView.h
//  TOP
//
//  Created by ianluo on 14-3-9.
//  Copyright (c) 2014年 WOD. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WODTextView.h"
#import "WODTextLayerManager.h"

extern NSString * const kNotificationOpenGLStageViewRebuildComplete;
extern NSString * const kNotificationOpenGLStageViewInitComplete;
@interface WODOpenGLESStageView : UIView

@property (nonatomic, assign)CGSize displaySize;

- (void)setBackgroundImage:(UIImage *)image;
- (void)removeBackgroundImage;
- (void)addTextView:(WODTextView *)textView;
- (void)removeTextView:(WODTextView *)textView;
- (void)selectTextView:(WODTextView *)textView;
- (void)preview;

- (void)updateTextViewTransform:(WODTextView *)textView;

- (void)updateTextViewImage:(WODTextView *)textView;

- (void)userFilter:(NSString *)filterName;

- (UIImage *)snapshotScreen;

- (UIImage *)snapeshotScreenHide:(NSArray *)hideObjs;

- (void)setGrayoutBackground:(BOOL)isGrayout;

- (void)initCAEAGL;

- (void)setupRenderHirarchy;
- (void)tearDownRenderHirarchy;

- (BOOL)isReadyToRender;

@end
