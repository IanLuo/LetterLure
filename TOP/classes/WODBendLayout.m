//
//  WODBendLayout.m
//  TOP
//
//  Created by ianluo on 14-1-1.
//  Copyright (c) 2014年 WOD. All rights reserved.
//

#import "WODBendLayout.h"

@interface WODBendLayout()


@end

@implementation WODBendLayout

- (NSArray *)textview:(WODTextView *)textview positionForCharacters:(NSAttributedString *)aString glyphInfo:(NSDictionary *)info
{
	NSMutableArray * cPositions = [NSMutableArray array];
	
	NSArray * glyphBounds = [info objectForKey:@"glyphsBounds"];
		
	double len = 0;
	for (int i = 0; i < glyphBounds.count; i++)
	{
		len += ([(NSValue*)glyphBounds[i] CGRectValue].size.width);
	}
	
    double l = len;
    double a = self.bendAngle == 0 ? 0.1 : self.bendAngle;
    double r = (180 * l) / (a * M_PI);
	
    CGPoint anchor = CGPointMake(textview.bounds.size.width/2, textview.bounds.size.height/2);
    
	//    float arcCount = aString.length + 2;
    double A1,A2;
	double baseAngle = (90 - a/2);
	double angleIncremental = 0.0;
	BOOL clockWise = a<0 ? YES : NO;
	//draw 1 more point, and ignore the last point, because the first point is not able to get.
    CGMutablePathRef path = CGPathCreateMutable();
	
	angleIncremental = 0.0;
	CGPathAddArc(path, NULL, anchor.x, anchor.y + r, r, radians(baseAngle+180.0),radians(baseAngle+180), clockWise);
	CGPoint lastpoint = CGPathGetCurrentPoint(path);
	double minX = lastpoint.x, minY = lastpoint.y, maxX = lastpoint.x, maxY = lastpoint.y;
	
	float maxGlyphHeight = 0;
	
	for(int i = 0; i < glyphBounds.count; i++)
	{
		A1 = baseAngle + angleIncremental + 180.0;
		
		double glyphWidth = [(NSValue*)glyphBounds[i] CGRectValue].size.width;
		double glyphAngle = glyphWidth/len * a;
		
		angleIncremental += glyphAngle;
		A2 = baseAngle + angleIncremental + 180.0;
		
		CGPathAddArc(path, NULL, anchor.x, anchor.y + r, r, radians(A1),radians(A2), clockWise);
		CGPoint currentPoint = CGPathGetCurrentPoint(path);
		
		minX = MIN(currentPoint.x, minX);
		minY = MIN(currentPoint.y, minY);
		maxX = MAX(currentPoint.x, maxX);
		maxY = MAX(currentPoint.y, maxY);
		
		maxGlyphHeight = MAX(maxGlyphHeight, [(NSValue*)glyphBounds[i] CGRectValue].size.height);
	}
	
	textview.bounds = (CGRect){CGPointZero,CGSizeMake((maxX - minX) + maxGlyphHeight * 3, (maxY - minY) + maxGlyphHeight * 3)};
	
	anchor.x = textview.bounds.size.width/2;
	
	
	// whem a > 0, means the curve is facing down, so the caracters align to top, offset is twice of the biggist glyph size
	if (a > maxGlyphHeight)
	{
		anchor.y = maxGlyphHeight * 2;
	}
	// whem a < 0, means the curve is facing up, so the caracters align to bottom, offset is twice of the biggist glyph size
	else
	{
		anchor.y = textview.bounds.size.height - maxGlyphHeight * 2;
	}
	
	//use this trick to get the first point, draw a zero lengh arc
	angleIncremental = 0.0;
	CGPathAddArc(path, NULL, anchor.x, anchor.y + r, r, radians(baseAngle+180.0),radians(baseAngle+180), clockWise);
	lastpoint = CGPathGetCurrentPoint(path);
	
	//	NSLog(@"----->\n");
	for(int i = 0; i < glyphBounds.count; i++)
	{
		A1 = baseAngle + angleIncremental + 180.0;
		
		double glyphWidth = [(NSValue*)glyphBounds[i] CGRectValue].size.width;
		double glyphAngle = glyphWidth/len * a;
		
		angleIncremental += glyphAngle;
		A2 = baseAngle + angleIncremental + 180.0;
		
		CGPathAddArc(path, NULL, anchor.x, anchor.y + r, r, radians(A1),radians(A2), clockWise);
		CGPoint currentPoint = CGPathGetCurrentPoint(path);
		
		CPosition cPosition;
		cPosition.point = CGPointMake((currentPoint.x + lastpoint.x - glyphWidth)/2, (currentPoint.y + lastpoint.y)/2);
		cPosition.angle = atan2((currentPoint.y/2 - lastpoint.y/2),(currentPoint.x/2 - lastpoint.x/2));
		
		cPosition.point.x += maxGlyphHeight/4;
		
		//		NSLog(@"%@",NSStringFromCGPoint(cPosition.point));
		
		lastpoint = currentPoint;
		
		[cPositions addObject:[NSValue value:&cPosition withObjCType:@encode(CPosition)]];
	}
		
	CGPathRelease(path);
	
	return cPositions;
}

- (CGFloat)spaceSize
{
	return 10;
}

- (void)didStartRender:(WODTextView *)textview
{
	
}

- (void)didEndRender:(WODTextView *)textview
{
	
}


@end
