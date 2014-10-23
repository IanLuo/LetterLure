//
//  WODExportToOtherAppviewController.h
//  TOP
//
//  Created by ianluo on 14-3-25.
//  Copyright (c) 2014年 WOD. All rights reserved.
//

#import <UIKit/UIKit.h>

@class WODExportToOtherAppviewController;

@protocol WODExportToOtherAppviewControllerDelegate

- (void)completeExportingToOtherApp:(WODExportToOtherAppviewController *)controller;

@end

@interface WODExportToOtherAppviewController : UIViewController

@property (nonatomic, weak)NSObject<WODExportToOtherAppviewControllerDelegate> * delegate;
@property (nonatomic, strong) UIDocumentInteractionController * documentInteractionController;
@property (nonatomic, strong) NSURL * fileURL;
@property (nonatomic, strong) UIImageView * imageView;

- (void)setImage:(UIImage *)image;

@end
