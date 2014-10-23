//
//  WODAnimationManager.h
//  TOP
//
//  Created by ianluo on 14-4-20.
//  Copyright (c) 2014年 WOD. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CEReversibleAnimationController.h"

typedef enum
{
	AnimatorCorssfadeAnimator,
}Animator;

@interface WODAnimationManager : NSObject

- (CEReversibleAnimationController *)animatorWithType:(Animator)animator;

@end
