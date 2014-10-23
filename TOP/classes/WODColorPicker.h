//
//  WODColorPickerViewController.h
//  TOP
//
//  Created by ianluo on 13-12-12.
//  Copyright (c) 2013年 WOD. All rights reserved.
//

#import <UIKit/UIKit.h>

@class WODColorPicker;
@protocol WODColorPickerDelegate <NSObject>

- (void)didFinishPickingColor:(UIColor *)color picker:(WODColorPicker *)colorPicker;

@optional
- (void)didCancelColorPicker:(WODColorPicker *)colorPicker;

@end

@interface WODColorPicker : UIView

@property (nonatomic,weak)id<WODColorPickerDelegate> delegate;

- (UIColor *)defaultColor;

@end

@interface WODColorPickerCell : UICollectionViewCell

@end
