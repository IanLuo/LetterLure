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
#import "MBProgressHUD.h"

#import <BlocksKit/BlocksKit+UIKit.h>

//static float adViewHight = 200.0;
static float rowViewHight = 100.0;

@interface WODEffectsPackageViewController ()<UITableViewDelegate,UITableViewDataSource,UIScrollViewDelegate>

@property (nonatomic, strong) UITableView * tableView;

//TODO: used in updated versions
//@property (nonatomic, strong) UIScrollView * adView;
//@property (nonatomic, assign) CGFloat adViewOffsetY;

@property (nonatomic, strong) NSArray * packages;

@property (nonatomic, strong) WODEffectPackageManager * effectsManager;


@property (nonatomic, strong) WODIAPCenter * iapCenter;

@property (nonatomic, strong) MBProgressHUD * hud;

@end

#define tableCellID @"packageCell"

static int selectedPackageIdx;

@implementation WODEffectsPackageViewController

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
		self.tableView.separatorColor = color_black;
		[self.tableView setBackgroundColor:color_black];

		[self.view addSubview:self.tableView];
        
        _hud = [MBProgressHUD HUDForView:self.view];
        self.hud.mode = MBProgressHUDModeIndeterminate;
    }
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	
	self.view.backgroundColor = color_black;
	
	self.title = NSLocalizedString(@"VC_TITLE_CHOOSE_EFFECT_PACKAGE", nil);
	
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
			[self.hud setLabelText:iStr(@"Restore Complete")];
            [self.hud show:YES];
			
            [self performSelector:@selector(dismissHUD) withObject:nil afterDelay:2.0];
			
			[self.tableView reloadData];
		}
	}];
}

- (void)viewWillLayoutSubviews
{
    NSUInteger topOffset = HEIGHT_STATUS_AND_NAV_BAR;
    
    if (!isVertical())
    {
        topOffset = HEIGHT_STATUS_AND_NAV_BAR_LANDSCAPE;
    }
    
    NSDictionary * views = @{@"tableView":self.tableView};
    
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|-10-[tableView]-10-|" options:0 metrics:nil views:views]];
    
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-topOffset-[tableView]|" options:0 metrics:@{@"topOffset":@(topOffset + 10)} views:views]];
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
	
	NSString * packageName = self.packages[indexPath.row];
	NSString * selectedPackageName = [[NSUserDefaults standardUserDefaults]valueForKey:kCurrentSelectedEffectPackageName];
	[cell.textLabel setText:NSLocalizedString(packageName, nil)];
	[cell setSelectionStyle:UITableViewCellSelectionStyleGray];
	[cell setTintColor:color_white];
	[cell.textLabel setTextColor:color_white];
	[cell.textLabel setFont:[UIFont boldSystemFontOfSize:16]];
	[cell setBackgroundColor:color_black];
	
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

- (void)dismissHUD
{
	[self.hud hide:YES];
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
	
	UIAlertView * alertView = [[UIAlertView alloc]initWithTitle:NSLocalizedString(@"PURCHASE", nil) message:[NSLocalizedString(@"COMFIRM_PURCHASEING", nil) stringByAppendingFormat:@"%@ (%@)",NSLocalizedString(self.packages[selectedPackageIdx],nil),[button titleForState:UIControlStateNormal]] delegate:self cancelButtonTitle:NSLocalizedString(@"CANCEL", nil) otherButtonTitles:NSLocalizedString(@"OK", nil), nil];

    ws(wself);
    [alertView bk_addButtonWithTitle:iStr(@"OK") handler:^{
        
        ss(sself);
        [wself.iapCenter purchasePackage:self.packages[selectedPackageIdx] complete:^(NSString *completeMessage) {
            if (completeMessage)
            {
                [sself.hud setLabelText:completeMessage];
                [sself.hud show:YES];
                
                [NSTimer scheduledTimerWithTimeInterval:2.0 target:sself selector:@selector(dismissHUD) userInfo:nil repeats:NO];
                
                WODButton * button = [WODButton new];
                button.tag = selectedPackageIdx;
                [sself changeSelectedPackage:button];
                [sself.tableView reloadData];
            }
        }];
        
    }];
    
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

#pragma mark - getter

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

@end
