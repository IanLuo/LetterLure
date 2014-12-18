//
//  WODConstants.m
//  TOP
//
//  Created by ianluo on 13-12-13.
//  Copyright (c) 2013年 WOD. All rights reserved.
//

#import "WODConstants.h"

@implementation WODConstants

static NSArray * CurrentPattern;
#pragma mark - colors

//+ (NSArray *)themes
//{
//	return @[THEME_DARK,THEME_GREEN,THEME_GREEN2,THEME_BLUE,THEME_DEEP_BLUE,THEME_ORGANGE,THEME_PURPLE,THEME_RED,THEME_YELLOW];
//}
//
//+ (void)setUpUITheme:(int)index
//{
//	CurrentPattern = [self themes][index];
//
//	[UIBarButtonItem configureFlatButtonsWithColor:[UIColor clearColor]
//								  highlightedColor:[UIColor clearColor]
//									  cornerRadius:0];
//	[[UIBarButtonItem appearance] setTitleTextAttributes:@{NSFontAttributeName:[UIFont boldFlatFontOfSize:12],NSForegroundColorAttributeName:WODConstants.COLOR_TEXT_TITLE} forState:UIControlStateNormal];
//	[[UIBarButtonItem appearance] setTintColor:WODConstants.COLOR_TEXT_TITLE];
//	[[UINavigationBar appearance] setTitleTextAttributes:@{NSFontAttributeName:[UIFont boldFlatFontOfSize:12],NSForegroundColorAttributeName:WODConstants.COLOR_TEXT_TITLE}];
//	[[UINavigationBar appearance] setBarTintColor:WODConstants.COLOR_NAV_BAR];
//	[[UINavigationBar appearance] setTintColor:WODConstants.COLOR_TEXT_TITLE];
//
//	[[NSNotificationCenter defaultCenter]postNotificationName:NOTIFICATION_THEME_CHANGED object:nil];
//}
//
//+ (void)setTheme:(NSArray *)pattern
//{
//	CurrentPattern = pattern;
//}
//
//+ (NSArray *)CURRENT_THEM
//{
//	return CurrentPattern;
//}
//
//+ (UIColor*) COLOR_TAB_BACKGROUND
//{
//	return [self CURRENT_THEM][0];
//}
//
//+ (UIColor*) COLOR_TOOLBAR_BACKGROUND
//{
//	return [self CURRENT_THEM][0];
//}
//
//+ (UIColor*) COLOR_TOOLBAR_BACKGROUND_SECONDARY
//{
//	return [UIColor cloudsColor];
//}
//
//+ (UIColor*) COLOR_NAV_BAR
//{
//	return [self CURRENT_THEM][0];
//}
//
//+ (UIColor*) COLOR_DIALOG_BACKGROUND
//{
//	return [self CURRENT_THEM][0];
//}
//
//+ (UIColor*) COLOR_VIEW_BACKGROUND
//{
//	return [self CURRENT_THEM][0];
//}
//
//+ (UIColor*) COLOR_VIEW_BACKGROUND_DARK
//{
//	return [self CURRENT_THEM][0];
//}
//
//+ (UIColor*) COLOR_CONTROLLER
//{
//	return [self CURRENT_THEM][0];
//}
//
//+ (UIColor*) COLOR_CONTROLLER_HIGHTLIGHT
//{
//	return [self CURRENT_THEM][0];
//}
//
//+ (UIColor*) COLOR_CONTROLLER_SHADOW
//{
//	return [self CURRENT_THEM][0];
//}
//
//+ (UIColor*) COLOR_CONTROLLER_DISABLED
//{
//	return [UIColor silverColor];
//}
//
//+ (UIColor*) COLOR_CONTROLLER_SELECTED
//{
//	return [self CURRENT_THEM][0];
//}
//
//+ (UIColor*) COLOR_TEXT_TITLE
//{
//	return [UIColor cloudsColor];
//}
//
//+ (UIColor*) COLOR_TEXT_CONTENT
//{
//	return [UIColor concreteColor];
//}
//
//+ (UIColor*) COLOR_TEXT_ACTIONSHEET
//{
//	return [self CURRENT_THEM][1];
//}
//
//+ (UIColor*) COLOR_ITEM_PICKER
//{
//	return [self CURRENT_THEM][1];
//}
//
//+ (UIColor*) COLOR_ITEM_PICKER_CONTROL_ITEM
//{
//	return [self CURRENT_THEM][0];
//}
//
//+ (UIColor*) COLOR_ITEM_PICKER_CUSTOM_ITEM
//{
//	return [self CURRENT_THEM][0];
//}
//
//+ (UIColor*) COLOR_LINE_COLOR
//{
//	return [UIColor cloudsColor];
//}

#pragma mark - image processing

+ (UIImage *)resizeImageToFullScreenSize:(UIImage *)sourceImage
{
	CGSize imageSize = CGSizeApplyAffineTransform(sourceImage.size, CGAffineTransformMakeScale(sourceImage.scale, sourceImage.scale));
	CGSize windowSize = CGSizeApplyAffineTransform([self currentSize], CGAffineTransformMakeScale([UIScreen mainScreen].scale, [UIScreen mainScreen].scale));
	
	float scale = 1.0;
	
	if (imageSize.width > windowSize.width)
	{
		scale = imageSize.width / windowSize.width;
	}
	
	if (imageSize.height > windowSize.height)
	{
		scale = MAX(scale, imageSize.height / windowSize.height);
	}
	
	UIGraphicsBeginImageContextWithOptions(imageSize, NO, 1);
	[sourceImage drawAtPoint:CGPointZero];
	CGContextScaleCTM(UIGraphicsGetCurrentContext(), 1.0 / scale, 1.0 / scale);
	UIImage * scaledImage = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
	
	return scaledImage;
}

