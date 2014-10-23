//
//  WODFilterSelector.h
//  TOP
//
//  Created by ianluo on 14-5-19.
//  Copyright (c) 2014年 WOD. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WODFilterSelector : UIView<UICollectionViewDataSource, UICollectionViewDelegate,UIGestureRecognizerDelegate>
{
	void (^completeAction)(NSString *filterName);
}

@property (nonatomic, strong) UICollectionView * filtersView;
@property (nonatomic, strong) NSArray * filterNames;
@property (nonatomic, weak)UIView *parentView;

- (void)showFiltersViewIn:(UIView *)view WithComplete:(void (^)(NSString * filterName))action;

@end

@interface FilterCell : UIView

@property (nonatomic, strong)UILabel * title;
@property (nonatomic, strong)UIImageView * imageView;

@end