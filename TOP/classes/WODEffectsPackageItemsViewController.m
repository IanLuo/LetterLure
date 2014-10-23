//
//  WODEffectsPackageItemsViewController.m
//  TOP
//
//  Created by ianluo on 14-1-20.
//  Copyright (c) 2014年 WOD. All rights reserved.
//

#import "WODEffectsPackageItemsViewController.h"
#import "WODEffectPackageManager.h"
#import "WODSimpleScrollItemPicker.h"
#import "WODEffectPackageManager.h"
#import "WODTextView.h"
#import "WODEffect.h"
#import "WODIAPCenter.h"
#import "SVProgressHUD.h"

#define FontSize UIUserInterfaceIdiomPad == UI_USER_INTERFACE_IDIOM() ? 100 : 50

@interface WODEffectsPackageItemsViewController ()<UICollectionViewDataSource,UICollectionViewDelegate,FUIAlertViewDelegate>

@property (nonatomic, strong) NSArray * packageItems;
@property (nonatomic, strong) WODEffectPackageManager * effectPackageManager;
@property (nonatomic, strong) UIImageView * sampleTextImageView;
@property (nonatomic, strong) WODEffectPackageManager * effectsManager;
@property (nonatomic, strong) WODTextView * sampleTextView;
@property (nonatomic, strong) WODIAPCenter * iapCenter;
@property (nonatomic, strong) NSArray * allFontFamilies;
@property (nonatomic, strong) UICollectionView * collectionView;

@end

@implementation WODEffectsPackageItemsViewController

- (WODIAPCenter *)iapCenter
{
	if (!_iapCenter)
	{
		_iapCenter = [WODIAPCenter sharedSingleton];
	}
	return _iapCenter;
}

- (NSArray *)allFontFamilies
{
	if (!_allFontFamilies)
	{
		_allFontFamilies = [UIFont familyNames];
	}
	return _allFontFamilies;
}

- (WODEffectPackageManager *)effectPackageManager
{
	if(!_effectPackageManager)
	{
		_effectPackageManager = [WODEffectPackageManager new];
	}
	return _effectPackageManager;
}

- (WODEffectPackageManager *)effectsManager
{
	if (!_effectsManager)
	{
		_effectsManager = [WODEffectPackageManager new];
	}
	return _effectsManager;
}

- (WODTextView *)sampleTextView
{
	if (!_sampleTextView)
	{
		_sampleTextView = [WODTextView new];
		UIFont * font = [UIFont fontWithName:@"ArialHebrew-Bold" size:FontSize];
		[_sampleTextView setText:[self sampleAttributedStringForFont:font]];
	}
	return _sampleTextView;
}

- (id)init
{
    self = [super init];
    if (self)
	{
		_sampleTextImageView = [[UIImageView alloc] init];
		[self.sampleTextImageView setContentMode:UIViewContentModeCenter];
		[self.sampleTextImageView setCenter:self.view.center];
		[self.sampleTextImageView setTranslatesAutoresizingMaskIntoConstraints:NO];
		[self.view addSubview:self.sampleTextImageView];
		
		UICollectionViewFlowLayout * flowLayout = [[UICollectionViewFlowLayout alloc]init];
		[flowLayout setScrollDirection:UICollectionViewScrollDirectionHorizontal];
		[flowLayout setMinimumInteritemSpacing:0.0];
		[flowLayout setMinimumLineSpacing:0.0];
		_collectionView = [[UICollectionView alloc]initWithFrame:CGRectZero collectionViewLayout:flowLayout];
		[self.collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"fontCell"];
		[self.collectionView setDelegate:self];
		[self.collectionView setDataSource:self];
		[self.collectionView setTranslatesAutoresizingMaskIntoConstraints:NO];
		[self.collectionView setAlpha:0.0];
		[self.collectionView setBackgroundColor:WODConstants.COLOR_VIEW_BACKGROUND];
		[self.view addSubview:self.collectionView];
    }
    return self;
}

