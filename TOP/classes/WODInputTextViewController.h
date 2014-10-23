//
//  WODInputTextViewController.h
//  TOP
//
//  Created by ianluo on 13-12-25.
//  Copyright (c) 2013年 WOD. All rights reserved.
//

#import <UIKit/UIKit.h>

@class WODInputTextViewController;
@protocol WODInputTextViewDelegate <NSObject>

- (void)didFinishInputtingText:(WODInputTextViewController *)inputTextViewController text:(NSAttributedString *)attrString;
- (void)didCancelInputtingText:(WODInputTextViewController *)inputTextViewController;

@end

typedef enum{
	EditTypeNew,
	EditTypeModify,
}EditType;

@interface WODInputTextViewController : UIViewController

@property (nonatomic, strong) UITextView * textView;
@property (nonatomic, weak) id<WODInputTextViewDelegate> delegate;
@property (nonatomic, assign) EditType editType;

@end
