//
//  WODPatternPickerViewController.h
//  TOP
//
//  Created by ianluo on 13-12-12.
//  Copyright (c) 2013年 WOD. All rights reserved.
//

#import <UIKit/UIKit.h>

@class WODPatternPicker;

@protocol  WODPatternPickerDelegate<NSObject>

- (void)didFinishPickerPattern:(CGPatternRef)pattern patternPicker:(WODPatternPicker *)patternPicker;
- (void)didCancelPatternPicker:(WODPatternPicker *)patternPicker;

@end

@interface WODPatternPicker : UIView

@property (nonatomic,weak) id<WODPatternPickerDelegate> delegate;

@end