- (void)viewWillLayoutSubviews
{
	[self.view removeConstraints:self.view.constraints];
	
	[self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|[imageView]|" options:0 metrics:nil views:@{@"collectionView":self.collectionView,@"imageView":self.sampleTextImageView}]];
	[self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|[collectionView]|" options:0 metrics:nil views:@{@"collectionView":self.collectionView,@"imageView":self.sampleTextImageView}]];
	[self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[imageView][collectionView(fontsBarHeight)]-toolbarHeight-|" options:0 metrics:@{@"toolbarHeight":@(76),@"fontsBarHeight":@([WODConstants navigationbarHeight])} views:@{@"collectionView":self.collectionView,@"imageView":self.sampleTextImageView}]];
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
	NSMutableArray * visibaleIndexPaths = [NSMutableArray array];
	for(UICollectionViewCell * cell in [self.collectionView visibleCells])
	{
		NSIndexPath * indexPath = [self.collectionView indexPathForCell:cell];
		[visibaleIndexPaths addObject:indexPath];
	}
	
	[self.collectionView reloadItemsAtIndexPaths:[NSArray arrayWithArray:visibaleIndexPaths]];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	[self setEdgesForExtendedLayout:UIRectEdgeNone];
	[self setAutomaticallyAdjustsScrollViewInsets:NO];
	// Do any additional setup after loading the view.
	
	self.view.backgroundColor = WODConstants.COLOR_VIEW_BACKGROUND_DARK;
}

- (void)payPackage:(UIBarButtonItem *)button
{
	FUIAlertView * alertView = [[FUIAlertView alloc]initWithTitle:NSLocalizedString(@"PURCHASE", nil) message:[NSLocalizedString(@"COMFIRM_PURCHASEING", nil) stringByAppendingFormat:@"%@ (%@)",NSLocalizedString(self.packageName, nil),button.title] delegate:self cancelButtonTitle:NSLocalizedString(@"CANCEL", nil) otherButtonTitles:NSLocalizedString(@"OK", nil), nil];
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

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
	if (buttonIndex == 1)
	{
		[self.iapCenter purchasePackage:self.packageName complete:^(NSString *completeMessage) {
			if (completeMessage)
			{
				[SVProgressHUD showSuccessWithStatus:completeMessage];
				
				[NSTimer scheduledTimerWithTimeInterval:2.0 target:self selector:@selector(dismissHUD) userInfo:nil repeats:NO];
				
				UIBarButtonItem * apply = [[UIBarButtonItem alloc]initWithTitle:NSLocalizedString(@"NAVIGATIONBAR_ITEM_USE_IT", nil) style:UIBarButtonItemStylePlain target:self action:@selector(applyPackage)];
				self.navigationItem.rightBarButtonItem = apply;
			}
		}];
	}
}

- (void)dismissHUD
{
	[SVProgressHUD dismiss];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidAppear:(BOOL)animated
{
	[super viewDidAppear:animated];
	
	if ( self.packageItems.count > 0)
	{
		WODSimpleScrollItemPicker * effectsPicker = [WODSimpleScrollItemPicker new];
		effectsPicker.distansFromBottomPortrait = 0;
		effectsPicker.distansFromBottomLandscape = 0;
		effectsPicker.hideBorder = YES;
		effectsPicker.displayStyle = DisplayStylePermenante;
		
		for (NSString * path in self.packageItems)
		{
			UIImage * image = [self.effectsManager iconForEffect:path];
			if (image)
			{
				UIImageView * effecIcon = [[UIImageView alloc]initWithImage:[self.effectsManager iconForEffect:path]];
				[effecIcon setContentMode:UIViewContentModeCenter];
				[effectsPicker addItemWithView:effecIcon];
			}
			else
				[effectsPicker addItem:[path lastPathComponent]];
		}
		
		NSString * xmlFilePath = [self.packageItems[0]stringByAppendingString:@"/effect.xml"];
		[self showEffectedText:xmlFilePath];
		
		__weak typeof (self) wSelf = self;
		[effectsPicker showFrom:self.view withSelection:^(WODSimpleScrollItemPickerItem *selectedItem)
		 {
			 NSString * xmlFilePath = [wSelf.packageItems[selectedItem.index]stringByAppendingString:@"/effect.xml"];
			 
			 [wSelf showEffectedText:xmlFilePath];
		 }];
		 
		[UIView animateWithDuration:0.3 animations:^{
			[self.collectionView setAlpha:1.0];
		} completion:^(BOOL finished) {
			[self.view bringSubviewToFront:self.collectionView];
		}];
	}
}

- (void)showEffectedText:(NSString *)xmlFilePath
{
	WODEffect * effect = [[WODEffect new] initWithXMLFilePath:xmlFilePath];
	__weak typeof(self) wself = self;
	
	if(self.sampleTextView.effectProvider != effect)
	{
		[effect prepare:^{
			[wself.sampleTextView setEffectProvider:effect];
			
			[wself.sampleTextView displayTextHideFeatures:NO complete:^(UIImage *image) {
				[wself applyEffectForSampleTextImage:image];
			}];
		}];
	}
}

- (void)setPackageName:(NSString *)packageName
{
	_packageName = packageName;
	
	self.title = NSLocalizedString(_packageName, nil);
	
	self.packageItems = [self.effectPackageManager effectsInPackage:self.packageName];
	
	if (![self.iapCenter checkIsPackageReady:self.packageName])
	{
		if([self.iapCenter.freePackages containsObject:self.packageName])
		{
			UIBarButtonItem * purchaase = [[UIBarButtonItem alloc]initWithTitle:NSLocalizedString(@"FREE", nil) style:UIBarButtonItemStylePlain target:self action:@selector(payPackage:)];
			self.navigationItem.rightBarButtonItem = purchaase;
		}
		else
		{
			UIBarButtonItem * purchaase = [[UIBarButtonItem alloc]initWithTitle:@"0.99$" style:UIBarButtonItemStylePlain target:self action:@selector(payPackage:)];
			self.navigationItem.rightBarButtonItem = purchaase;
		}
	}
	else
	{
		UIBarButtonItem * apply = [[UIBarButtonItem alloc]initWithTitle:NSLocalizedString(@"NAVIGATIONBAR_ITEM_USE_IT", nil) style:UIBarButtonItemStylePlain target:self action:@selector(applyPackage)];
		self.navigationItem.rightBarButtonItem = apply;
	}
}

- (void)applyPackage
{
	[[NSUserDefaults standardUserDefaults]setObject:self.packageName forKey:kCurrentSelectedEffectPackageName];
	[[NSUserDefaults standardUserDefaults]synchronize];

	if([self.packageViewController.delegate respondsToSelector:@selector(didFinishSelectEffectPackage:currentEffect:viewController:)])
	{
		[self.packageViewController.delegate didFinishSelectEffectPackage:self.packageName currentEffect:[(WODEffect *)self.sampleTextView.effectProvider effectXMLFilePath] viewController:self.packageViewController];
	}
}

#pragma mark - collection view -
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
	return self.allFontFamilies.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
	UICollectionViewCell * cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"fontCell" forIndexPath:indexPath];
	
	for (UIView * view in cell.contentView.subviews)
	{
		[view removeFromSuperview];
	}
	
	UILabel * label = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, [WODConstants navigationbarHeight], [WODConstants navigationbarHeight])];
	[label setTextColor:WODConstants.COLOR_TEXT_TITLE];
	[label setTextAlignment:NSTextAlignmentCenter];
	[label setBackgroundColor:WODConstants.COLOR_CONTROLLER];
	[cell.contentView addSubview:label];
	
	[label setText:@"Aa"];
	[label setFont:[UIFont fontWithName:self.allFontFamilies[indexPath.row] size:12]];
	
	return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
	UIFont * font = [UIFont fontWithName:self.allFontFamilies[indexPath.row] size:FontSize];
	
	[self.sampleTextView setText:[self sampleAttributedStringForFont:font]];
			
	__weak typeof(self) wself = self;
	[self.sampleTextView displayTextHideFeatures:NO complete:^(UIImage *image) {
		[wself applyEffectForSampleTextImage:image];
	}];
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
	return CGSizeMake([WODConstants navigationbarHeight], [WODConstants navigationbarHeight]);
}

