//
//  WODEffectsPackageItemsViewController.m
//  TOP
//
//  Created by ianluo on 14-1-20.
//  Copyright (c) 2014年 WOD. All rights reserved.
//

#import "WODEffectsPackageItemsViewController.h"
#import "WODSimpleScrollItemPicker.h"
#import "WODEffectPackageManager.h"
#import "WODTextView.h"
#import "WODEffect.h"
#import "WODIAPCenter.h"
#import "MBProgressHUD.h"

#define FontSize UIUserInterfaceIdiomPad == UI_USER_INTERFACE_IDIOM() ? 100 : 50

@interface WODEffectsPackageItemsViewController ()<UICollectionViewDataSource,UICollectionViewDelegate,UIAlertViewDelegate>

@property (nonatomic, strong) NSArray * packageItems;
@property (nonatomic, strong) UIImageView * sampleTextImageView;
@property (nonatomic, strong) WODEffectPackageManager * effectsManager;
@property (nonatomic, strong) WODTextView * sampleTextView;
@property (nonatomic, strong) WODIAPCenter * iapCenter;
@property (nonatomic, strong) NSArray * allFontFamilies;
@property (nonatomic, strong) UICollectionView * fontCollectionView;
@property (nonatomic, strong) WODSimpleScrollItemPicker * effectsPicker;
@property (nonatomic, strong) MBProgressHUD * hud;

@end

@implementation WODEffectsPackageItemsViewController

- (id)init
{
    self = [super init];
    if (self)
	{
        _hud = [MBProgressHUD HUDForView:self.view];
    }
    
    return self;
}

- (void)viewDidLayoutSubviews
{
    WODDebug(@"effects picker items: %@",self.effectsPicker.itemsCollectionView);
}

- (void)makeConstrains
{
    ws(wself);
    [self.sampleTextImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.edges.equalTo(self.view).insets(UIEdgeInsetsMake(10, 10, 80, 10));
        
    }];
    
    [self.fontCollectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.width.equalTo(wself.view.mas_width);
        make.height.mas_equalTo(40);
        make.bottom.equalTo(wself.view.mas_bottom).offset(-40);
        
    }];
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
	NSMutableArray * visibaleIndexPaths = [NSMutableArray array];
	for(UICollectionViewCell * cell in [self.fontCollectionView visibleCells])
	{
		NSIndexPath * indexPath = [self.fontCollectionView indexPathForCell:cell];
		[visibaleIndexPaths addObject:indexPath];
	}
	
	[self.fontCollectionView reloadItemsAtIndexPaths:[NSArray arrayWithArray:visibaleIndexPaths]];
}

- (void)viewDidLoad
{
    [super viewDidLoad];

	[self setAutomaticallyAdjustsScrollViewInsets:NO];
    
    [self setEdgesForExtendedLayout:UIRectEdgeAll];

    self.view.backgroundColor = color_black;
    
    [self.view addSubview:self.sampleTextImageView];
    
    [self.view addSubview:self.fontCollectionView];
    
    [self makeConstrains];
    
    ws(wself);
 
    [self.effectsPicker showFrom:self.view withSelection:^(WODSimpleScrollItemPickerItem *selectedItem)
     {
         NSString * xmlFilePath = [wself.packageItems[selectedItem.index]stringByAppendingString:@"/effect.xml"];
         
         [wself showEffectedText:xmlFilePath];
         
     }];
    
}

