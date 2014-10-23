//
//  WODTypeSetterViewController.h
//  TOP
//
//  Created by ianluo on 13-12-13.
//  Copyright (c) 2013年 WOD. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WODTextView.h"
#import "WODOpenGLESStageView.h"

@class WODTypeSetterViewController;
@protocol WODTypeSetterDelegate <NSObject>

- (void)didFinishTypeSetterEdit:(WODTypeSetterViewController *)typeSetterViewController newTextView:(WODTextView *)textView;
- (void)didCancelTypeSetterEdit:(WODTypeSetterViewController *)typeSetterViewController;

@end

@interface WODTypeSetterViewController : UIViewController<UIGestureRecognizerDelegate>

@property (nonatomic, strong)WODTextView * textView;

@property (nonatomic, strong)WODOpenGLESStageView * openGLESStageView;

@property (nonatomic, strong)UIImage * image;

@property (nonatomic, strong)UIView * toolbar;

@property (nonatomic, weak)id<WODTypeSetterDelegate> delegate;

@property (nonatomic, assign)BOOL shouldIgnorGestures;

- (void)layout;

@end
