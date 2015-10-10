//
//  SaveToMyDirectoryActivity.m
//  TOP
//
//  Created by ianluo on 14-4-30.
//  Copyright (c) 2014年 WOD. All rights reserved.
//

#import "SaveToMyDirectoryActivity.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import "MBProgressHUD.h"

@implementation SaveToMyDirectoryActivity
- (id)init
{
	self = [super init];
	if (self)
	{
		type = @"SaveToDirectory";
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
	return NSLocalizedString(@"SAVE_IMAGE", nil);
}

- (UIImage *)activityImage       // default returns nil. subclass must override and must return non-nil value
{
	if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
	{
		return [UIImage imageNamed:@"save_to_directory_76"];
	}
	else if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
	{
		return [UIImage imageNamed:@"save_to_directory_60"];
	}
	else
	{
		return [UIImage imageNamed:@"save_to_directory_60"];
	}
}

- (BOOL)canPerformWithActivityItems:(NSArray *)activityItems   // override this to return availability of activity based on items. default returns NO
{
	return YES;
}

- (void)prepareWithActivityItems:(NSArray *)activityItems      // override to extract items and set up your HI. default does nothing
{
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:[[UIApplication sharedApplication]keyWindow] animated:YES];
    [hud setLabelText:@"Saving.."];
    [hud show:YES];
    
	if (activityItems > 0)
	{
		if ([activityItems[0] isKindOfClass:[UIImage class]])
		{
			UIImage * imageToSave = activityItems[0];
			ALAssetsLibrary * library = [ALAssetsLibrary new];
			
			__weak typeof(library) wLibrary = library;
			[library addAssetsGroupAlbumWithName:NSLocalizedString(@"IMAGE_ROLL_GROUP_NAME",nil) resultBlock:^(ALAssetsGroup *group) {
				if (group) {
					[self addImage:imageToSave toGroup:group library:wLibrary];
				}
				else
				{
					[wLibrary enumerateGroupsWithTypes:ALAssetsGroupAll usingBlock:^(ALAssetsGroup *group, BOOL *stop) {
						if ([[group valueForProperty:ALAssetsGroupPropertyName]isEqualToString:NSLocalizedString(@"IMAGE_ROLL_GROUP_NAME",nil)])
						{
							[self addImage:imageToSave toGroup:group library:wLibrary];
                            [hud hide:YES];
						}
					} failureBlock:^(NSError *error) {
						NSLog(@"(%@,%i)ERROR: %@",[[NSString stringWithUTF8String:__FILE__]lastPathComponent],__LINE__,error);
					}];
					
				}
			} failureBlock:^(NSError *error) {
				NSLog(@"(%@,%i)ERROR: %@",[[NSString stringWithUTF8String:__FILE__]lastPathComponent],__LINE__,error);
			}];
		}
	}
}

- (void)addImage:(UIImage *)image toGroup:(ALAssetsGroup *)group library:(ALAssetsLibrary *)lib
{
	[lib writeImageToSavedPhotosAlbum:image.CGImage orientation:ALAssetOrientationUp completionBlock:^(NSURL *assetURL, NSError *error) {
		[lib assetForURL:assetURL resultBlock:^(ALAsset *asset) {
			[group addAsset:asset];
		} failureBlock:^(NSError *error) {
			NSLog(@"(%@,%i)ERROR: %@",[[NSString stringWithUTF8String:__FILE__]lastPathComponent],__LINE__,error);
		}];
	}];
}

- (UIViewController *)activityViewController // return non-nil to have vC presented modally. call activityDidFinish at end. default returns nil
{
	return nil;
}

- (void)performActivity                     // if no view controller, this method is called. call activityDidFinish when done. default calls [self activityDidFinish:NO]
{
	[self activityDidFinish:YES];
}

@end
