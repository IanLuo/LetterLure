//
//  WODExportToOtherAppviewController.m
//  TOP
//
//  Created by ianluo on 14-3-25.
//  Copyright (c) 2014年 WOD. All rights reserved.
//

#import "WODExportToOtherAppviewController.h"

@interface WODExportToOtherAppviewController ()<UIDocumentInteractionControllerDelegate>

@end

@implementation WODExportToOtherAppviewController
- (UIDocumentInteractionController *)documentInteractionController
{
	if (!_documentInteractionController)
	{
        _documentInteractionController = [UIDocumentInteractionController interactionControllerWithURL:self.fileURL];
		_documentInteractionController.UTI = [self documentUIT];
		_documentInteractionController.delegate = self;
		
	}
	return _documentInteractionController;
}

- (NSString *)documentUIT
{
	return @"public.image";
}

- (NSURL *)fileURL
{
	if (!_fileURL)
	{
		_fileURL = [NSURL fileURLWithPath:[self filePath]];
	}
	return _fileURL;
}

- (NSString *)filePath
{
	return [NSTemporaryDirectory() stringByAppendingString:@"imageToShare.jpeg"];
}

- (UIImageView *)imageView
{
	if (!_imageView)
	{
		_imageView = [UIImageView new];
		_imageView.contentMode = UIViewContentModeScaleAspectFit;
	}
	return _imageView;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
	
	self.title = NSLocalizedString(@"VC_TITLE_PICK_AN_APP", nil);
	
	self.imageView.translatesAutoresizingMaskIntoConstraints = NO;
	self.view.backgroundColor = color_black;
	
	[self.view addSubview:self.imageView];
	
	[self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|-[imageView]-|" options:0 metrics:nil views:@{@"imageView":self.imageView}]];
	[self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-[imageView]-|" options:0 metrics:nil views:@{@"imageView":self.imageView}]];
	
	[self.navigationItem setRightBarButtonItem:[[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(dismiss)]];
	[self.navigationItem setLeftBarButtonItem:[[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(showApps)]];
}

- (void)dismiss
{
	[self.documentInteractionController dismissMenuAnimated:NO];
	
	if([self.delegate respondsToSelector:@selector(completeExportingToOtherApp:)])
	{
		[self.delegate completeExportingToOtherApp:self];
	}
}

- (void)viewDidAppear:(BOOL)animated
{
	[super viewDidAppear:animated];
	[self showApps];
}

- (void)showApps
{
	[self.documentInteractionController presentOpenInMenuFromBarButtonItem:self.navigationItem.leftBarButtonItem animated:YES];
}

- (void)documentInteractionControllerDidDismissOpenInMenu:(UIDocumentInteractionController *)controller
{
	[self dismiss];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setImage:(UIImage *)image
{
	self.imageView.image = image;
	NSError * error;
	[UIImageJPEGRepresentation(image,1.0) writeToFile:self.fileURL.path options:0 error:&error];
	if (error)
	{
		NSLog(@"Error when saving image for share for other apps:\n%@",error);
	}
}

- (UIDocumentInteractionController *) setupControllerWithURL: (NSURL*) fileURL usingDelegate: (id <UIDocumentInteractionControllerDelegate>) interactionDelegate {
	UIDocumentInteractionController *interactionController = [UIDocumentInteractionController interactionControllerWithURL: fileURL];
	interactionController.delegate = interactionDelegate;
	return interactionController;
}

- (void)documentInteractionController:(UIDocumentInteractionController *)controller willBeginSendingToApplication:(NSString *)application
{
	[self dismiss];
}

@end
