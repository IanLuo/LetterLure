//
//  WODEditHomeActions.m
//  TOP
//
//  Created by ianluo on 14-8-20.
//  Copyright (c) 2014年 WOD. All rights reserved.
//

#import "WODEditHomeActions.h"
#import "WODInputTextViewController.h"
#import "WODSimpleScrollItemPicker.h"
#import "WODActionSheet.h"
#import "WODBendViewController.h"
#import "WODEffectPackageManager.h"
#import "WODTextLayerManager.h"
#import "WODEffect.h"
#import "ASValueTrackingSlider.h"
#import <BlocksKit/BlocksKit+UIKit.h>

@interface WODEditHomeActions()

@property (nonatomic, strong) NSMutableArray * orientationSensibleConstraints;


@end

@implementation WODEditHomeActions

#pragma mark -

- (void)startPreview
{
	[self.editHomeController.openGLStageView preview];
}

- (void)stopPreview
{
	[self.editHomeController.openGLStageView selectTextView:self.editHomeController.textLayerManager.currentTextView];
}

- (void)editText:(UIButton *)button
{
	WODInputTextViewController * inputTextViewController = [WODInputTextViewController new];
	inputTextViewController.editType = EditTypeModify;
	inputTextViewController.delegate = self.editHomeController;
	inputTextViewController.textView.attributedText = self.editHomeController.textLayerManager.currentTextView.text;
	
	self.editHomeController->customNavigationTransition = YES;
	[self.editHomeController performSelector:@selector(fadeNavigationPush:) withObject:inputTextViewController];
}