#pragma mark - utils
- (NSAttributedString *)sampleAttributedStringForFont:(UIFont *)font
{
	NSMutableParagraphStyle * paragraphStyle = [[NSMutableParagraphStyle alloc] init];
	paragraphStyle.alignment = NSTextAlignmentCenter;
	
	NSDictionary * attributes = @{NSFontAttributeName:font, NSParagraphStyleAttributeName:paragraphStyle};
	NSAttributedString * sampleText = [[NSAttributedString alloc]initWithString:[self sampleTextString] attributes:attributes];
	
	UITextView * textView = [[UITextView alloc]initWithFrame:(CGRect){CGPointZero,[WODConstants currentSize]}];
 	[textView setAttributedText:sampleText];
	[textView sizeToFit];
	CGSize textViewSize = (CGSize){textView.bounds.size.width + ABS(textView.contentOffset.x), textView.bounds.size.height * 1.3 + ABS(textView.contentOffset.y)};//the line space seem too big but haven't found a way to reduce, so for now, just simply multypy by 1.3 to encreace the bounds' height
	
	self.sampleTextView.bounds = (CGRect){CGPointZero,textViewSize};
	[self.sampleTextView resetLayoutShapePath];
	
#ifdef DEBUGMODE
	NSLog(@"(%@,%i):new size :%@",[[NSString stringWithUTF8String:__FILE__]lastPathComponent],__LINE__,NSStringFromCGSize(textViewSize));
#endif
			
	return sampleText;
}

- (NSString *)sampleTextString
{
	UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
	if ((orientation == UIInterfaceOrientationLandscapeLeft || orientation == UIInterfaceOrientationLandscapeRight) && UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
	{
		return @"Sample Effect";
	}
	else
	{
		return @"Sample \n Effect";
	}
}

- (void)applyEffectForSampleTextImage:(UIImage *)image
{
	self.sampleTextImageView.image = image;
}

@end
