//
//  WODIAPCenter.h
//  TOP
//
//  Created by ianluo on 14-4-8.
//  Copyright (c) 2014年 WOD. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <StoreKit/StoreKit.h>

extern NSString * const iapEffectMetal;
extern NSString * const iapEffectColors;
extern NSString * const iapEffectGlass;
extern NSString * const iapEffectGradient;
extern NSString * const iapEffectNeon;
extern NSString * const iapEffectAnimals;
extern NSString * const iapEffectWater;
extern NSString * const iapEffectHoney;
extern NSString * const iapExtraFonts;

@interface WODIAPCenter : NSObject

@property (nonatomic, strong)NSArray * freePackages;

- (BOOL)checkIsPackageReady:(NSString *)packageName;

- (void)purchasePackage:(NSString *)packagedName complete:(void(^)(NSString * completeMessage))actoin;

- (void)restorePaymentsComplete:(void(^)(BOOL status))actoin;

- (void)loadStore;

- (BOOL)canMakePurchases;

+ (WODIAPCenter*)sharedSingleton;
@end

@interface SKProduct (LocalizedPrice)

@end
