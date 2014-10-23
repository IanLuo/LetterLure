//
//  WODEffectsPackageViewController.m
//  TOP
//
//  Created by ianluo on 14-1-19.
//  Copyright (c) 2014年 WOD. All rights reserved.
//

#import "WODEffectsPackageViewController.h"
#import "WODEffectPackageManager.h"
#import "WODEffectsPackageItemsViewController.h"
#import "WODButton.h"
#import "WODIAPCenter.h"
#import "SVProgressHUD.h"

//static float adViewHight = 200.0;
static float rowViewHight = 100.0;

@interface WODEffectsPackageViewController ()<UITableViewDelegate,UITableViewDataSource,UIScrollViewDelegate,FUIAlertViewDelegate>

@property (nonatomic, strong) UITableView * tableView;

//TODO: used in updated versions
//@property (nonatomic, strong) UIScrollView * adView;
//@property (nonatomic, assign) CGFloat adViewOffsetY;

@property (nonatomic, strong) NSArray * packages;

@property (nonatomic, strong) WODEffectPackageManager * effectsManager;


@property (nonatomic, strong) WODIAPCenter * iapCenter;

@end

#define tableCellID @"packageCell"

@implementation WODEffectsPackageViewController

- (WODEffectPackageManager *)effectsManager
{
	if (!_effectsManager)
	{
		_effectsManager = [WODEffectPackageManager new];
	}
	return _effectsManager;
}

- (WODIAPCenter *)iapCenter
{
	if (!_iapCenter)
	{
		_iapCenter = [WODIAPCenter sharedSingleton];
	}
	return _iapCenter;
}

