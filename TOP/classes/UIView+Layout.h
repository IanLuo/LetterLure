//
//  UIImage+Layout.h
//  TOP
//
//  Created by ian luo on 14/10/18.
//  Copyright (c) 2014年 WOD. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum{
    PLKViewAlignmentTopLeft,
    PLKViewAlignmentTopCenter,
    PLKViewAlignmentTopRight,
    PLKViewAlignmentMiddleLeft,
    PLKViewAlignmentCenter,
    PLKViewAlignmentMiddleRight,
    PLKViewAlignmentBottomLeft,
    PLKViewAlignmentBottomCenter,
    PLKViewAlignmentBottomRight,
} PLKViewAlignment;

@interface UIView(Layout)

@property (nonatomic) CGFloat viewWidth;		//view.frame.size.width
@property (nonatomic) CGFloat viewHeight;		//view.frame.size.height
@property (nonatomic) CGFloat viewX;			//view.frame.origin.x
@property (nonatomic) CGFloat viewY;			//view.frame.origin.y
@property (nonatomic) CGPoint viewOrigin;		//view.frame.origin
@property (nonatomic) CGSize  viewSize;			//view.frame.size
@property (nonatomic) CGFloat viewRightEdge;	//view.frame.origin.x + view.frame.size.width
@property (nonatomic) CGFloat viewBottomEdge;	//view.frame.origin.y + view.frame.size.height

- (CGPoint)boundsCenter;

- (void)frameIntegral;

-(void)align:(PLKViewAlignment)alignment relativeToPoint:(CGPoint)point;
//position the view relative to a rectangle
-(void)align:(PLKViewAlignment)alignment relativeToRect:(CGRect)rect;
@end