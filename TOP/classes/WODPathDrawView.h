//
//  WODPathDrawView.h
//  TOP
//
//  Created by ianluo on 14-1-3.
//  Copyright (c) 2014年 WOD. All rights reserved.
//

#import <UIKit/UIKit.h>

@class WODPathDrawView;
@protocol WODPathDrawViewDelegate <NSObject>

@optional
- (void)didFinishdDrawingPathWithPoints:(NSArray *)points drawView:(WODPathDrawView *)drawView;
- (void)didFinishdDrawingPath:(UIBezierPath *)path drawView:(WODPathDrawView *)drawView;

@end


@interface WODPathDrawView : UIView
{
	UIView * cursor;
	CADisplayLink * dl;
	NSMutableArray * allPoints;
	
}

@property (nonatomic, weak)id<WODPathDrawViewDelegate>delegate;

@property (nonatomic, assign) NSUInteger stringLength;

@property (nonatomic, assign) BOOL autoClosePath;

@property (nonatomic, strong) UIBezierPath * path;

- (void)startAnimation;

@end
