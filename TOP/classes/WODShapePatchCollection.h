//
//  WODShapePatchCollection.h
//  TOP
//
//  Created by ianluo on 13-12-12.
//  Copyright (c) 2013年 WOD. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString *const kShapePathOval;
extern NSString *const kShapePatthPentagon;
extern NSString *const kShapePatthSquare;
extern NSString *const kShapePatthSixAngle;
extern NSString *const kShapePatthTrangle;
extern NSString *const kShapePatthDiamond;
extern NSString *const kShapePatthRoundCornerSquare;

@interface WODShapePatchCollection : NSObject

- (NSArray *)allShapePathKeys;

- (NSDictionary *)allShapePathWithIconNames;

- (UIBezierPath *)pathWithKey:(NSString *)pathKey forRect:(CGRect)rect;

- (UIBezierPath *)createPentagonForRect:(NSValue *)rectObject;

@end
