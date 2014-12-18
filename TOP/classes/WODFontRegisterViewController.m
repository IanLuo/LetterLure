//
//  WODFontRigisterViewController.m
//  TOP
//
//  Created by ianluo on 14-2-8.
//  Copyright (c) 2014年 WOD. All rights reserved.
//

#import "WODFontRegisterViewController.h"
#import "WODFontManager.h"
#import "WODIAPCenter.h"
#import "MBProgressHUD.h"
#import "WODButton.h"
#import "WODFontCreditViewerViewController.h"

#define segmentHeight 34
#define purchaseButtonsHeight 44
#define puchaseButtonsViewTag 10

@interface WODFontRegisterViewController ()<UIAlertViewDelegate,UITableViewDataSource,UITableViewDelegate>

@property (nonatomic, strong)NSArray * allFontFamilies;
@property (nonatomic, strong)NSMutableArray * unregisterdFontFamilies;
@property (nonatomic, strong)UISegmentedControl * segmented;
@property (nonatomic, strong)WODFontManager * fontManager;
@property (nonatomic, strong)WODIAPCenter * iapCenter;
@property (nonatomic, strong)UITableView * tableView;

@property (nonatomic, strong)MBProgressHUD *hud;

@end

@implementation WODFontRegisterViewController

- (UITableView *)tableView
{
	if (!_tableView)
	{
		_tableView = [[UITableView alloc] initWithFrame:CGRectMake(10, self.segmented.bounds.size.height + 4, self.view.bounds.size.width-20, self.view.bounds.size.height - segmentHeight -4) style:UITableViewStylePlain];
		_tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
		[_tableView setDataSource:self];
		[_tableView setDelegate:self];
		[_tableView setBackgroundColor:color_black];
		[_tableView setSeparatorColor:color_white];
	}
	return _tableView;
}

- (NSMutableArray *)unregisterdFontFamilies
{
	if(!_unregisterdFontFamilies)
	{
		_unregisterdFontFamilies = [NSMutableArray arrayWithArray:[[NSUserDefaults standardUserDefaults]objectForKey:KEY_UNREGISTERED_FONTS]];
	}
	return _unregisterdFontFamilies;
}

- (WODIAPCenter *)iapCenter
{
	if (!_iapCenter)
	{
		_iapCenter = [WODIAPCenter sharedSingleton];
	}
	return _iapCenter;
}

- (WODFontManager *)fontManager
{
	if (!_fontManager)
	{
		_fontManager = [WODFontManager new];
	}
	return _fontManager;
}

- (UISegmentedControl *)segmented
{
	if (!_segmented)
	{
		_segmented = [[UISegmentedControl alloc]initWithFrame:CGRectMake(10, 2, self.view.bounds.size.width - 20, segmentHeight)];
		_segmented.autoresizingMask = UIViewAutoresizingFlexibleWidth;
		[_segmented insertSegmentWithTitle:NSLocalizedString(@"FONTS_ALL", nil) atIndex:0 animated:NO];
		[_segmented insertSegmentWithTitle:NSLocalizedString(@"FONTS_EXTRA", nil) atIndex:1 animated:NO];
		[_segmented insertSegmentWithTitle:NSLocalizedString(@"FONTS_CUSTOM", nil) atIndex:2 animated:NO];
	
////		_segmented.selectedFont = [UIFont boldFlatFontOfSize:16];
//		_segmented.selectedFontColor = WODConstants.COLOR_TEXT_TITLE;
////		_segmented.deselectedFont = [UIFont flatFontOfSize:16];
//		_segmented.deselectedFontColor = WODConstants.COLOR_TEXT_TITLE;
//		_segmented.selectedColor = WODConstants.COLOR_CONTROLLER;
//		_segmented.deselectedColor = WODConstants.COLOR_CONTROLLER_DISABLED;
//		_segmented.dividerColor = WODConstants.COLOR_LINE_COLOR;
//		_segmented.cornerRadius = 5.0;
	
		[_segmented addTarget:self action:@selector(fontSourceChanged:) forControlEvents:UIControlEventValueChanged];
	}
	return _segmented;
}

