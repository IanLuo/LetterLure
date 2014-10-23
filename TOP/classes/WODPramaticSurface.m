//
//  WODPramaticSurface.m
//  TOP
//
//  Created by ianluo on 14-3-14.
//  Copyright (c) 2014年 WOD. All rights reserved.
//

#import "WODPramaticSurface.h"

@interface WODPramaticSurface()
{
	GLKVector2 m_slices;
	GLKVector2 m_divisions;
	GLKVector2 m_upperBound;
	GLKVector2 m_textureCount;
}

@end

@implementation WODPramaticSurface

- (GLKVector2)computeDomain:(float)x y:(float)y
{
	return GLKVector2Make(x * m_upperBound.x / m_slices.x, y * m_upperBound.y / m_slices.y);
}

- (void)setInterval:(ParametricInterval)interval
{
    m_divisions = interval.Divisions;
    m_upperBound = interval.UpperBound;
    m_textureCount = interval.TextureCount;
    m_slices = GLKVector2Subtract(m_divisions, GLKVector2Make(1, 1));
}

- (NSInteger)getVertexCount
{
    return m_divisions.x * m_divisions.y;
}

- (NSInteger)getLineIndexCount
{
    return 4 * m_slices.x * m_slices.x;
}

- (NSInteger)getTriangleIndexCount
{
    return 6 * m_slices.x * m_slices.y;
}

- (void)generateVertices:(float *)verticesIn flag:(unsigned char)flags
{
	int idx = 0;
    for (int j = 0; j < m_divisions.y; j++) {
        for (int i = 0; i < m_divisions.x; i++) {
            // Compute Position
            GLKVector2 domain = [self computeDomain:i y:j];
            GLKVector3 range = [self evaluate:domain];
			
			verticesIn[idx++] = range.x;
			verticesIn[idx++] = range.y;
			verticesIn[idx++] = range.z;
			
            // Compute Normal
            if (flags & VertexFlagsNormals) {
                float s = i, t = j;
				
                // Nudge the point if the normal is indeterminate.
                if (i == 0) s += 0.01f;
                if (i == m_divisions.x - 1) s -= 0.01f;
                if (j == 0) t += 0.01f;
                if (j == m_divisions.y - 1) t -= 0.01f;
                
                // Compute the tangents and their cross product.
                GLKVector3 p = [self evaluate:[self computeDomain:s y:t]];
                GLKVector3 u = GLKVector3Subtract([self evaluate:[self computeDomain:s + 0.01f y:t]], p);
                GLKVector3 v = GLKVector3Subtract([self evaluate:[self computeDomain:s y:t + 0.01f]], p);
                GLKVector3 normal = GLKVector3Normalize(GLKVector3CrossProduct(u, v));
                if ([self invertNormal:domain])
                    normal = GLKVector3Make(-normal.x, -normal.y, -normal.z);
					
				verticesIn[idx++] = normal.x;
				verticesIn[idx++] = normal.y;
				verticesIn[idx++] = normal.z;
            }
            
            // Compute Texture Coordinates
            if (flags & VertexFlagsTexCoords) {
                float s = m_textureCount.x * i / m_slices.x;
                float t = m_textureCount.y * j / m_slices.y;
				
                verticesIn[idx++] = s;
				verticesIn[idx++] = t;
            }
        }
    }
}

- (void)generateLineIndices:(float *)indicesIn
{
    float indices[[self getLineIndexCount]];
	indicesIn = indices;
	
	int index = 0;
    for (int j = 0, vertex = 0; j < m_slices.y; j++) {
        for (int i = 0; i < m_slices.x; i++) {
            int next = (i + 1) % (int)m_divisions.x;
            indices[index++] = vertex + i;
            indices[index++] = vertex + next;
            indices[index++] = vertex + i;
            indices[index++] = vertex + i + m_divisions.x;
        }
        vertex += m_divisions.x;
    }
}

- (void)generateTriangleIndices:(unsigned short *)indicesIn
{	
	int index = 0;
    for (int j = 0, vertex = 0; j < m_slices.y; j++) {
        for (int i = 0; i < m_slices.x; i++) {
            int next = (i + 1) % (int)m_divisions.x;
            indicesIn[index++] = vertex + i;
            indicesIn[index++] = vertex + next;
            indicesIn[index++] = vertex + i + m_divisions.x;
            indicesIn[index++] = vertex + next;
            indicesIn[index++] = vertex + next + m_divisions.x;
            indicesIn[index++] = vertex + i + m_divisions.x;
        }
        vertex += m_divisions.x;
    }
}

- (GLKVector3)evaluate:(GLKVector2)range
{
	return GLKVector3Make(0, 0, 0);
}

- (BOOL)invertNormal:(GLKVector2)domain
{
	return false;
}
@end
