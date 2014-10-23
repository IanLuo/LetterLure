//
//  WODPramaticSufaceQuad.m
//  TOP
//
//  Created by ianluo on 14-3-14.
//  Copyright (c) 2014年 WOD. All rights reserved.
//

#import "WODPramaticSufaceQuad.h"

@implementation WODPramaticSufaceQuad
{
	GLKVector2 m_size;
}

- (id)initWithSize:(CGSize)size
{
	self = [super init];
	if (self)
	{
		m_size = GLKVector2Make(size.width, size.height);
		ParametricInterval interval = { GLKVector2Make(2, 2), GLKVector2Make(1, 1), GLKVector2Make(1, 1) };
        [self setInterval:interval];
	}
	return self;
}

- (GLKVector3)evaluate:(GLKVector2)domain
{
	float x = (domain.x - 0.5) * m_size.x;
	float y = (domain.y - 0.5) * m_size.y;
	float z = 0;
	return GLKVector3Make(x, y, z);
}

@end
