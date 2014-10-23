//
//  WODTextViewTextLayer.h
//  TOP
//
//  Created by ianluo on 14-1-3.
//  Copyright (c) 2014年 WOD. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "WODTextView.h"

@interface WODTextViewTextLayerDelegate : NSObject

@property (weak, nonatomic) WODTextView * textView;

- (UIImage *)renderImage;
- (UIImage *)renderFullSizeImage:(float)fullsizeScale;
@end