- (void)showPurchaseButton
{
	UIView * view = [[UIView alloc]initWithFrame:CGRectMake(0, self.segmented.bounds.size.height, self.view.bounds.size.width, purchaseButtonsHeight)];
	view.tag = puchaseButtonsViewTag;
	view.alpha = 0.0;
	view.backgroundColor = color_black;
	view.autoresizingMask = UIViewAutoresizingFlexibleWidth;
	[self.view addSubview:view];
	
	WODButton * restore = [[WODButton alloc] initWithFrame:CGRectMake(10, 5, (self.view.bounds.size.width - 30)/2, 34)];
	[restore setTitle:NSLocalizedString(@"Restore", nil) forState:UIControlStateNormal];
	[restore setStyle:WODButtonStyleRoundCorner];
	restore.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleRightMargin;
	[restore addTarget:self action:@selector(restore) forControlEvents:UIControlEventTouchUpInside];
	[view addSubview:restore];
	
	WODButton * purchase = [[WODButton alloc] initWithFrame:CGRectMake(restore.bounds.size.width + 20, 5, (self.view.bounds.size.width - 30)/2, 34)];
	[purchase setTitle:NSLocalizedString(@"PURCHASE", nil) forState:UIControlStateNormal];
	[purchase setStyle:WODButtonStyleRoundCorner];
	purchase.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleLeftMargin;
	[purchase addTarget:self action:@selector(purchase) forControlEvents:UIControlEventTouchUpInside];
	[view addSubview:purchase];
	
	[UIView animateWithDuration:0.3 animations:^{
		self.tableView.frame = CGRectMake(10, self.segmented.bounds.size.height + view.bounds.size.height + 4, self.tableView.bounds.size.width, self.view.bounds.size.height - segmentHeight - 4 - purchaseButtonsHeight);
		view.alpha = 1.0;
	}];
}

- (void)hidePurchaseButton
{
	UIView * view = [self.view viewWithTag:puchaseButtonsViewTag];
	if (view)
	{
		[view removeFromSuperview];
		[UIView animateWithDuration:0.3 animations:^{
			self.tableView.frame = CGRectMake(10, self.segmented.bounds.size.height + 4, self.tableView.bounds.size.width, self.view.bounds.size.height - segmentHeight - 4);
			}];
	}
}

