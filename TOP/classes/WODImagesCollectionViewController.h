//
//  WODImagesCollectionViewController.h
//  TOP
//
//  Created by ianluo on 13-12-16.
//  Copyright (c) 2013年 WOD. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import "WODImagePickerViewController.h"

@interface WODImagesCollectionViewController : UICollectionViewController

@property (nonatomic, strong) ALAssetsGroup * assetsGroup;
@property (nonatomic, weak) WODImagePickerViewController * imagePickerViewController;

@property (nonatomic, strong) NSIndexPath * currentIndexpath;

@end

@interface WODImageCell : UICollectionViewCell
@property (nonatomic, strong)UIImageView * imageView;
@end