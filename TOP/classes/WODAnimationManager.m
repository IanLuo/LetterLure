//
//  WODAnimationManager.m
//  TOP
//
//  Created by ianluo on 14-4-20.
//  Copyright (c) 2014年 WOD. All rights reserved.
//

#import "WODAnimationManager.h"
#import "CECrossfadeAnimationController.h"
#import "CEReversibleAnimationController.h"

@implementation WODAnimationManager

- (CEReversibleAnimationController *)animatorWithType:(Animator)animatorType
{
	CEReversibleAnimationController * animator = nil;
	switch (animatorType) {
		case AnimatorCorssfadeAnimator:
			animator = [CECrossfadeAnimationController new];
			break;
		default:
			break;
	}
	
	return animator;
}

@end
