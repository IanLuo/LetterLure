//
//  WODEffectPackageBrowser.m
//  TOP
//
//  Created by ianluo on 13-12-13.
//  Copyright (c) 2013年 WOD. All rights reserved.
//

#import "WODEffectPackageManager.h"

NSString * xmlFileName = @"effect.xml";
NSString * iconFileName = @"/icon.png";
NSString * bannerFileName = @"banner.png";

@interface WODEffectPackageManager ()

@end

@implementation WODEffectPackageManager

- (NSArray *)effectsInPackage:(NSString *)packageName
{
	return [self getEffectRootDirsInPackage:packageName];
}

- (NSString *)pathForSystemTexture:(NSString *)fileName
{
	NSString * packageRootPath = [[[NSBundle mainBundle]resourcePath]stringByAppendingString:@"/effects/texture/"];
	return [packageRootPath stringByAppendingString:fileName];
}

- (NSString *)getPackagePath:(NSString *)packageName
{
// for now , the contents will all be provided without download, so all data will be in the bundle
//	if ([packageName isEqualToString:@"defaultPackage"])
//	{
//		return [[[NSBundle mainBundle]resourcePath]stringByAppendingString:@"/effects/packages/defaultPackage"];
//	}
//	else
	{
		NSString * packageRootPath = [[[NSBundle mainBundle]resourcePath] stringByAppendingString:@"/effects/packages/"];
		return [packageRootPath stringByAppendingString:packageName];
	}
}

- (NSArray *)getEffectRootDirsInPackage:(NSString *)packageName
{
	NSString * packagePath = [self getPackagePath:packageName];
	NSError * error;
	NSMutableArray * dirs = [NSMutableArray arrayWithArray:[[NSFileManager defaultManager]contentsOfDirectoryAtPath:packagePath error:&error]];
	
	[dirs enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop)
	{
		dirs[idx] = [packagePath stringByAppendingFormat:@"/%@",obj];
	}];
	
	if (error)
	{
		NSLog(@"ERROR \n %@",error);
		return nil;
	}
	return [NSArray arrayWithArray:dirs];
}

- (NSArray *)packageList
{
	NSString * packagePath = [[[NSBundle mainBundle]resourcePath]stringByAppendingString:@"/effects/packages/"];
	
	NSError * error;
	NSArray * result = [[NSFileManager defaultManager]contentsOfDirectoryAtPath:packagePath error:&error];
	
	if (error)
	{
		NSLog(@"ERROR:%s \n error getting package list \n %@",__PRETTY_FUNCTION__,error);
	}
	
	return result;
}

- (UIImage *)iconForEffect:(NSString*)effectPath
{
	NSString * iconPath = [effectPath stringByAppendingString:iconFileName];
	return [UIImage imageWithContentsOfFile:iconPath];
}

- (UIImage *)bannerForEffect:(NSString *)effectPath
{
	NSString * iconPath = [effectPath stringByAppendingString:bannerFileName];
	return [UIImage imageWithContentsOfFile:iconPath];
}

@end
