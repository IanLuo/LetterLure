//
//  WODTextLayerManager.h
//  TOP
//
//  Created by ianluo on 13-12-12.
//  Copyright (c) 2013年 WOD. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WODTextView.h"

#define TextLayerDidChangeCurrentLayer @"textLayerDidChangeCurrentLayer"

@interface WODTextLayerManager : NSObject

@property (nonatomic,weak)WODTextView * currentTextView;

- (void)addTextView:(WODTextView *)textView;
- (void)removeTextView:(WODTextView *)textView;
- (void)selectTextView:(WODTextView *)textView;
- (NSArray *)allTextViews;

+ (WODTextLayerManager *)sharedInstance;

@end
