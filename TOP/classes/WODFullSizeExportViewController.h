//
//  WODFullSizeExportView.h
//  TOP
//
//  Created by ianluo on 14-8-21.
//  Copyright (c) 2014年 WOD. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WODEditHomeActions.h"

@interface WODFullSizeExportViewController : UIViewController

@property (nonatomic, weak)EditHomeViewController * editHomeViewController;
@property (nonatomic, strong)UIImage * fullScreenImage;

- (void)outputImageComplete:(void(^)(UIImage * image))action;

@end
