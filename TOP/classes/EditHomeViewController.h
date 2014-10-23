//
//  EditHomeViewController.h
//  TOP
//
//  Created by ianluo on 13-12-12.
//  Copyright (c) 2013年 WOD. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WODOpenGLESStageView.h"
#import "WODTextLayerManager.h"
#import "WODInputTextViewController.h"
#import "WODItemPicker.h"
#import "WODToolbar.h"
#import "WODFreeDrawViewController.h"
#import "WODShapeViewController.h"
#import "WODEffectPackageManager.h"
#import "WODEffectsPackageViewController.h"

@interface EditHomeViewController : UIViewController<UINavigationControllerDelegate,WODInputTextViewDelegate,UIActionSheetDelegate,WODTypeSetterDelegate,WODEffectsPackageDelegate>
{
	@public
		BOOL customNavigationTransition;
}

@property (nonatomic,strong) WODOpenGLESStageView * openGLStageView;
@property (nonatomic, strong) WODTextLayerManager * textLayerManager;
@property (nonatomic, strong) NSString * originalImageCachKey;
@property (nonatomic, assign) CGSize originalImageSize;
@property (nonatomic, strong) WODItemPicker * currentItemPicker;
@property (nonatomic, strong) WODToolbar * toolbar;

- (void)checkControlVisiability;
- (UIImage *)getSavedBackgroundImage;
- (void)fadeNavigationPush:(UIViewController *)controller;
- (void)fadeNavigationPop;
- (void)selectTextView:(WODTextView *)textView;
- (void)addText;
- (void)setBackgroundImage:(UIImage *)image;
@end