+ (UIImage *)resizeImage:(UIImage *)image scale:(float)s
{
	CGSize newSize = CGSizeMake(floor(image.size.width * image.scale  * s), floor(image.size.height * image.scale * s));
	UIGraphicsBeginImageContextWithOptions(newSize, NO, 1);
	[image drawInRect:(CGRect){(CGPoint){0,0},newSize}];
	UIImage * newImage = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
	return newImage;
}

+ (UIImage *)resizeImage:(UIImage *)image fitSize:(CGSize)size
{
	float imageScale = image.scale;

	CGSize viewSize = size;
	CGSize originalSize = CGSizeApplyAffineTransform(image.size, CGAffineTransformMakeScale(imageScale, imageScale));
	CGFloat resizeTimes = 1.0;
	
	CGFloat ratioW = viewSize.width/originalSize.width;
	CGFloat rationH = viewSize.height/originalSize.height;
	
	resizeTimes = MIN(ratioW, rationH);
	UIImage * resultImage = [self resizeImage:image scale:resizeTimes];
	
	return resultImage;
}

+ (CGSize)calculateNewSizeForImage:(UIImage *)image maxSide:(float)s
{
	CGSize originalSize = CGSizeApplyAffineTransform(image.size, CGAffineTransformMakeScale(image.scale, image.scale));
	CGSize newSize = originalSize;
	
	if (originalSize.width > originalSize.height)
	{
		if (originalSize.width > s)
		{
			newSize = CGSizeApplyAffineTransform(originalSize, CGAffineTransformMakeScale(s/originalSize.width, s/originalSize.width));
		}
	}
	else
	{
		if (originalSize.height > s)
		{
			newSize = CGSizeApplyAffineTransform(originalSize, CGAffineTransformMakeScale(s/originalSize.height, s/originalSize.height));
		}
	}
	
	return newSize;
}

+ (UIImage *)resizeImage:(UIImage *)image maxSide:(float)s
{
	return [WODConstants resizeImage:image fitSize:[WODConstants calculateNewSizeForImage:image maxSide:s]];
}

+ (UIImage *)cropImage:(UIImage *)image rect:(CGRect)r
{
	CGSize size = CGSizeMake(image.size.width * image.scale, image.size.height * image.scale);
	CGRect cropRect = CGRectMake((size.width - r.size.width)/2, (size.height - r.size.height)/2, r.size.width, r.size.height);

	CGImageRef newCGImage = CGImageCreateWithImageInRect(image.CGImage,cropRect);
	
	UIImage * newImage = [UIImage imageWithCGImage:newCGImage];
	CGImageRelease(newCGImage);
	
	return newImage;
}

#pragma mark - disk caching

+ (void)addOrUpdateImageCache:(UIImage *)image forKey:(NSString*)key
{
	NSString * path = [NSTemporaryDirectory() stringByAppendingFormat:@"%@.png",key];
	
	/*BOOL result =*/ [UIImagePNGRepresentation(image) writeToFile:path atomically:NO];
	
//	NSLog(@"%@ to save cache file (%@)",result == YES ? @"sucess" : @"fail", key);
}

+ (UIImage *)getCachedImageForKey:(NSString *)key
{
	NSString * path = [NSTemporaryDirectory() stringByAppendingFormat:@"%@.png",key];
	
	if ([[NSFileManager defaultManager] fileExistsAtPath:path])
	{
#ifdef DEBUGMODE
		NSLog(@"found image from cached (%@)",key);
#endif
		return [UIImage imageWithContentsOfFile:path];
	}
	else
	{
#ifdef DEBUGMODE
		NSLog(@"didn't find image from cached (%@)",key);
#endif
		return nil;
	}
}

+ (void)removeImageCacheWithKey:(NSString *)key
{
	NSFileManager * fm = [NSFileManager defaultManager];
	NSError * error;
	if ([fm fileExistsAtPath:[NSTemporaryDirectory() stringByAppendingFormat:@"%@.png",key]])
		[fm removeItemAtPath:[NSTemporaryDirectory() stringByAppendingFormat:@"%@.png",key] error:&error];

	if (error)
		NSLog(@"faile to delete cache(%@): %@",key,error);
#ifdef DEBUGMODE
	else
		NSLog(@"cache(%@) cleared",key);
#endif
}


+ (BOOL)isPortrait
{
	UIInterfaceOrientation toInterfaceOrientation = [[UIApplication sharedApplication]statusBarOrientation];
	return toInterfaceOrientation == UIInterfaceOrientationPortrait || toInterfaceOrientation == UIInterfaceOrientationPortraitUpsideDown;
}


#pragma mark - size -
+(CGSize) currentSize
{
    return [self sizeInOrientation:[UIApplication sharedApplication].statusBarOrientation];
}

+(CGSize) sizeInOrientation:(UIInterfaceOrientation)orientation
{
    CGSize size = [UIScreen mainScreen].bounds.size;
//    UIApplication *application = [UIApplication sharedApplication];
//    if (UIInterfaceOrientationIsLandscape(orientation))
//    {
//        size = CGSizeMake(size.height, size.width);
//    }
//    if (application.statusBarHidden == NO)
//    {
//        size.height -= MIN(application.statusBarFrame.size.width, application.statusBarFrame.size.height);
//    }
    return size;
}

+(CGFloat) navigationbarHeight
{
	if (([UIApplication sharedApplication].statusBarOrientation == UIInterfaceOrientationLandscapeLeft || [UIApplication sharedApplication].statusBarOrientation == UIInterfaceOrientationLandscapeRight) && UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
	{
		return SIZE_NAVIGATIONBAR_LANDSCAPE;
	}
	else
	{
		return SIZE_NAVIGATIONBAR_PORTRAIT;
	}
}

@end
