//
//  WODEffectsPackageItemsViewController.h
//  TOP
//
//  Created by ianluo on 14-1-20.
//  Copyright (c) 2014年 WOD. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WODEffectsPackageViewController.h"

@interface WODEffectsPackageItemsViewController : UIViewController

@property (nonatomic, weak) WODEffectsPackageViewController * packageViewController;

@property (nonatomic, strong) NSString * packageName;

@end
