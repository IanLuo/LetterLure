//
//  WODConstants.h
//  TOP
//
//  Created by ianluo on 13-12-13.
//  Copyright (c) 2013年 WOD. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UIView+Layout.h"
#import "Masonry.h"

//#define DEBUGMODE

#define VERSION_NUMBER @"2.0"

#pragma mark - colors

#define color_black                        [UIColor colorWithRed:0.19 green:0.2 blue:0.23 alpha:1]
#define color_white                        [UIColor colorWithRed:0.96 green:0.96 blue:0.96 alpha:1]
#define color_gray                         [UIColor colorWithRed:0.76 green:0.76 blue:0.76 alpha:1]

#define control_button_size 40

#define HEIGHT_STATUS_AND_NAV_BAR 64
#define HEIGHT_STATUS_AND_NAV_BAR_LANDSCAPE 30
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

/*******************************************************************************/
/*                               system font                                    */
/*******************************************************************************/

#define font_name  @""
#define font_name_bold @""


/*******************************************************************************/
/*                               short cuts                                    */
/*******************************************************************************/



#define WODDebug(format, ...) logIMP(format"\n%s (line %d)",##__VA_ARGS__, __FUNCTION__,__LINE__ )
#define WODError(format, ...) errIMP(format"\n%s (line %d)",##__VA_ARGS__, __FUNCTION__,__LINE__ )
#define iStr(key) NSLocalizedString(key, nil)

#define ws(weakSelf)  __weak __typeof(&*self)weakSelf = self;
#define ss(strongSelf)  __strong __typeof(&*self)strongSelf = self;

/*******************************************************************************/
/*                                  调试输出                                    */
/*******************************************************************************/

static inline void
logIMP(NSString * format,...)
{
#ifdef DEBUGMODE
    va_list vars;
    va_start(vars, format);
    NSLogv(format, vars);
    va_end(vars);
#endif
}

/*******************************************************************************/
/*                                  错误输出                                    */
/*******************************************************************************/

static inline void
errIMP(NSString * format,...)
{
    printf("ERROR \n");
    va_list vars;
    va_start(vars, format);
    NSLogv(format, vars);
    va_end(vars);
}

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

static inline id
ObjectOrEmptyString(id obj)
{
    BOOL flag = YES;
    
    if (obj == nil)
    {
        flag = NO;
    }
    else if (obj == [NSNull null])
    {
        flag = NO;
    }
    
    return flag ? obj : @"";
}

static inline BOOL
isPad()
{
    return UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad;
}

static inline BOOL
isVertical()
{
    UIInterfaceOrientation orientation = [[UIApplication sharedApplication]statusBarOrientation];
    
    return (orientation == UIInterfaceOrientationPortrait ||
                orientation == UIInterfaceOrientationPortraitUpsideDown);
}

static inline NSUInteger
topOffset()
{
    if (isVertical())
    {
        return HEIGHT_STATUS_AND_NAV_BAR;
    }
    else
    {
        return HEIGHT_STATUS_AND_NAV_BAR_LANDSCAPE;
    }
}

@interface WODConstants : NSObject

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
