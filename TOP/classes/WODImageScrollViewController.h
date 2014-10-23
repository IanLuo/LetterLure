//
//  WODImageScrollViewController.h
//  TOP
//
//  Created by ianluo on 13-12-12.
//  Copyright (c) 2013年 WOD. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import "WODImagePickerViewController.h"

typedef enum
{
	System = 0, //default value
	Custom,
}ImageSource;

@interface WODImageScrollViewController : UIViewController

@property (nonatomic, assign) NSUInteger currentPage;
@property (nonatomic, strong) ALAssetsGroup * assetsGroup;
@property (nonatomic, strong) NSArray * images;
@property (nonatomic, weak) WODImagePickerViewController * imagePickerViewController;
@property (nonatomic, assign) ImageSource imageSource;

@end