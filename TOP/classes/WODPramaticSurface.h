//
//  WODPramaticSurface.h
//  TOP
//
//  Created by ianluo on 14-3-14.
//  Copyright (c) 2014年 WOD. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GLKit/GLKit.h>

typedef struct ParametricInterval ParametricInterval;

struct ParametricInterval {
    GLKVector2 Divisions;
    GLKVector2 UpperBound;
    GLKVector2 TextureCount;
};

enum VertexFlags {
    VertexFlagsNormals = 1 << 0,
    VertexFlagsTexCoords = 1 << 1,
};

@interface WODPramaticSurface : NSObject

- (NSInteger)getVertexCount;
- (NSInteger)getLineIndexCount;
- (NSInteger)getTriangleIndexCount;

- (void)generateVertices:(float *)vertices flag:(unsigned char)flags;
- (void)generateLineIndices:(float *)indices;
- (void)generateTriangleIndices:(unsigned short *)indices;

- (void)setInterval:(ParametricInterval)interval;
- (GLKVector3)evaluate:(GLKVector2)domain;
- (BOOL)invertNormal:(GLKVector2)domain;

@end
