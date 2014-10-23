//
//  WODEffectPackageManager.h
//  TOP
//
//  Created by ianluo on 13-12-13.
//  Copyright (c) 2013年 WOD. All rights reserved.
//

#import <UIKit/UIKit.h>

extern const NSString * xmlFileName;
extern const NSString * iconFileName;
extern const NSString * bannerFileName;

@interface WODEffectPackageManager : NSObject

- (NSArray *)effectsInPackage:(NSString *)package;

- (NSString *)pathForSystemTexture:(NSString *)fileName;

- (NSArray *)packageList;

- (UIImage *)iconForEffect:(NSString*)effectPath;

- (UIImage *)bannerForEffect:(NSString *)effecPath;

@end
