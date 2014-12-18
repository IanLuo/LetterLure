//
//  WODFreeLayout.m
//  TOP
//
//  Created by ianluo on 14-1-3.
//  Copyright (c) 2014年 WOD. All rights reserved.
//

#import "WODFreeLayout.h"

@interface WODFreeLayout()

@end

@implementation WODFreeLayout

- (NSArray *)textview:(WODTextView *)textview positionForCharacters:(NSAttributedString *)aString glyphInfo:(NSDictionary *)info
{
	NSMutableArray * cPositions = [NSMutableArray array];
	
	NSArray * glyphsBounds = [info objectForKey:@"glyphsBounds"];
	
	CGFloat totalStringSizeLength = 0;
	for (int i = 0; i < glyphsBounds.count; i++)
	{
		totalStringSizeLength += [(NSValue*)glyphsBounds[i] CGRectValue].size.width;
	}

    WODDebug(@"----->(%d)\n",(int)self.allPoints.count);

	CGRect glyphMatrix;
	
	CGFloat lengthToCurrentGlypy = 0.0;
	NSUInteger position = 0;
	
	for (NSValue * glyphMatrixValue in glyphsBounds)
	{
		glyphMatrix = [glyphMatrixValue CGRectValue];
		
		lengthToCurrentGlypy += glyphMatrix.size.width;
		
		position = (lengthToCurrentGlypy - glyphMatrix.size.width/2) / totalStringSizeLength * self.allPoints.count - 0.5;// (0.5 = +0.5 - 1) index of array
		
		CGPoint centerPoint = [(NSValue*)self.allPoints[position] CGPointValue];
		CGPoint lastPoint = position != 0 ? [(NSValue*)self.allPoints[position - 1] CGPointValue] : centerPoint;
		CGPoint nextPoint = position != self.allPoints.count - 1 ? [(NSValue*)self.allPoints[position + 1] CGPointValue] : centerPoint;
		
		float x1,y1,x2,y2;
		y1 = lastPoint.y;
		x1 = lastPoint.x;
		y2 = nextPoint.y;
		x2 = nextPoint.x;
				
		CPosition cPosition;
		cPosition.point = CGPointMake(centerPoint.x - glyphMatrix.size.width/2, centerPoint.y);
		cPosition.angle = atan2((y2 - y1),(x2 - x1));
		[cPositions addObject:[NSValue value:&cPosition withObjCType:@encode(CPosition)]];
	}
		
	return cPositions;
}
@end
