//
//  SocialControl.m
//  YouPlay
//
//  Created by ianluo on 14-7-26.
//  Copyright (c) 2014年 WOD. All rights reserved.
//

#import "SocialControl.h"
#import <Social/Social.h>
#import <MessageUI/MessageUI.h>
#import "WODAppDelegate.h"
#import "WXApi.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import "MBProgressHUD.h"

@interface SocialControl()<MFMailComposeViewControllerDelegate,UINavigationControllerDelegate>

@end

@implementation SocialControl

- (UIViewController *)presentingController
{
	return [(WODAppDelegate *)[UIApplication sharedApplication].delegate navigationController];
}

- (void)shareToFacebook:(void(^)(void))complete
{
	if ([SLComposeViewController isAvailableForServiceType:SLServiceTypeSinaWeibo])
    {
        SLComposeViewController * sl_compose = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeFacebook];
        [sl_compose setInitialText:self.message ? self.message : NSLocalizedString(@"socail_share_msg", nil)];
		if (self.image)
		{
			[sl_compose addImage:self.image];
		}
        [sl_compose addURL:[NSURL URLWithString:@"http://www.facebook.com"]];
		
        [[self presentingController] presentViewController:sl_compose animated:YES completion:nil];
        
        __weak SLComposeViewController * vc = sl_compose;
        [sl_compose setCompletionHandler:^(SLComposeViewControllerResult result)
         {
			 if (result == SLComposeViewControllerResultDone)
			 {
				 if (complete)
				 {
					 complete();
					 [vc dismissViewControllerAnimated:YES completion:nil];
				 }
			 }
         }];
    }
}

- (void)shareToTwitter:(void(^)(void))complete
{
	if ([SLComposeViewController isAvailableForServiceType:SLServiceTypeSinaWeibo])
    {
        SLComposeViewController * sl_compose = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeTwitter];
        [sl_compose setInitialText:self.message ? self.message : NSLocalizedString(@"socail_share_msg", nil)];
		if (self.image)
		{
			[sl_compose addImage:self.image];
		}
        [sl_compose addURL:[NSURL URLWithString:@"http://www.twitter.com"]];
		
        [[self presentingController] presentViewController:sl_compose animated:YES completion:nil];
        
        __weak SLComposeViewController * vc = sl_compose;
        [sl_compose setCompletionHandler:^(SLComposeViewControllerResult result)
         {
			 if (result == SLComposeViewControllerResultDone)
			 {
				 if (complete)
				 {
					 complete();
					 [vc dismissViewControllerAnimated:YES completion:nil];
				 }
			 }
         }];
    }
}

- (void)shareToWeibo:(void(^)(void))complete
{
	if ([SLComposeViewController isAvailableForServiceType:SLServiceTypeSinaWeibo])
    {
        SLComposeViewController * sl_compose = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeSinaWeibo];
        [sl_compose setInitialText:self.message ? self.message : NSLocalizedString(@"socail_share_msg", nil)];
		if (self.image)
		{
			[sl_compose addImage:self.image];
		}
        [sl_compose addURL:[NSURL URLWithString:@"http://www.weibo.com"]];
		
        [[self presentingController] presentViewController:sl_compose animated:YES completion:nil];
        
        __weak SLComposeViewController * vc = sl_compose;
        [sl_compose setCompletionHandler:^(SLComposeViewControllerResult result)
         {
			 if (result == SLComposeViewControllerResultDone)
			 {
				 if (complete)
				 {
					 complete();
					 [vc dismissViewControllerAnimated:YES completion:nil];
				 }
			 }
         }];
    }
}

- (void)shareToWeChat:(void(^)(void))complete
{
    WXMediaMessage *message = [WXMediaMessage message];
    [message setThumbImage:self.image];
	
	SendMessageToWXReq* req = [[SendMessageToWXReq alloc] init];
    req.bText = NO;
    req.message = message;
    req.scene = WXSceneTimeline;
    
    [WXApi sendReq:req];
	
	if (complete)
	{
		complete();
	}
}

- (void)shareToEmail:(void(^)(void))complete
{
	MFMailComposeViewController *mailController = [[MFMailComposeViewController alloc] init];
	[mailController addAttachmentData:UIImageJPEGRepresentation(self.image, 1) mimeType:@"image/jpeg" fileName:@"Image.jpg"];
	[mailController setSubject:@""];
	mailController.mailComposeDelegate = self;
	[[self presentingController] presentViewController:mailController animated:YES completion:nil];
}

- (void)saveToImageRoll:(void(^)(void))complete
{
	UIImage * imageToSave = self.image;
	
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
          
          dispatch_async(dispatch_get_main_queue(), ^{
            [[[UIAlertView alloc]initWithTitle:iStr(@"OK") message:iStr(@"SAVE_COMPLETE") delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil]show];
          });
				}
			} failureBlock:^(NSError *error) {
				NSLog(@"(%@,%i)ERROR: %@",[[NSString stringWithUTF8String:__FILE__]lastPathComponent],__LINE__,error);
			}];
			
		}
	} failureBlock:^(NSError *error) {
		NSLog(@"(%@,%i)ERROR: %@",[[NSString stringWithUTF8String:__FILE__]lastPathComponent],__LINE__,error);
	}];
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

- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
	[controller dismissViewControllerAnimated:YES completion:nil];
}

@end
