//
//  WODOpenGLESDrawable.h
//  TOP
//
//  Created by ianluo on 14-3-13.
//  Copyright (c) 2014年 WOD. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GLKit/GLKit.h>
#import "WODPramaticSurface.h"

@interface WODOpenGLESDrawable : NSObject

@property (nonatomic, assign) GLKVector2 scale;
@property (nonatomic, assign) GLKVector3 translation;
@property (nonatomic, assign) CGRect frame;
@property (nonatomic, assign) GLKMatrix4 rotation;
@property (nonatomic, weak) CALayer * dataLayer;
@property (nonatomic, strong) UIImage * image;
@property (nonatomic, assign) NSInteger name;
@property (nonatomic, strong) WODPramaticSurface * surface;
@property (nonatomic, strong) NSNumber * alpha;

@end
