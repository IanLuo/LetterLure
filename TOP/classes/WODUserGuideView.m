//
//  WODUserGuideView.m
//  TOP
//
//  Created by ianluo on 14-4-28.
//  Copyright (c) 2014年 WOD. All rights reserved.
//

#import "WODUserGuideView.h"

@interface WODUserGuideView()


@end

@implementation WODUserGuideView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
		self.backgroundColor = color_black;
		self.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
		
		[self addSubview:self.textView];
		
		[self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|[textView]|" options:0 metrics:nil views:@{@"textView":self.textView}]];
		[self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[textView]|" options:0 metrics:nil views:@{@"textView":self.textView}]];
    }
    return self;
}

- (UITextView *)textView
{
	if (!_textView)
	{
		_textView = [UITextView new];
		_textView.backgroundColor = color_black;
		_textView.font = [UIFont systemFontOfSize:25];
		_textView.textColor = color_white;
		_textView.editable = NO;
		_textView.translatesAutoresizingMaskIntoConstraints = NO;
	}
	return _textView;
}

@end
