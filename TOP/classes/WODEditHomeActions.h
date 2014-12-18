//
//  WODEditHomeActions.h
//  TOP
//
//  Created by ianluo on 14-8-20.
//  Copyright (c) 2014年 WOD. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WODButton.h"
#import "EditHomeViewController.h"

@interface WODEditHomeActions : NSObject<UIAlertViewDelegate>

@property (nonatomic, strong) WODButton * previewButton;
@property (nonatomic, strong) WODButton * deleteButton;
@property (nonatomic, strong) WODButton * editTextButton;
@property (nonatomic, weak)EditHomeViewController * editHomeController;

- (void)setOpacity:(id)sender;
- (void)applyEffect:(UIButton *)button;
- (void)chooseText:(UIButton *)button;
- (void)typesetter:(UIButton *)button;
- (void)editText:(UIButton *)button;
- (void)deleteCurrentText;
@end
