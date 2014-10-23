//
//  WODImagePickerViewController.h
//  TOP
//
//  Created by ianluo on 13-12-12.
//  Copyright (c) 2013年 WOD. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WODScrollTab.h"
#import <AssetsLibrary/AssetsLibrary.h>

@class WODImagePickerViewController;

@protocol WODImagePickerDelegate<NSObject>

- (void)didFinishPickingImage:(UIImage *)fullScreenImage originalImagePath:(NSString *)originalImage size:(CGSize)size picker:(WODImagePickerViewController *)picker;
- (void)didCancelImagePicker:(WODImagePickerViewController *)picker;

@end

@interface WODImagePickerViewController : UIViewController

@property (nonatomic, strong)WODScrollTab * tab;

@property (nonatomic, weak)id<WODImagePickerDelegate> delegate;

@end


@interface WODAsset : NSObject

@property (nonatomic, strong) UIImage * fullScreenImage;
@property (nonatomic, strong) UIImage * originalImage;
@property (nonatomic, assign) CGSize size;

- (id)initWithImage:(UIImage *)image;

@end
