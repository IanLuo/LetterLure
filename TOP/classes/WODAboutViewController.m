//
//  WODAboutViewController.m
//  TOP
//
//  Created by ianluo on 14-5-2.
//  Copyright (c) 2014年 WOD. All rights reserved.
//

#import "WODAboutViewController.h"
#import "WODButton.h"
//#import <MessageUI/MessageUI.h>
#import <Social/Social.h>
#import "UVConfig.h"
#import "UserVoice.h"

@interface WODAboutViewController ()//<MFMailComposeViewControllerDelegate>

@property (nonatomic, strong)UILabel * version;

@end

@implementation WODAboutViewController

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
	
	[self setTitle:NSLocalizedString(@"ABOUT", nil)];
    // Do any additional setup after loading the view.
	[self setEdgesForExtendedLayout:UIRectEdgeNone];
	
	self.view.backgroundColor = color_black;
		
	WODButton * rate = [WODButton new];
	rate.translatesAutoresizingMaskIntoConstraints = NO;
	[rate setTitle:NSLocalizedString(@"RATE", nil) forState:UIControlStateNormal];
	[rate addTarget:self action:@selector(rate) forControlEvents:UIControlEventTouchUpInside];
	[self.view addSubview:rate];
	
	UILabel * rateTitle = [UILabel new];
	[rateTitle setNumberOfLines:3];
	rateTitle.textColor = color_white;
	rateTitle.font = [UIFont systemFontOfSize:14];
	rateTitle.translatesAutoresizingMaskIntoConstraints = NO;
	[rateTitle setText:NSLocalizedString(@"RATE_TITLE", nil)];
	[self.view addSubview:rateTitle];
	
	WODButton * support = [WODButton new];
	support.translatesAutoresizingMaskIntoConstraints = NO;
	[support setTitle:NSLocalizedString(@"SUPPORT", NIL) forState:UIControlStateNormal];
	[support addTarget:self action:@selector(support) forControlEvents:UIControlEventTouchUpInside];
	[self.view addSubview:support];
	
	UILabel * supportTitle = [UILabel new];
	[supportTitle setNumberOfLines:2];
	supportTitle.textColor = color_white;
	supportTitle.font = [UIFont systemFontOfSize:14];
	supportTitle.translatesAutoresizingMaskIntoConstraints = NO;
	[supportTitle setText:NSLocalizedString(@"SUPPORT_TITLE", nil)];
	[self.view addSubview:supportTitle];
	
	UILabel * shareToFriendsTitle = [UILabel new];
	[shareToFriendsTitle setNumberOfLines:2];
	shareToFriendsTitle.textColor = color_white;
	shareToFriendsTitle.font = [UIFont systemFontOfSize:14];
	shareToFriendsTitle.translatesAutoresizingMaskIntoConstraints = NO;
	[shareToFriendsTitle setText:NSLocalizedString(@"SHARE_TO_FRIEND_MSG", nil)];
	[self.view addSubview:shareToFriendsTitle];
	
	UIView * shareButtons = [self shareToFriendsView];
	shareButtons.translatesAutoresizingMaskIntoConstraints = NO;
	[self.view addSubview:shareButtons];
	
	_version = [UILabel new];
	[_version setTextAlignment:NSTextAlignmentCenter];
	[_version setNumberOfLines:2];
	_version.textColor = color_white;
	_version.font = [UIFont systemFontOfSize:12];
	_version.translatesAutoresizingMaskIntoConstraints = NO;
	[_version setText:[NSString stringWithFormat:@"Version %@ \n WOD STUDIOS@ 2014 ALL RIGHTS RESERVED",VERSION_NUMBER]];
	[self.view addSubview:_version];
	
	NSDictionary * views = NSDictionaryOfVariableBindings(rate,rateTitle,support,supportTitle,shareToFriendsTitle,shareButtons);
	[self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-[supportTitle]-[support]-[rateTitle]-[rate]-[shareToFriendsTitle]-[shareButtons]" options:0 metrics:nil views:views]];
	[self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|-[rateTitle]-|" options:0 metrics:nil views:views]];
	[self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|-[rate]-|" options:0 metrics:nil views:views]];
	[self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|-[supportTitle]-|" options:0 metrics:nil views:views]];
	[self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|-[support]-|" options:0 metrics:nil views:views]];
	[self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|-[shareToFriendsTitle]-|" options:0 metrics:nil views:views]];
	[self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|-[shareButtons]-|" options:0 metrics:nil views:views]];

	[self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|-[version]-|" options:0 metrics:nil views:@{@"version":self.version}]];
	[self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[version]-|" options:0 metrics:nil views:@{@"version":self.version}]];
	
	UIBarButtonItem * done = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(done)];
	[self.navigationItem setRightBarButtonItem:done];
}

- (UIView *)shareToFriendsView
{
	UIView * view = [UIView new];
	
	WODButton * facebookButton = [WODButton new];
	facebookButton.translatesAutoresizingMaskIntoConstraints = NO;
	[facebookButton setTitle:@"Facebook" forState:UIControlStateNormal];
	[facebookButton addTarget:self action:@selector(shareWithFacebook) forControlEvents:UIControlEventTouchUpInside];
	[view addSubview:facebookButton];
	
	WODButton * twitterButton = [WODButton new];
	[twitterButton setTitle:@"Twitter" forState:UIControlStateNormal];
	twitterButton.translatesAutoresizingMaskIntoConstraints = NO;
	[twitterButton addTarget:self action:@selector(shareWithTwitter) forControlEvents:UIControlEventTouchUpInside];
	[view addSubview:twitterButton];
	
	[view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|-[facebook(twitter)]-[twitter]-|" options:0 metrics:nil views:@{@"facebook":facebookButton,@"twitter":twitterButton}]];
	[view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-2-[facebook]-2-|" options:0 metrics:nil views:@{@"facebook":facebookButton,@"twitter":twitterButton}]];
	[view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-2-[twitter]-2-|" options:0 metrics:nil views:@{@"facebook":facebookButton,@"twitter":twitterButton}]];
	
	return view;
}

static const NSString * appLink = @"https://itunes.apple.com/us/app/letter-lure/id872341374?ls=1&mt=8";

- (void)shareWithFacebook
{
	SLComposeViewController *facebookComposer = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeFacebook];
	SLComposeViewControllerCompletionHandler __block handler = ^(SLComposeViewControllerResult result){
		[facebookComposer dismissViewControllerAnimated:YES completion:nil];
	};
	[facebookComposer setInitialText:[NSString stringWithFormat:@"Fantastic text app - Letter Lure, check this link: %@",appLink]];
	[facebookComposer setCompletionHandler:handler];
	[self presentViewController:facebookComposer animated:YES completion:nil];
}

- (void)shareWithTwitter
{
	SLComposeViewController *twitterComposer = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeTwitter];
	SLComposeViewControllerCompletionHandler __block handler = ^(SLComposeViewControllerResult result){
		[twitterComposer dismissViewControllerAnimated:YES completion:nil];
	};
	[twitterComposer setInitialText:[NSString stringWithFormat:@"Fantastic text app - Letter Lure, check this link: %@",appLink]];
	[twitterComposer setCompletionHandler:handler];
	[self presentViewController:twitterComposer animated:YES completion:nil];
}


- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
	if (toInterfaceOrientation == UIInterfaceOrientationLandscapeLeft || toInterfaceOrientation == UIInterfaceOrientationLandscapeRight)
	{
		[self.version setText:@"Version 1.0 WOD STUDIOS@ 2014 ALL RIGHTS RESERVED"];
		[_version setNumberOfLines:1];
	}
	else
	{
		[self.version setText:@"Version 1.0 \n WOD STUDIOS@ 2014 ALL RIGHTS RESERVED"];
		[_version setNumberOfLines:2];
	}
}

static NSString *const iOS7AppStoreURLFormat = @"itms-apps://itunes.apple.com/WebObjects/MZStore.woa/wa/viewContentsUserReviews?type=Purple+Software&id=%@";
- (void)rate
{
	NSURL * url = [NSURL URLWithString:[NSString stringWithFormat:([[UIDevice currentDevice].systemVersion floatValue] >= 7.0f)? iOS7AppStoreURLFormat:iOS7AppStoreURLFormat, @(appStoreID)]];
	
	[[UIApplication sharedApplication] openURL:url];
}

- (void)support
{
//	MFMailComposeViewController * email = [MFMailComposeViewController new];
//	[email setMailComposeDelegate:self];
//	[email setSubject:@"Letter Lure"];
//	[email setToRecipients:@[@"letterlure@gmail.com"]];
//	[self presentViewController:email animated:YES completion:nil];
	// Set this up once when your application launches
	UVConfig *config = [UVConfig configWithSite:@"letterlure.uservoice.com"];
	config.forumId = 251895;
	// [config identifyUserWithEmail:@"email@example.com" name:@"User Name", guid:@"USER_ID");
	[UserVoice initialize:config];
	
	// Call this wherever you want to launch UserVoice
	[UserVoice presentUserVoiceInterfaceForParentViewController:self];
}

//- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
//{
//	[self dismissViewControllerAnimated:YES completion:nil];
//}

- (void)done
{
	[self dismissViewControllerAnimated:YES completion:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
