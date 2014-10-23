//
//  WODShapePatchCollection.m
//  TOP
//
//  Created by ianluo on 13-12-12.
//  Copyright (c) 2013年 WOD. All rights reserved.
//

#import "WODShapePatchCollection.h"

NSString *const kShapePathOval = @"createCircleForRect:";
NSString *const kShapePatthPentagon = @"createPentagonForRect:";
NSString *const kShapePatthSquare = @"createSquareForRect:";
NSString *const kShapePatthSixAngle = @"createSixAngleForRect:";
NSString *const kShapePatthTrangle = @"createTrangleForRect:";
NSString *const kShapePatthDiamond = @"createDiamondForRect:";
NSString *const kShapePatthRoundCornerSquare = @"createRoundCornerSquareForRect:";

@implementation WODShapePatchCollection

- (NSArray *)allShapePathKeys
{
	return @[kShapePathOval,kShapePatthSquare,kShapePatthTrangle,kShapePatthDiamond,kShapePatthPentagon,kShapePatthSixAngle];
}

- (NSDictionary *)allShapePathWithIconNames
{
	return @{kShapePathOval:@"shape_circle.png",kShapePatthSquare:@"shape_square",kShapePatthTrangle:@"shape_trangle",kShapePatthDiamond:@"shape_diamond",kShapePatthPentagon:@"shape_pentagon",kShapePatthSixAngle:@"shape_sixAngle"};
}

- (UIBezierPath *)pathWithKey:(NSString *)pathKey forRect:(CGRect)rect
{
	SEL sel = NSSelectorFromString(pathKey);
	
	return [self performSelector:sel withObject:[NSValue valueWithCGRect:rect]];
}

- (UIBezierPath *)createSquareForRect:(NSValue *)rect
{
	CGRect rectValue = [rect CGRectValue];
	float sideLength = (MAX(rectValue.size.width, rectValue.size.height) +  MIN(rectValue.size.width, rectValue.size.height))/2;
	return [UIBezierPath bezierPathWithRoundedRect:CGRectMake(rectValue.origin.x, rectValue.origin.y, sideLength, sideLength) cornerRadius:0];
}

- (UIBezierPath *)createRoundCornerSquareForRect:(NSValue *)rect
{
	CGRect rectValue = [rect CGRectValue];
	float sideLength = (MAX(rectValue.size.width, rectValue.size.height) +  MIN(rectValue.size.width, rectValue.size.height))/2;
	return [UIBezierPath bezierPathWithRoundedRect:CGRectMake(rectValue.origin.x, rectValue.origin.y, sideLength, sideLength) cornerRadius:sideLength/4];
}

- (UIBezierPath *)createCircleForRect:(NSValue *)rect
{
	CGRect rectValue = rect.CGRectValue;
	float sideLength = (MAX(rectValue.size.width, rectValue.size.height) +  MIN(rectValue.size.width, rectValue.size.height))/2;
	return [UIBezierPath bezierPathWithOvalInRect:CGRectMake(rectValue.origin.x, rectValue.origin.y, sideLength, sideLength)];
}

- (UIBezierPath *)createPentagonForRect:(NSValue *)rectObject
{
	return [self polygonWithNumberOfSize:5 rect:[rectObject CGRectValue]];
}

- (UIBezierPath *)createDiamondForRect:(NSValue *)rectObject
{
	return [self polygonWithNumberOfSize:4 rect:[rectObject CGRectValue]];
}

- (UIBezierPath *)createSixAngleForRect:(NSValue *)rectObject
{
	return [self polygonWithNumberOfSize:6 rect:[rectObject CGRectValue]];
}

- (UIBezierPath *)createTrangleForRect:(NSValue *)rectObject
{
	return [self polygonWithNumberOfSize:3 rect:[rectObject CGRectValue]];
}

- (UIBezierPath *)polygonWithNumberOfSize:(NSUInteger)numberOfSides rect:(CGRect)rect
{
	CGFloat radius = floorf( 0.9 * MIN(rect.size.width, rect.size.height) / 2.0f );
	CGMutablePathRef path = CGPathCreateMutable();
    CGFloat startingAngle = 2 * M_PI / numberOfSides;
	
    for (int n = 0; n < numberOfSides; n++)
	{
        CGFloat rotationFactor = ((2 * M_PI) / numberOfSides) * (n+1) + startingAngle;
        CGFloat x = (rect.size.width / 2.0f) + sin(rotationFactor) * radius;
        CGFloat y = (rect.size.height / 2.0f) + cos(rotationFactor) * radius;
        
        if (n == 0)
		{
            CGPathMoveToPoint(path, NULL, x, y);
        }
		else
		{
            CGPathAddLineToPoint(path, NULL, x, y);
        }
    }
	
	CGPathCloseSubpath(path);
	
	UIBezierPath * bezierPath = [UIBezierPath bezierPathWithCGPath:path];
	
	CGPathRelease(path);
	
	return bezierPath;
}

@end