- (void)fontSourceChanged:(UISegmentedControl *)seg
{
	NSInteger selectedIndex = seg.selectedSegmentIndex;
	
	if (selectedIndex == 1)
	{
		if (![self.iapCenter checkIsPackageReady:iapExtraFonts])
		{
			[self.fontManager loadExtraFonts];
			[self showPurchaseButton];
		}
	}
	else
	{
		if (![self.iapCenter checkIsPackageReady:iapExtraFonts])
		{
			[self.fontManager unloadExtraFonts];
			[self hidePurchaseButton];
		}
	}
	
	switch (selectedIndex)
	{
		case 0:
			self.allFontFamilies = [[UIFont familyNames]sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
			break;
		case 1:
			self.allFontFamilies = [[self.fontManager extraFontFamilies]sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
			break;
		case 2:
			self.allFontFamilies = [[self.fontManager customFontFamilies]sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
			break;
	}
	
	[self.tableView reloadData];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	
	self.view.backgroundColor = color_black;
	
	[self setEdgesForExtendedLayout:UIRectEdgeNone];
	
	[self setTitle:NSLocalizedString(@"VC_TITLE_MANAGE_FONT", nil)];
	
	[self.tableView registerClass:[WODFontRegisterTableCell class] forCellReuseIdentifier:@"fontFamilyCell"];
	
	[self.segmented setSelectedSegmentIndex:0];
	[self fontSourceChanged:self.segmented];
	
	[self.view addSubview:self.segmented];
	[self.view addSubview:self.tableView];
	
	UIBarButtonItem * done = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(close)];
	
	[self.navigationItem setRightBarButtonItem:done];
    
    _hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    self.hud.mode = MBProgressHUDModeAnnularDeterminate;
}

- (void)close
{
	[self dismissViewControllerAnimated:YES completion:nil];
}

- (void)viewDidDisappear:(BOOL)animated
{
	[super viewDidDisappear:animated];
	[self saveUnregisteredFont];
}

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	return self.allFontFamilies.count;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
	
	if (self.segmented.selectedSegmentIndex == 1)
	{
		WODFontCreditViewerViewController * creditInfo = [WODFontCreditViewerViewController new];
		[creditInfo setFontName:self.allFontFamilies[indexPath.row]];
		
		[self.navigationController pushViewController:creditInfo animated:YES];
	}
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	__block WODFontRegisterTableCell * cell = [tableView dequeueReusableCellWithIdentifier:@"fontFamilyCell"];
	
	NSString * fontFamilyName = self.allFontFamilies[indexPath.row];
	[cell.textLabel setText:fontFamilyName];
	[cell.textLabel setFont:[UIFont fontWithName:fontFamilyName size:20]];
	[cell.textLabel setTextColor:color_white];
	
	cell.selectionStyle = self.segmented.selectedSegmentIndex == 1 ? UITableViewCellSelectionStyleGray : UITableViewCellSelectionStyleNone;
	
	if (self.segmented.selectedSegmentIndex == 1)
	{
		[cell setCellStyle:CellStyleCredit];
	}
	else if(self.segmented.selectedSegmentIndex == 2)
	{
		[cell setCellStyle:CellStyleNone];
	}
	else
	{
		[cell setCellStyle:CellStyleSwitch];
		[cell.isRigesterd setOn:![self.unregisterdFontFamilies containsObject:fontFamilyName]];
		
		__weak typeof(self) wself = self;
		[cell setSwitchBlock:^(bool isOn){
			if (!isOn)
			{
				[wself.unregisterdFontFamilies addObject:fontFamilyName];
			}
			else
			{
				if ([wself.unregisterdFontFamilies containsObject:fontFamilyName])
					[wself.unregisterdFontFamilies removeObject:fontFamilyName];
			}
		}];
	}
	
	return cell;
}

- (void)purchase
{
	UIAlertView * alertView = [[UIAlertView alloc]initWithTitle:NSLocalizedString(@"PURCHASE_EXTRA_FONTS", nil) message:NSLocalizedString(@"PURCHASE_EXTRA_FONTS_MSG", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"CANCEL", nil) otherButtonTitles:NSLocalizedString(@"OK", nil), nil];
//	alertView.titleLabel.textColor = [UIColor cloudsColor];
//	alertView.titleLabel.font = [UIFont boldFlatFontOfSize:16];
//	alertView.messageLabel.textColor = [UIColor cloudsColor];
//	alertView.messageLabel.font = [UIFont flatFontOfSize:14];
//	alertView.backgroundOverlay.backgroundColor = [[UIColor cloudsColor] colorWithAlphaComponent:0.8];
//	alertView.alertContainer.backgroundColor = WODConstants.COLOR_DIALOG_BACKGROUND;
//	alertView.defaultButtonColor = [UIColor cloudsColor];
//	alertView.defaultButtonShadowColor = [UIColor asbestosColor];
//	alertView.defaultButtonFont = [UIFont boldFlatFontOfSize:16];
//	alertView.defaultButtonTitleColor = [UIColor asbestosColor];
	[alertView show];
}

- (void)restore
{
	[self.iapCenter restorePaymentsComplete:^(BOOL status) {
	
		if ([self.iapCenter checkIsPackageReady:iapExtraFonts])
		{
			[self hidePurchaseButton];
		}
        
		self.hud.labelText = @"Restore Complete";
        [self.hud show:YES];
		
		[NSTimer scheduledTimerWithTimeInterval:2.0 target:self selector:@selector(dismissHUD) userInfo:nil repeats:NO];
	}];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
	if (buttonIndex == 1)
	{
		[self.iapCenter purchasePackage:iapExtraFonts complete:^(NSString *completeMessage) {
		
            [self.hud hide:YES];
			
			[NSTimer scheduledTimerWithTimeInterval:2.0 target:self selector:@selector(dismissHUD) userInfo:nil repeats:NO];
			
			[self.tableView reloadData];
			
			[self hidePurchaseButton];
		}];
	}
}

- (void)dismissHUD
{
	[self.hud hide:YES];
}

- (void)saveUnregisteredFont
{
	[[NSUserDefaults standardUserDefaults]setObject:self.unregisterdFontFamilies forKey:KEY_UNREGISTERED_FONTS];
	[[NSUserDefaults standardUserDefaults]synchronize];
}

@end

@implementation WODFontRegisterTableCell
{
	void (^switchAction)(bool isOn);
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
	self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
	if (self)
	{
		[self setCellStyle:CellStyleSwitch];
		
//		[self configureFlatCellWithColor:WODConstants.COLOR_CONTROLLER selectedColor:[UIColor cloudsColor] roundingCorners:UIRectCornerAllCorners];
		
//		self.cornerRadius = 5.0f;
//		self.separatorHeight = 2.0f;
		self.backgroundColor = color_black;
	}
	return self;
}

- (void)setCellStyle:(CellStyle)style
{
	switch (style) {
		case CellStyleSwitch:
		{
			if (!self.accessoryView)
			{
				_isRigesterd = [UISwitch new];
//				_isRigesterd.bounds = CGRectMake(0, 0, 60, 30);
//				_isRigesterd.onColor = [UIColor cloudsColor];
//				_isRigesterd.offColor = WODConstants.COLOR_CONTROLLER_SHADOW;
//				_isRigesterd.onBackgroundColor = [UIColor silverColor];
//				_isRigesterd.offBackgroundColor = WODConstants.COLOR_CONTROLLER;
//				_isRigesterd.offLabel.font = [UIFont boldFlatFontOfSize:14];
//				_isRigesterd.onLabel.font = [UIFont boldFlatFontOfSize:14];
				
				[self.isRigesterd addTarget:self action:@selector(switchChanged:) forControlEvents:UIControlEventValueChanged];
			}

			self.accessoryView = self.isRigesterd;
			
			break;
		}
		case CellStyleCredit:
			self.accessoryView = nil;
			self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
			break;
		case CellStyleNone:
			self.accessoryView = nil;
			self.accessoryType = UITableViewCellAccessoryNone;
			break;
	}
}

- (void)switchChanged:(UISwitch *)s;
{
	BOOL value = [s isOn];
	
	if (switchAction)
		switchAction(value);
}

- (void)setSwitchBlock:(void(^)(bool isOn))action
{
	switchAction = action;
}

@end
