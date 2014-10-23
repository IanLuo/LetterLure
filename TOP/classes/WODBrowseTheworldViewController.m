//
//  WODBrowseTheworldViewController.m
//  TOP
//
//  Created by ianluo on 14-5-15.
//  Copyright (c) 2014年 WOD. All rights reserved.
//

#import "WODBrowseTheworldViewController.h"

@interface WODBrowseTheworldViewController ()<UIWebViewDelegate>

@property (nonatomic, strong) UIWebView * webView;

@end

@implementation WODBrowseTheworldViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	
	_webView = [[UIWebView alloc]init];
	self.webView.delegate = self;
	
	self.view = self.webView;
	
	self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(dismiss)];
	
	self.navigationItem.leftBarButtonItems = @[[[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self.webView action:@selector(reload)],[[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemReply target:self.webView action:@selector(goBack)]];
}

- (void)viewDidAppear:(BOOL)animated
{
	[super viewDidAppear:animated];
	
	[self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"http://instagram.com/letterlure"]]];
	[self.webView reload];
}

- (void)dismiss
{
	[self dismissViewControllerAnimated:YES completion:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)webViewDidStartLoad:(UIWebView *)webView
{
	UIActivityIndicatorView * indicatorView = [UIActivityIndicatorView new];
	[indicatorView startAnimating];
	
	[self.navigationItem setTitleView:indicatorView];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
	[self.navigationItem setTitleView:nil];
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
	[self.navigationItem setTitleView:nil];
	NSLog(@"%@",error.description);
}

@end
