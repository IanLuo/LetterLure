//
//  WODTextConfigureView.h
//  TOP
//
//  Created by ianluo on 14-1-14.
//  Copyright (c) 2014年 WOD. All rights reserved.
//

#import <UIKit/UIKit.h>

@class WODTextConfigureView;

@protocol WODTextConfigureDelegate <NSObject>

- (void)didFinishTextConfigureAlignment:(NSTextAlignment)alignment configureView:(WODTextConfigureView *)configureView;

@end

@interface WODTextConfigureView : UIView

@property (nonatomic,weak) id<WODTextConfigureDelegate> delegate;

@end
