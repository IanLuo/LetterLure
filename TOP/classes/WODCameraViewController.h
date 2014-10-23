//
//  WODCameraViewController.h
//  TOP
//
//  Created by ianluo on 13-12-16.
//  Copyright (c) 2013年 WOD. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WODImagePickerViewController.h"

@interface WODCameraViewController : UIViewController

@property (nonatomic, weak) WODImagePickerViewController * imagePickerViewController;

- (void)showShutter;
- (void)removeShutter;

@end