- (void)payPackage:(UIBarButtonItem *)button
{
	UIAlertView * alertView = [[UIAlertView alloc]initWithTitle:NSLocalizedString(@"PURCHASE", nil) message:[NSLocalizedString(@"COMFIRM_PURCHASEING", nil) stringByAppendingFormat:@"%@ (%@)",NSLocalizedString(self.packageName, nil),button.title] delegate:self cancelButtonTitle:NSLocalizedString(@"CANCEL", nil) otherButtonTitles:NSLocalizedString(@"OK", nil), nil];

    [alertView show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
	if (buttonIndex == 1)
	{
        ws(wself);
		[self.iapCenter purchasePackage:self.packageName complete:^(NSString *completeMessage) {
			if (completeMessage)
			{
				[wself.hud setLabelText:completeMessage];
                [wself.hud show:YES];
				
                [wself performSelector:@selector(dismissHUD) withObject:nil afterDelay:2.0];
				
				UIBarButtonItem * apply = [[UIBarButtonItem alloc]initWithTitle:NSLocalizedString(@"NAVIGATIONBAR_ITEM_USE_IT", nil) style:UIBarButtonItemStylePlain target:wself action:@selector(applyPackage)];
				wself.navigationItem.rightBarButtonItem = apply;
			}
		}];
	}
}

- (void)dismissHUD
{
    [self.hud hide:YES];
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
		for (NSString * path in self.packageItems)
		{
			UIImage * image = [self.effectsManager iconForEffect:path];
			if (image)
			{
				UIImageView * effecIcon = [[UIImageView alloc]initWithImage:[self.effectsManager iconForEffect:path]];
				[effecIcon setContentMode:UIViewContentModeCenter];
				[self.effectsPicker addItemWithView:effecIcon];
			}
			else
				[self.effectsPicker addItem:[path lastPathComponent]];
		}
		
		NSString * xmlFilePath = [self.packageItems[0]stringByAppendingString:@"/effect.xml"];
		[self showEffectedText:xmlFilePath];
		
        ws(wself);
		 
		[UIView animateWithDuration:0.3 animations:^{
            
			[wself.fontCollectionView setAlpha:1.0];
            
		} completion:^(BOOL finished) {
            
			[wself.view bringSubviewToFront:self.fontCollectionView];
            
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
	
	self.packageItems = [self.effectsManager effectsInPackage:self.packageName];
	
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
	[label setTextColor:color_white];
	[label setTextAlignment:NSTextAlignmentCenter];
	[label setBackgroundColor:color_black];
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
	return CGSizeMake(30, 30);
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
	if (!isVertical())
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

#pragma mark - getter 

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

- (UIImageView *)sampleTextImageView
{
    if (!_sampleTextImageView)
    {
        _sampleTextImageView = [[UIImageView alloc] init];
        [_sampleTextImageView setContentMode:UIViewContentModeCenter];
        [_sampleTextImageView setCenter:self.view.center];
        [_sampleTextImageView setTranslatesAutoresizingMaskIntoConstraints:NO];
    }
    
    return _sampleTextImageView;
}

- (UICollectionView *)fontCollectionView
{
    if (!_fontCollectionView)
    {
        UICollectionViewFlowLayout * flowLayout = [[UICollectionViewFlowLayout alloc]init];
        [flowLayout setScrollDirection:UICollectionViewScrollDirectionHorizontal];
        [flowLayout setMinimumInteritemSpacing:0.0];
        [flowLayout setMinimumLineSpacing:0.0];
        
        _fontCollectionView = [[UICollectionView alloc]initWithFrame:CGRectZero collectionViewLayout:flowLayout];
        [_fontCollectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"fontCell"];
        [_fontCollectionView setDelegate:self];
        [_fontCollectionView setDataSource:self];
        [_fontCollectionView setTranslatesAutoresizingMaskIntoConstraints:NO];
        [_fontCollectionView setAlpha:0.0];
        [_fontCollectionView setBackgroundColor:color_black];
    }
    
    return _fontCollectionView;
}

- (WODSimpleScrollItemPicker *)effectsPicker
{
    if (!_effectsPicker)
    {
        _effectsPicker = [WODSimpleScrollItemPicker new];
        _effectsPicker.distansFromBottomPortrait = 0;
        _effectsPicker.distansFromBottomLandscape = 0;
        _effectsPicker.hideBorder = YES;
        _effectsPicker.displayStyle = DisplayStylePermenante;
        _effectsPicker.position = BarPostionBotton;
    }
    
    return _effectsPicker;
}

@end
