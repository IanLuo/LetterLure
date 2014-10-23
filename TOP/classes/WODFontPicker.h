//
//  WODFontPicker.h
//  TOP
//
//  Created by ianluo on 13-12-12.
//  Copyright (c) 2013年 WOD. All rights reserved.
//

#import <UIKit/UIKit.h>

@class WODFontPicker;
@protocol WODFontPickerDelegate <NSObject>

- (void)didFinishPickingFont:(UIFont *)font picker:(WODFontPicker *)colorPicker;

@optional
- (void)didCancelFontPicker:(WODFontPicker *)colorPicker;

@end

@interface WODFontPicker : UIView

@property (nonatomic,weak)id<WODFontPickerDelegate> delegate;

@property (nonatomic, strong)NSString * currentFontFamily;
@property (nonatomic, strong)NSString * currentFontName;
@property (nonatomic, assign)NSInteger currentFontSize;
@property (nonatomic, weak) UITextView * textView;

- (void)setupSelectedValues;

@end
