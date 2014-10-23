//
//  WODEffectsPackageViewController.h
//  TOP
//
//  Created by ianluo on 14-1-19.
//  Copyright (c) 2014年 WOD. All rights reserved.
//

#import <UIKit/UIKit.h>

#define kCurrentSelectedEffectPackageName @"currentSelectedEffectPackageName"
#define kDefualtPackageName  @"defaultPackage"

@class WODEffectsPackageViewController;
@protocol WODEffectsPackageDelegate <NSObject>

- (void)didFinishSelectEffectPackage:(NSString *)currentPackageName currentEffect:(NSString *)effectXMLfilePath viewController:(WODEffectsPackageViewController *)viewController;

@end

@interface WODEffectsPackageViewController : UIViewController

@property (nonatomic, weak) id<WODEffectsPackageDelegate> delegate;

@end
