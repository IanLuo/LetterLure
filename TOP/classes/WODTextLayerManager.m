//
//  WODTextLayerManager.m
//  TOP
//
//  Created by ianluo on 13-12-12.
//  Copyright (c) 2013年 WOD. All rights reserved.
//

#import "WODTextLayerManager.h"

@interface WODTextLayerManager()

@property (nonatomic, strong)NSMutableArray * textViews;
@property (nonatomic, assign)NSUInteger name;

@end

@implementation WODTextLayerManager

- (NSMutableArray *)textViews
{
	if (_textViews == nil)
	{
		_textViews = [NSMutableArray array];
	}
	return _textViews;
}

- (void)addTextView:(WODTextView *)textView
{
	if (textView)
	{
		[self.textViews addObject:textView];
		
		//asssin a unique name for each added textview
		[textView setName:++self.name];
	}
}

- (void)removeTextView:(WODTextView *)textView
{
	if ([self.textViews containsObject:textView])
	{
		[self.textViews removeObject:textView];
	}
}

- (void)selectTextView:(WODTextView *)textView
{
	self.currentTextView = textView;
	[[NSNotificationCenter defaultCenter]postNotificationName:TextLayerDidChangeCurrentLayer object:nil];
}

- (NSArray *)allTextViews
{
	return [NSArray arrayWithArray:self.textViews];
}

#pragma mark - singleTon
+ (WODTextLayerManager *)sharedInstance
{
	
	static dispatch_once_t pred = 0;
    __strong static id _sharedObject = nil;
	
    dispatch_once(&pred, ^
				  {
					  _sharedObject = [[self alloc] init];
				  });
	
    return _sharedObject;
}

@end
