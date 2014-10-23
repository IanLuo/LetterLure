//
//  WODOpenGLESDrawable.m
//  TOP
//
//  Created by ianluo on 14-3-13.
//  Copyright (c) 2014年 WOD. All rights reserved.
//

#import "WODOpenGLESDrawable.h"

@implementation WODOpenGLESDrawable
- (id)init
{
	self = [super init];
	if (self)
	{
		self.scale = GLKVector2Make(1.0, 1.0);
		self.rotation = GLKMatrix4Identity;
		self.translation = GLKVector3Make(0.0, 0.0, 1.0);
	}
	return self;
}

@end
