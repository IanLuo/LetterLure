//
//  WODInstagramActivity.m
//  TOP
//
//  Created by ianluo on 14-3-25.
//  Copyright (c) 2014年 WOD. All rights reserved.
//

#import "InstagramActivity.h"

@interface InstagramActivity()

@end

@implementation InstagramActivity

- (id)init
{
	self = [super init];
	if (self)
	{
		type = @"OpenInInstagram";
	}
	return self;
}

+ (UIActivityCategory)activityCategory // default is UIActivityCategoryAction.
{
	return UIActivityCategoryShare;
}

- (NSString *)activityType       // default returns nil. subclass may override to return custom activity type that is reported to completion handler
{
	return type;
}

- (NSString *)activityTitle      // default returns nil. subclass must override and must return non-nil value
{
	return NSLocalizedString(@"INSTAGRAM", nil);
}

- (UIImage *)activityImage       // default returns nil. subclass must override and must return non-nil value
{
	if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
	{
		return [UIImage imageNamed:@"instagram_activity_76"];
	}
	else if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
	{
		return [UIImage imageNamed:@"instagram_activity_60"];
	}
	else
	{
		return [UIImage imageNamed:@"instagram_activity_60"];
	}
}

- (BOOL)canPerformWithActivityItems:(NSArray *)activityItems   // override this to return availability of activity based on items. default returns NO
{
	return YES;
}

- (void)prepareWithActivityItems:(NSArray *)activityItems      // override to extract items and set up your HI. default does nothing
{

}

- (UIViewController *)activityViewController // return non-nil to have vC presented modally. call activityDidFinish at end. default returns nil
{
	return nil;
}

- (void)performActivity                     // if no view controller, this method is called. call activityDidFinish when done. default calls [self activityDidFinish:NO]
{
	[self activityDidFinish:YES];
//	completeAction();
}

// state method

@end
