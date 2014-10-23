//
//  WODTextConfigureView.m
//  TOP
//
//  Created by ianluo on 14-1-14.
//  Copyright (c) 2014年 WOD. All rights reserved.
//

#import "WODTextConfigureView.h"
#import "WODButton.h"

#define tag_alignment_left 1
#define tag_alignment_center 0
#define tag_alignment_right 2

@interface WODTextConfigureView()

@property (nonatomic, strong)WODButton * alignmentLeft;
@property (nonatomic, strong)WODButton * alignmentCenter;
@property (nonatomic, strong)WODButton * alignmentRight;

@end

@implementation WODTextConfigureView

- (id)init
{
    self = [super init];
    if (self)
	{
        _alignmentLeft = [WODButton new];
		[self.alignmentLeft setTag:tag_alignment_left];
		[self.alignmentLeft addTarget:self action:@selector(selectAlignment:) forControlEvents:UIControlEventTouchUpInside];
		[self.alignmentLeft setImage:[[UIImage imageNamed:@"text_align_left"]imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
		[self.alignmentLeft showBorder:YES];
		[self.alignmentLeft setTranslatesAutoresizingMaskIntoConstraints:NO];
		
		_alignmentCenter = [WODButton new];
		[self.alignmentCenter setTag:tag_alignment_center];
		[self.alignmentCenter addTarget:self action:@selector(selectAlignment:) forControlEvents:UIControlEventTouchUpInside];
		[self.alignmentCenter setImage:[[UIImage imageNamed:@"text_align_center"]imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
		[self.alignmentCenter showBorder:YES];
		[self.alignmentCenter setTranslatesAutoresizingMaskIntoConstraints:NO];
		
		_alignmentRight = [WODButton new];
		[self.alignmentRight setTag:tag_alignment_right];
		[self.alignmentRight addTarget:self action:@selector(selectAlignment:) forControlEvents:UIControlEventTouchUpInside];
		[self.alignmentRight setImage:[[UIImage imageNamed:@"text_align_right"]imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
		[self.alignmentRight showBorder:YES];
		[self.alignmentRight setTranslatesAutoresizingMaskIntoConstraints:NO];
		
		[self addSubview:self.alignmentLeft];
		[self addSubview:self.alignmentCenter];
		[self addSubview:self.alignmentRight];
    }
    return self;
}

- (void)layoutSubviews
{
	[super layoutSubviews];
	
	[self removeConstraints:self.constraints];
	
	NSDictionary * views = @{@"left":self.alignmentLeft,@"center":self.alignmentCenter,@"right":self.alignmentRight};
	
	[self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|-[left(center)]-2-[center(right)]-2-[right]-|" options:0 metrics:nil views:views]];
	[self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-[left]" options:0 metrics:nil views:views]];
	[self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-[center]" options:0 metrics:nil views:views]];
	[self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-[right]" options:0 metrics:nil views:views]];
	
	[super layoutSubviews];
}

- (void)selectAlignment:(WODButton *)button
{
	NSTextAlignment alignment = NSTextAlignmentLeft;
	
	if (button.tag == tag_alignment_left)
	{
		alignment = NSTextAlignmentLeft;
	}else if (button.tag == tag_alignment_center)
	{
		alignment = NSTextAlignmentCenter;
	}else if (button.tag == tag_alignment_right)
	{
		alignment = NSTextAlignmentRight;
	}
	
	if ([self.delegate respondsToSelector:@selector(didFinishTextConfigureAlignment:configureView:)])
	{
		[self.delegate didFinishTextConfigureAlignment:alignment configureView:self];
	}
}

@end
