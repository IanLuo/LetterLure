//
//  WODAppDelegate.m
//  TOP
//
//  Created by ianluo on 13-12-12.
//  Copyright (c) 2013年 WOD. All rights reserved.
//

#import "WODAppDelegate.h"
#import "WODRootViewController.h"
#import "WODFontManager.h"
#import <MobileCoreServices/MobileCoreServices.h>
#import "WODIAPCenter.h"
#import "Flurry.h"

@implementation WODAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
	[Flurry setCrashReportingEnabled:YES];
	[Flurry startSession:@"4J7ZCHZYWP73RBRW7Z97"];

    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    // Override point for customization after application launch.
    self.window.backgroundColor = [UIColor whiteColor];
    
    [[UINavigationBar appearance]setBackgroundImage:[UIImage new] forBarMetrics:UIBarMetricsDefault];
    [[UINavigationBar appearance]setShadowImage:[UIImage new]];
    [[UINavigationBar appearance]setTintColor:color_white];
    [[UINavigationBar appearance]setTitleTextAttributes:@{NSFontAttributeName:[UIFont boldSystemFontOfSize:16],NSForegroundColorAttributeName:color_white}];
    
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];

	WODRootViewController * rootViewController = [[WODRootViewController alloc]init];
	_navigationController = [[UINavigationController alloc]initWithRootViewController:rootViewController];
    [self.window setRootViewController:self.navigationController];
    [self.window makeKeyAndVisible];
	
	WODFontManager * fontManager = [WODFontManager new];
	[fontManager loadCustomFonts];
	
	WODIAPCenter * iapCenter = [WODIAPCenter sharedSingleton];
	
	[iapCenter loadStore];
	if ([iapCenter checkIsPackageReady:iapExtraFonts])
	{
		[fontManager loadExtraFonts];
	}
	
    return YES;
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
{
	WODFontManager * fontManager = [WODFontManager new];
	
	CFStringRef fileUTI = UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension, (__bridge CFStringRef)([url pathExtension]), NULL);
	
	if (url && [url isFileURL])
	{
		if (UTTypeConformsTo(fileUTI, kUTTypeImage))
		{
			UIImage * image = [UIImage imageWithContentsOfFile:url.path];
			if (image)
			{
				WODRootViewController * rootViewController = (WODRootViewController *)[self.navigationController topViewController];
				[rootViewController useOutsideImage:image];
			}
		}
		else
		{
			[fontManager importFont:url];
		}
	}
	
	CFRelease(fileUTI);
	
	return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
	// Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
	// Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
	// Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
	// If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
	// Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
	// Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
	// Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