- (void)deleteCurrentText
{
	if (self.editHomeController.textLayerManager.currentTextView)
	{
		UIAlertView * alertView =  [[UIAlertView alloc]initWithTitle:@"Delete" message:@"Delete?" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Yes", nil];
		[alertView show];
	}
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
	if (buttonIndex == 1)
	{
		[self deleteCurrentTextAction];
	}
}

- (void)deleteCurrentTextAction
{
	//remove from opengle es stage
	[self.editHomeController.openGLStageView removeTextView:self.editHomeController.textLayerManager.currentTextView];
	
	//remove from text manager
	[self.editHomeController.textLayerManager removeTextView:self.editHomeController.textLayerManager.currentTextView];
	
    if (self.editHomeController.textLayerManager.allTextViews.count > 0)
	{
		[self.editHomeController.textLayerManager selectTextView:self.editHomeController.textLayerManager.allTextViews[0]];
		[self.editHomeController.openGLStageView selectTextView:self.editHomeController.textLayerManager.currentTextView];
	}
	
	[self.editHomeController checkControlVisiability];
}

- (void)setCurrentItemPicker:(WODItemPicker *)currentItemPicker
{
	[self.editHomeController.currentItemPicker dismiss];
    
	self.editHomeController.currentItemPicker = currentItemPicker;
}

- (void)typesetter:(UIButton *)button
{
    ws(wself);
    UIActionSheet * typesetterAS = [UIActionSheet new];
    
    [typesetterAS setTitle:iStr(@"Use Typesetting")];
    
    [typesetterAS bk_addButtonWithTitle:iStr(@"VC_TITLE_TYPESETTER_BEND") handler:^{
        
        [wself bendDraw];
        
    }];
    
    [typesetterAS bk_addButtonWithTitle:iStr(@"VC_TITLE_TYPESETTER_FREE_DRAW") handler:^{
       
        [wself freeDraw];
        
    }];
    
    [typesetterAS bk_addButtonWithTitle:iStr(@"VC_TITLE_TYPESETTER_SHAPE") handler:^{
        
        [wself shapeDraw];
        
    }];
    
    [typesetterAS bk_setCancelButtonWithTitle:iStr(@"CANCEL") handler:nil];
    
    [typesetterAS showInView:self.editHomeController.view];
}

- (void)freeDraw
{
	UIImage * bgImage = [self.editHomeController.openGLStageView snapeshotScreenHide:@[@(self.editHomeController.textLayerManager.currentTextView.name)]];
	
	WODFreeDrawViewController * freeDrawViewController = [WODFreeDrawViewController new];
	[freeDrawViewController setImage:bgImage];
	[freeDrawViewController setTextView:self.editHomeController.textLayerManager.currentTextView];
	[freeDrawViewController.textView setHideFeatures:YES];
	freeDrawViewController.delegate = self.editHomeController;
	
	[self.editHomeController fadeNavigationPush:freeDrawViewController];
}

- (void)shapeDraw
{
	UIImage * bgImage = [self.editHomeController.openGLStageView snapeshotScreenHide:@[@(self.editHomeController.textLayerManager.currentTextView.name)]];
	
	WODShapeViewController * shapeViewController = [WODShapeViewController new];
	[shapeViewController setImage:bgImage];
	[shapeViewController setTextView:self.editHomeController.textLayerManager.currentTextView];
	[shapeViewController.textView setHideFeatures:YES];
	shapeViewController.delegate = self.editHomeController;
	
	[self.editHomeController fadeNavigationPush:shapeViewController];
}

- (void)bendDraw
{
	UIImage * bgImage = [self.editHomeController.openGLStageView snapeshotScreenHide:@[@(self.editHomeController.textLayerManager.currentTextView.name)]];
	
	WODBendViewController * bendViewController = [WODBendViewController new];
	[bendViewController setDelegate:self.editHomeController];
	[bendViewController setImage:bgImage];
	[bendViewController setTextView:self.editHomeController.textLayerManager.currentTextView];
	[bendViewController.textView setHideFeatures:YES];
	
	[self.editHomeController fadeNavigationPush:bendViewController];
}

- (void)chooseText:(UIBarButtonItem *)sender
{
    UIActionSheet * chooseTextAS = [UIActionSheet new];
    
    [chooseTextAS setTitle:iStr(@"Choose Text")];
    
    ws(wself);
    [chooseTextAS bk_addButtonWithTitle:iStr(@"VC_TITLE_ADD_NEW_TEXT") handler:^{
        
        [wself.editHomeController addText];
        
    }];
	
	BOOL isIPad = UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad;
	int maxTextLength = isIPad ? 20 : 10;
	
	__block NSUInteger index = 0;
	for (WODTextView * textView in [self.editHomeController.textLayerManager allTextViews])
	{
		NSString * title = textView.text.string.length < maxTextLength ? textView.text.string : [[textView.text.string substringToIndex:maxTextLength-3] stringByAppendingString:@".."];
        
        WODTextView * selectedTextView = [wself.editHomeController.textLayerManager allTextViews][index++];
        
        ws(wself);
        [chooseTextAS bk_addButtonWithTitle:title handler:^{
            
            [wself.editHomeController selectTextView:selectedTextView];
            
        }];
		
	}
    
    [chooseTextAS bk_setCancelButtonWithTitle:iStr(@"CANCEL") handler:nil];
    
    [chooseTextAS showInView:self.editHomeController.view];
}

static unsigned int effectIndex;

- (void)applyEffect:(UIButton *)button
{
	[button setSelected:!button.isSelected];
	
	if (!button.isSelected)
	{
		self.currentItemPicker = nil;
		return;
	}
	
	WODSimpleScrollItemPicker * simpleScrollItemPicker = [WODSimpleScrollItemPicker new];
	simpleScrollItemPicker.selectedIndex = effectIndex;
	UIImageView * showAllImageView = [[UIImageView alloc]initWithImage:[[UIImage imageNamed:@"more.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate]];
	[showAllImageView setContentMode:UIViewContentModeCenter];
	[simpleScrollItemPicker addItemWithView:showAllImageView];
	UIImageView * removeEffectImageView = [[UIImageView alloc]initWithImage:[[UIImage imageNamed:@"trash.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate]];
    
	[removeEffectImageView setContentMode:UIViewContentModeCenter];
	[simpleScrollItemPicker addItemWithView:removeEffectImageView];
	[simpleScrollItemPicker setControlItemIndexs:@[@(0),@(1)]];
	[simpleScrollItemPicker setHideBorder:YES];//this option only works for non-control items
	
	simpleScrollItemPicker.position = BarPostionBotton;
	
	WODEffectPackageManager * effectPackageManager = [WODEffectPackageManager new];
	
	NSString * packageName = [[NSUserDefaults standardUserDefaults]valueForKey:kCurrentSelectedEffectPackageName];
	if (!packageName)packageName = kDefualtPackageName;
	
	NSArray * effectsPaths = [effectPackageManager effectsInPackage:packageName];
	
	for (NSString * path in effectsPaths)
	{
		
		UIImage * image = [effectPackageManager iconForEffect:path];
		if (image)
		{
			UIImageView * effecIcon = [[UIImageView alloc]initWithImage:[effectPackageManager iconForEffect:path]];
			[effecIcon setContentMode:UIViewContentModeCenter];
			[simpleScrollItemPicker addItemWithView:effecIcon];
		}
		else
			[simpleScrollItemPicker addItem:[path lastPathComponent]];
	}
	
	__weak typeof(self) weakSelf = self;
	[simpleScrollItemPicker showFrom:self.editHomeController.view withSelection:^(WODSimpleScrollItemPickerItem *selectedItem)
	 {
		 if (selectedItem)
		 {
			 if (selectedItem.index == 0)
			 {
				 WODEffectsPackageViewController * packageViewController = [WODEffectsPackageViewController new];
				 packageViewController.delegate = weakSelf.editHomeController;
				 UINavigationController * navVC = [[UINavigationController alloc]initWithRootViewController:packageViewController];
				 [navVC setModalPresentationStyle:UIModalPresentationFormSheet];
				 [self.editHomeController presentViewController:navVC animated:YES completion:^{
					 [simpleScrollItemPicker dismiss];
				 }];
			 }
			 else if (selectedItem.index == 1)
			 {
				 [weakSelf.editHomeController.textLayerManager.currentTextView setEffectProvider:nil];
				 
				 weakSelf.editHomeController.textLayerManager.currentTextView.hideFeatures = NO;
				 [weakSelf.editHomeController.openGLStageView updateTextViewImage:weakSelf.editHomeController.textLayerManager.currentTextView];
			 }
			 else
			 {
				 NSString * xmlFilePath = [effectsPaths[selectedItem.index - 2]stringByAppendingString:@"/effect.xml"];
				 WODEffect * effect = [[WODEffect new] initWithXMLFilePath:xmlFilePath];
				 if(weakSelf.editHomeController.textLayerManager.currentTextView.effectProvider != effect)
				 {
					 [effect prepare:^{
                         
						 effectIndex = (unsigned int)selectedItem.index;
						 
						 weakSelf.editHomeController.textLayerManager.currentTextView.effectProvider = nil;
						 [weakSelf.editHomeController.textLayerManager.currentTextView setEffectProvider:effect];
						 
						 [weakSelf.editHomeController.openGLStageView updateTextViewImage:weakSelf.editHomeController.textLayerManager.currentTextView];
					 
                     }];
				 }
			 }
		 }
		 else
		 {
			 [button setSelected:NO];
		 }
	 }];
	
	self.currentItemPicker = simpleScrollItemPicker;
	[self.editHomeController.view bringSubviewToFront:self.editHomeController.toolbar];
}

- (void)setOpacity:(WODButton *)button
{
	[button setSelected:!button.isSelected];
	
	if (!button.isSelected)
	{
		self.currentItemPicker = nil;
        
		return;
	}
	
	WODSimpleScrollItemPicker * opacityView = [WODSimpleScrollItemPicker new];
	opacityView.position = BarPostionBotton;
	[opacityView showFrom:self.editHomeController.view withSelection:nil];
	[self.editHomeController.view bringSubviewToFront:self.editHomeController.toolbar];
	WODTextView * currentTextview = [self.editHomeController.textLayerManager currentTextView];
	
	ASValueTrackingSlider * slider = [[ASValueTrackingSlider alloc]initWithFrame:CGRectMake(10, opacityView.bounds.size.height - 40 - [WODConstants navigationbarHeight], opacityView.frame.size.width - 20, 40)];
    
	slider.value = currentTextview.alpha.floatValue;
	slider.maximumValue = 1.0;
	slider.minimumValue = 0.01;
	slider.popUpViewCornerRadius = 12.0;
	[slider setMaxFractionDigitsDisplayed:0];
	slider.textColor = [UIColor whiteColor];
	[slider addTarget:self action:@selector(opacityChanged:) forControlEvents:UIControlEventTouchUpInside];
	
	NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
	[formatter setNumberStyle:NSNumberFormatterPercentStyle];
	[slider setNumberFormatter:formatter];
	slider.font = [UIFont systemFontOfSize:12];
	[opacityView addSubview:slider];
	
	self.currentItemPicker = opacityView;
}

- (void)opacityChanged:(UISlider *)slider
{
	WODTextView * currentTextview = [self.editHomeController.textLayerManager currentTextView];
	[currentTextview setAlpha:@(slider.value)];
    
	[self.editHomeController.openGLStageView updateTextViewImage:currentTextview];
}

@end
