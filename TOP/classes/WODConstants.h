//
//  WODConstants.h
//  TOP
//
//  Created by ianluo on 13-12-13.
//  Copyright (c) 2013年 WOD. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UIColor+FlatUI.h"
#import "UIFont+FlatUI.h"
#import "UIBarButtonItem+FlatUI.h"
#import "UISlider+FlatUI.h"
#import "UITableViewCell+FlatUI.h"
#import "FUIAlertView.h"
#import "UIView+Layout.h"

#define DEBUGMODE

#define VERSION_NUMBER @"1.01"

#pragma mark - colors
#pragma mark - theme

//themes
#define THEME_GREEN @[[UIColor greenSeaColor],[UIColor turquoiseColor]]
#define THEME_GREEN2 @[[UIColor nephritisColor],[UIColor emerlandColor]]
#define THEME_PURPLE @[[UIColor wisteriaColor],[UIColor amethystColor]]
#define THEME_YELLOW @[[UIColor tangerineColor],[UIColor sunflowerColor]]
#define THEME_ORGANGE @[[UIColor pumpkinColor],[UIColor carrotColor]]
#define THEME_RED @[[UIColor pomegranateColor],[UIColor alizarinColor]]
#define THEME_BLUE @[[UIColor belizeHoleColor],[UIColor peterRiverColor]]
#define THEME_DEEP_BLUE @[[UIColor midnightBlueColor],[UIColor wetAsphaltColor]]
#define THEME_DARK @[[UIColor darkdarkColor],[UIColor darkbrightColor]]

//colors
#define COLOR_RETRO_BLUE [UIColor retroBlue]

#define FONT_SIZE_NORMAL 12
#define FONT_SIZE_TITLE 18
#define FONT_SIZE_LABEL 20
#define FONT_SIZE_LABEL_BIG 25

#define control_button_size 40

#define SIZE_NAVIGATIONBAR_PORTRAIT 44
#define SIZE_NAVIGATIONBAR_LANDSCAPE 30

#define WOD_TOOLBAR_HEIGHT_HORIZEN 30
#define WOD_TOOLBAR_HEIGHT_PORTRAIT 50

#define HEIGHT_TOOLBAR_PORTRAIT 50
#define HEIGHT_TOOLBAR_LANDSCAPE 30

#define DEFAULT_FONT_SIZE_IPAD 80
#define DEFAULT_FONT_SIZE_IPHONE 40

#define KEY_UNREGISTERED_FONTS @"key_unregistered_fonts"

#define KEY_IS_RETURN_LAUNCH @"KEY_IS_RETURN_LAUNCH"

#define KEY_SAVED_THEME_INDEX @"KEY_SAVED_THEME_INDEX"

#define NOTIFICATION_THEME_CHANGED @"NOTIFICATION_THEME_CHANGED"

#define NOTIFICATION_RENDER_COMPLETE @"RENDER_COMPLETE"

#define appStoreID 872341374

static inline CGPoint
CenterPoint(CGRect rect)
{
	return CGPointMake((rect.origin.x + rect.size.width)/2, (rect.origin.y + rect.size.height)/2);
}

static inline double
radians (double degree)
{
	return degree * M_PI / 180;
}

@interface WODConstants : NSObject

#pragma mark - image processing
+ (NSArray *)themes;
+ (void)setUpUITheme:(int)theme;
+ (NSArray *)CURRENT_THEM;
+ (UIColor*) COLOR_TAB_BACKGROUND;
+ (UIColor*) COLOR_TOOLBAR_BACKGROUND;
+ (UIColor*) COLOR_TOOLBAR_BACKGROUND_SECONDARY;
+ (UIColor*) COLOR_NAV_BAR;

+ (UIColor*) COLOR_DIALOG_BACKGROUND;

+ (UIColor*) COLOR_VIEW_BACKGROUND;
+ (UIColor*) COLOR_VIEW_BACKGROUND_DARK;

+ (UIColor*) COLOR_CONTROLLER;
+ (UIColor*) COLOR_CONTROLLER_HIGHTLIGHT;
+ (UIColor*) COLOR_CONTROLLER_SHADOW;
+ (UIColor*) COLOR_CONTROLLER_DISABLED;
+ (UIColor*) COLOR_CONTROLLER_SELECTED;

+ (UIColor*) COLOR_TEXT_TITLE;
+ (UIColor*) COLOR_TEXT_CONTENT;
+ (UIColor*) COLOR_TEXT_ACTIONSHEET;

+ (UIColor*) COLOR_ITEM_PICKER;
+ (UIColor*) COLOR_ITEM_PICKER_CONTROL_ITEM;
+ (UIColor*) COLOR_ITEM_PICKER_CUSTOM_ITEM;

+ (UIColor*) COLOR_LINE_COLOR;

+ (CGSize)calculateNewSizeForImage:(UIImage *)image maxSide:(float)s;

+ (UIImage *)resizeImageToFullScreenSize:(UIImage *)sourceImage;

+ (UIImage *)resizeImage:(UIImage *)image scale:(float)s;

+ (UIImage *)resizeImage:(UIImage *)image fitSize:(CGSize)size;

+ (UIImage *)cropImage:(UIImage *)image rect:(CGRect)r;

+ (UIImage *)resizeImage:(UIImage *)image maxSide:(float)s;

#pragma mark - disk caching

+ (void)addOrUpdateImageCache:(UIImage *)obj forKey:(NSString*)key;

+ (UIImage *)getCachedImageForKey:(NSString *)key;

+ (void)removeImageCacheWithKey:(NSString *)key;

+ (BOOL)isPortrait;

#pragma mark - size -
+(CGSize) currentSize;
+(CGSize) sizeInOrientation:(UIInterfaceOrientation)orientation;
+(CGFloat) navigationbarHeight;

@end