- (id)init
{
    self = [super init];
    if (self)
	{
        _tableView = [UITableView new];
		[self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:tableCellID];
		self.tableView.translatesAutoresizingMaskIntoConstraints = NO;
		self.tableView.delegate = self;
		self.tableView.dataSource = self;
		self.tableView.separatorColor = WODConstants.COLOR_VIEW_BACKGROUND;
		[self.tableView setBackgroundColor:WODConstants.COLOR_VIEW_BACKGROUND];

		//TODO: used in updated versions
//		_adView = [UIScrollView new];
//		self.adView.translatesAutoresizingMaskIntoConstraints = NO;
//		self.adView.delegate = self;
//		self.adView.backgroundColor = COLOR_NAV_BAR;
		
		[self.view addSubview:self.tableView];
//		[self.view addSubview:self.adView];TODO: used in updated versions
		
		NSDictionary * views = @{/*@"adView":self.adView,TODO: used in updated versions*/@"tableView":self.tableView};
		
//		[self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|[adView]|" options:0 metrics:nil views:views]];TODO: used in updated versions
		[self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|-10-[tableView]-10-|" options:0 metrics:nil views:views]];
		/*[self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[adView(adViewHight)]" options:0 metrics:@{@"adViewHight":@(adViewHight)} views:views]];TODO: used in updated versions*/
		[self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-10-[tableView]|" options:0 metrics:nil views:views]];

    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	
	self.view.backgroundColor = WODConstants.COLOR_VIEW_BACKGROUND;
	
	self.title = NSLocalizedString(@"VC_TITLE_CHOOSE_EFFECT_PACKAGE", nil);
	
	[self setEdgesForExtendedLayout:UIRectEdgeNone];
	self.automaticallyAdjustsScrollViewInsets = NO;
	
	self.packages = [self.effectsManager packageList];
	
	UIBarButtonItem * complete = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(complete)];
	self.navigationItem.rightBarButtonItem = complete;
	
	UIBarButtonItem * restorePurchasedEffects = [[UIBarButtonItem alloc]initWithTitle:NSLocalizedString(@"Restore", nil) style:UIBarButtonItemStylePlain target:self action:@selector(restore)];
	self.navigationItem.leftBarButtonItem = restorePurchasedEffects;

}

- (void)restore
{
	[self.iapCenter restorePaymentsComplete:^(BOOL status) {
		
		if (status)
		{
			[SVProgressHUD showSuccessWithStatus:NSLocalizedString(@"Restore Complete", nil)];
			
			[NSTimer scheduledTimerWithTimeInterval:2.0 target:self selector:@selector(dismissHUD) userInfo:nil repeats:NO];
			
			[self.tableView reloadData];
		}
	}];
}

- (void)viewDidLayoutSubviews
{
//	self.adView.frame = CGRectMake(0, self.adViewOffsetY, self.adView.frame.size.width, self.adView.frame.size.height);TODO: used in updated versions
}

- (void)complete
{
	if([self.delegate respondsToSelector:@selector(didFinishSelectEffectPackage:currentEffect:viewController:)])
	{
		[self.delegate didFinishSelectEffectPackage:[[NSUserDefaults standardUserDefaults]objectForKey:kCurrentSelectedEffectPackageName] currentEffect:nil viewController:self];
	}
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//TODO: used in updated versions
//- (void)scrollViewDidScroll:(UIScrollView *)scrollView
//{
//	if (scrollView.contentOffset.y > -self.tableView.contentInset.top && scrollView.contentOffset.y < 0)
//	{
//		self.adViewOffsetY = -(scrollView.contentOffset.y + self.tableView.contentInset.top);
//		self.adView.frame = CGRectMake(0, self.adViewOffsetY, self.adView.frame.size.width, self.adView.frame.size.height);
//	}
//}

#pragma mark - tableview delegate and datasource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	return self.packages.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	return rowViewHight;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:tableCellID forIndexPath:indexPath];
	[cell configureFlatCellWithColor:WODConstants.COLOR_CONTROLLER selectedColor:[UIColor cloudsColor] roundingCorners:UIRectCornerAllCorners];
	
	cell.cornerRadius = 5.0f; // optional
	cell.separatorHeight = 2.0f;
	
	NSString * packageName = self.packages[indexPath.row];
	NSString * selectedPackageName = [[NSUserDefaults standardUserDefaults]valueForKey:kCurrentSelectedEffectPackageName];
	[cell.textLabel setText:NSLocalizedString(packageName, nil)];
	[cell setSelectionStyle:UITableViewCellSelectionStyleGray];
	[cell setTintColor:WODConstants.COLOR_TEXT_TITLE];
	[cell.textLabel setTextColor:WODConstants.COLOR_TEXT_TITLE];
	[cell.textLabel setFont:[UIFont boldFlatFontOfSize:16]];
	[cell setBackgroundColor:WODConstants.COLOR_VIEW_BACKGROUND];
	
	UIImage * icon = [self.effectsManager iconForEffect:([self.effectsManager effectsInPackage:packageName].count > 0 ? [self.effectsManager effectsInPackage:packageName][0] : nil)];
	[cell.imageView setImage:icon];
	
	if ([packageName isEqualToString:selectedPackageName])
	{
		UIImageView * checkMark = [[UIImageView alloc]initWithImage:[[UIImage imageNamed:@"check_mark.png"]imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate]];
		[cell setAccessoryView:checkMark];
		checkMark.bounds = CGRectMake(0, 0, 40, 40);
		[checkMark setContentMode:UIViewContentModeCenter];
	}
	else
	{
		WODButton * accseccoryButton = [WODButton new];
		[accseccoryButton setBounds:CGRectMake(0, 0, 40, 40)];
		if ([self.iapCenter checkIsPackageReady:packageName])
		{
			[accseccoryButton addTarget:self action:@selector(changeSelectedPackage:) forControlEvents:UIControlEventTouchUpInside];
			[accseccoryButton setImage:[[UIImage imageNamed:@"circle"]imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
		}
		else if([self.iapCenter.freePackages containsObject:packageName])
		{
			[accseccoryButton setTitle:NSLocalizedString(@"FREE", nil) forState:UIControlStateNormal];
			[accseccoryButton sizeToFit];
			accseccoryButton.style = WODButtonStyleNormal;
			[accseccoryButton showBorder:NO];
			[accseccoryButton addTarget:self action:@selector(purchasePacke:) forControlEvents:UIControlEventTouchUpInside];
		}
		else
		{
			accseccoryButton.style = WODButtonStyleNormal;
			[accseccoryButton showBorder:NO];
			[accseccoryButton setTitle:NSLocalizedString(@"0.99$", nil) forState:UIControlStateNormal];
			[accseccoryButton addTarget:self action:@selector(purchasePacke:) forControlEvents:UIControlEventTouchUpInside];
			[accseccoryButton setImage:[[UIImage imageNamed:@"shopping_cart"]imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
		}
		accseccoryButton.tag = indexPath.row;
		[cell setAccessoryView:accseccoryButton];
	}
	
	return cell;
}

static int selectedPackageIdx;

- (void)alertView:(FUIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
	if (buttonIndex == 1)
	{
		[self.iapCenter purchasePackage:self.packages[selectedPackageIdx] complete:^(NSString *completeMessage) {
			if (completeMessage)
			{
				[SVProgressHUD showSuccessWithStatus:completeMessage];
				
				[NSTimer scheduledTimerWithTimeInterval:2.0 target:self selector:@selector(dismissHUD) userInfo:nil repeats:NO];
				
				WODButton * button = [WODButton new];
				button.tag = selectedPackageIdx;
				[self changeSelectedPackage:button];
				[self.tableView reloadData];
			}
		}];
	}
}

- (void)dismissHUD
{
	[SVProgressHUD dismiss];
}

- (void)changeSelectedPackage:(WODButton *)button
{
	[[NSUserDefaults standardUserDefaults]setValue:self.packages[button.tag] forKey:kCurrentSelectedEffectPackageName];
	
	NSMutableArray * array = [NSMutableArray array];
	for (UITableViewCell * cell in self.tableView.visibleCells)
	{
		[array addObject:[self.tableView indexPathForCell:cell]];
	}
	[self.tableView reloadRowsAtIndexPaths:array withRowAnimation:UITableViewRowAnimationNone];
}

- (void)purchasePacke:(WODButton *)button
{
	selectedPackageIdx = (int)button.tag;
	
	FUIAlertView * alertView = [[FUIAlertView alloc]initWithTitle:NSLocalizedString(@"PURCHASE", nil) message:[NSLocalizedString(@"COMFIRM_PURCHASEING", nil) stringByAppendingFormat:@"%@ (%@)",NSLocalizedString(self.packages[selectedPackageIdx],nil),[button titleForState:UIControlStateNormal]] delegate:self cancelButtonTitle:NSLocalizedString(@"CANCEL", nil) otherButtonTitles:NSLocalizedString(@"OK", nil), nil];
	alertView.titleLabel.textColor = [UIColor cloudsColor];
	alertView.titleLabel.font = [UIFont boldFlatFontOfSize:16];
	alertView.messageLabel.textColor = [UIColor cloudsColor];
	alertView.messageLabel.font = [UIFont flatFontOfSize:14];
	alertView.backgroundOverlay.backgroundColor = [[UIColor cloudsColor] colorWithAlphaComponent:0.8];
	alertView.alertContainer.backgroundColor = WODConstants.COLOR_DIALOG_BACKGROUND;
	alertView.defaultButtonColor = [UIColor cloudsColor];
	alertView.defaultButtonShadowColor = [UIColor asbestosColor];
	alertView.defaultButtonFont = [UIFont boldFlatFontOfSize:16];
	alertView.defaultButtonTitleColor = [UIColor asbestosColor];
	[alertView show];

}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	WODEffectsPackageItemsViewController * itemsViewController = [WODEffectsPackageItemsViewController new];
	itemsViewController.packageName = self.packages[indexPath.row];
	itemsViewController.packageViewController = self;
	
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
	
	[self.navigationController pushViewController:itemsViewController animated:YES];
}

@end
