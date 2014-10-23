//
//  WODExportToOtherAppviewController.m
//  TOP
//
//  Created by ianluo on 14-3-25.
//  Copyright (c) 2014年 WOD. All rights reserved.
//

#import "ExportToInstagramPreviewController.h"

@interface ExportToInstagramPreviewController ()

@end

@implementation ExportToInstagramPreviewController

- (NSString *)filePath
{
	return [NSTemporaryDirectory() stringByAppendingString:@"imageToShare.igo"];
}

- (NSString *)documentUIT
{
	return @"public/jpeg";
}

- (void)setImage:(UIImage *)image
{
	CGRect rect;
	UIImage *resultImage;
	
	if (image.size.width != image.size.height)
	{
		if (image.size.width > image.size.height)
		{
			float originX = (image.size.width - image.size.height)/2;
			rect = CGRectMake(originX, 0, image.size.height, image.size.height);
		}
		else if(image.size.width < image.size.height)
		{
			float originY = (image.size.height - image.size.width)/2;
			rect = CGRectMake(0, originY, image.size.width, image.size.width);
		}
		
		UIGraphicsBeginImageContextWithOptions(rect.size, YES, 0);
		CGContextTranslateCTM(UIGraphicsGetCurrentContext(), -rect.origin.x, -rect.origin.y);
		[image drawAtPoint:CGPointZero];
		resultImage = UIGraphicsGetImageFromCurrentImageContext();
		UIGraphicsEndImageContext();
	}
	else
	{
		resultImage = image;
	}
	
	self.imageView.image =  resultImage;
	NSError * error;
	[UIImageJPEGRepresentation(resultImage,1.0) writeToFile:self.fileURL.path options:0 error:&error];
	if (error)
	{
		NSLog(@"Error when saving image for share for other apps:\n%@",error);
	}
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
	
	self.title = NSLocalizedString(@"VC_TITLE_SEND_TO_INSTAGRAM", nil);
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
@end
