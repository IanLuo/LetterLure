//
//  WODTransformEngine.h
//  TOP
//
//  Created by ianluo on 14-3-18.
//  Copyright (c) 2014年 WOD. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GLKit/GLKit.h>

typedef enum TransformationState
{
    S_NEW,
    S_SCALE,
    S_TRANSLATION,
    S_ROTATION
}TransformationState;

@interface WODTransformEngine : NSObject

@property (readwrite) TransformationState state;

- (id)initWithDepth:(float)z Scale:(float)s Translation:(GLKVector2)t Rotation:(GLKVector3)r;
- (void)start;
- (void)scale:(float)s;
- (void)translate:(GLKVector2)t withMultiplier:(float)m;
- (void)rotate:(GLKVector3)r withMultiplier:(float)m;
- (GLKMatrix4)getModelViewMatrix;

- (CGFloat)getScale;
- (GLKVector3)getTranslation;
- (GLKMatrix4)getRotation;
- (void)restore;

//- (WODTransformEngine *)copy;

@end
