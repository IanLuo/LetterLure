//
//  WODSystemPatternGenerator.m
//  TOP
//
//  Created by ianluo on 14-1-8.
//  Copyright (c) 2014年 WOD. All rights reserved.
//

#import "WODSystemPatternGenerator.h"

NSString *const kPatternGrid = @"patternGrid:";
NSString *const kPatternDotBig = @"patternDotBig:";
NSString *const kPatternDotMid = @"patternDotMid:";
NSString *const kPatternDotSmall = @"patternDotSmall:";

#define kInfoContext @"context"
#define kInfoSize @"size"

@implementation WODSystemPatternGenerator

- (void)generatePatternWithKey:(NSString *)patternKey size:(CGSize)size inContext:(CGContextRef)context
{
	if (![[patternKey substringWithRange:NSMakeRange(patternKey.length-1, 1)]isEqualToString:@":"])
	{
		patternKey = [patternKey stringByAppendingString:@":"];
	}
	
	SEL selector = NSSelectorFromString(patternKey);
	
	NSDictionary * info = @{kInfoContext:[NSValue valueWithPointer:context],
							kInfoSize:[NSValue valueWithCGSize:size]};
	if ([self respondsToSelector:selector])
	{
		[self performSelector:selector withObject:info];
	}
}

- (void)patternGrid:(NSDictionary *)info
{
	CGContextRef context = [[info objectForKey:kInfoContext] pointerValue];
	CGSize size = [[info objectForKey:kInfoSize] CGSizeValue];
	
	CGContextSetFillColorWithColor(context, [UIColor whiteColor].CGColor);
	CGContextFillRect(context, CGRectMake(0.0, 0.0, size.width, size.height));
		
	CGContextSetFillColorWithColor(context, [UIColor blackColor].CGColor);
	//Fill the top left quarter of the cell with black
	CGContextFillRect(context, CGRectMake(0.0, 0.0, size.width/2, size.height/2));
	
	//Fill the bottom right quarter of the cell with black
	CGContextSetFillColorWithColor(context, [UIColor blackColor].CGColor);
	CGContextFillRect(context, CGRectMake(size.width/2, size.height/2, size.width/2, size.height/2));
}

- (void)patternDotBig:(NSDictionary *)info
{
	CGContextRef context = [[info objectForKey:kInfoContext] pointerValue];
	CGSize size = [[info objectForKey:kInfoSize] CGSizeValue];
	
	int scale = [UIScreen mainScreen].scale;
	
	CGContextSetFillColorWithColor(context, [UIColor blackColor].CGColor);
	CGContextFillRect(context, CGRectMake(0, 0, size.width * scale, size.height * scale));
	
	CGContextSetFillColorWithColor(context, [UIColor whiteColor].CGColor);
	CGMutablePathRef path = CGPathCreateMutable();
	CGPathAddEllipseInRect(path, NULL, CGRectMake(size.width * scale * 0.5, size.height * scale * 0.5, size.width * scale * 0.8, size.height * scale * 0.8));
}

- (void)patternDotMid:(NSDictionary *)info
{

	CGContextRef context = [[info objectForKey:kInfoContext] pointerValue];
	CGSize size = [[info objectForKey:kInfoSize] CGSizeValue];
	int scale = [UIScreen mainScreen].scale;
	
	CGContextSetFillColorWithColor(context, [UIColor blackColor].CGColor);
	CGContextFillRect(context, CGRectMake(0, 0, size.width * scale, size.height * scale));
	
	CGContextSetFillColorWithColor(context, [UIColor whiteColor].CGColor);
	CGMutablePathRef path = CGPathCreateMutable();
	CGPathAddEllipseInRect(path, NULL, CGRectMake(size.width * scale * 0.5, size.height * scale * 0.5, size.width * scale * 0.5, size.height * scale * 0.5));
	CGContextAddPath(context, path);
	CGContextFillPath(context);
}

- (void)patternDotSmall:(NSDictionary *)info
{
	CGContextRef context = [[info objectForKey:kInfoContext] pointerValue];
	CGSize size = [[info objectForKey:kInfoSize] CGSizeValue];
	
	CGContextSetFillColorWithColor(context, [UIColor blackColor].CGColor);
	CGContextFillRect(context, CGRectMake(0, 0, size.width, size.height));
	
	CGContextSetFillColorWithColor(context, [UIColor whiteColor].CGColor);
	CGMutablePathRef path = CGPathCreateMutable();
	CGPathAddEllipseInRect(path, NULL, CGRectMake(size.width/2, size.height/2, size.width * 0.3, size.height* 0.3));
}


@end
