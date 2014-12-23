//
//  WODUserGuide.m
//  TOP
//
//  Created by ianluo on 14-4-28.
//  Copyright (c) 2014年 WOD. All rights reserved.
//

#import "WODUserGuide.h"
#import "WODUserGuideView.h"
#import <MediaPlayer/MediaPlayer.h>

@interface WODUserGuide ()<UIScrollViewDelegate,UICollectionViewDataSource,UICollectionViewDelegate>

@property (nonatomic, strong)UICollectionView * collectionView;
@property (nonatomic, strong)UIPageControl * pageControl;
@property(nonatomic, strong) MPMoviePlayerController * player;

@end

@implementation WODUserGuide

- (void)viewDidLoad
{
    [super viewDidLoad];
		
	self.view.backgroundColor = color_black;
	self.view.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;

	UIBarButtonItem * skip = [[UIBarButtonItem alloc]initWithTitle:NSLocalizedString(@"USERGUIDE_SKIP",nil) style:UIBarButtonItemStylePlain target:self action:@selector(dismiss)];
	self.navigationItem.leftBarButtonItem = skip;
	
	_pageControl = [UIPageControl new];
	_pageControl.numberOfPages = 4;
	_pageControl.currentPage = 0;
	_pageControl.translatesAutoresizingMaskIntoConstraints = NO;
	_pageControl.backgroundColor = color_black;
	
	self.navigationItem.rightBarButtonItem = [self rightBarItem:self.pageControl.currentPage];
	
	[self updateTitle:self.pageControl.currentPage];
	
	UICollectionViewFlowLayout * flowLayout = [UICollectionViewFlowLayout new];
	flowLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
	flowLayout.minimumInteritemSpacing = 0;
	flowLayout.minimumLineSpacing = 0;
	
	_collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:flowLayout];
    self.collectionView.contentInset = UIEdgeInsetsMake(isVertical() ? HEIGHT_STATUS_AND_NAV_BAR : 0, 0, 0, 0);
	_collectionView.backgroundColor = color_black;
	_collectionView.showsHorizontalScrollIndicator = NO;
	_collectionView.translatesAutoresizingMaskIntoConstraints = NO;
	_collectionView.pagingEnabled = YES;
	_collectionView.delegate = self;
	_collectionView.dataSource = self;
	[self.collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"UserGuideCell"];
	
	[self.view addSubview:self.collectionView];
	[self.view addSubview:self.player.view];
	[self.view addSubview:self.pageControl];
    
    if(isVertical())
    {
        [self updatePortraiteConstraints];
    }
    else
    {
        [self updateLandscapeConstraints];
    }
}

- (void)updatePortraiteConstraints
{
    [self.collectionView mas_remakeConstraints:^(MASConstraintMaker *make) {
        
        make.width.equalTo(self.view);
        make.top.equalTo(self.view.mas_top);
        make.height.mas_equalTo(@(self.view.viewHeight/2));
        
    }];
    
    [self.pageControl mas_remakeConstraints:^(MASConstraintMaker *make) {
        
        make.width.equalTo(self.collectionView.mas_width);
        make.bottom.equalTo(self.collectionView.mas_bottom);
        
    }];
    
    [self.player.view mas_remakeConstraints:^(MASConstraintMaker *make) {
        
        make.width.equalTo(self.view);
        make.top.equalTo(self.collectionView.mas_bottom);
        make.height.mas_equalTo(@(self.view.viewHeight/2));
        
    }];
}

- (void)updateLandscapeConstraints
{
    [self.collectionView mas_remakeConstraints:^(MASConstraintMaker *make) {
        
        make.width.mas_equalTo(@(self.view.viewWidth/2));
        make.left.equalTo(self.view.mas_left);
        make.height.equalTo(self.view.mas_height);
        
    }];
    
    [self.pageControl mas_remakeConstraints:^(MASConstraintMaker *make) {
        
        make.width.equalTo(self.collectionView.mas_width);
        make.bottom.equalTo(self.collectionView.mas_bottom);
        
    }];
    
    [self.player.view mas_remakeConstraints:^(MASConstraintMaker *make) {
        
        make.width.mas_equalTo(@(self.view.viewWidth/2));
        make.left.equalTo(self.collectionView.mas_right);
        make.top.equalTo(self.view.mas_top);
        make.height.equalTo(self.view.mas_height);
        
    }];
}

- (MPMoviePlayerController *)player
{
	if (!_player)
	{
		_player = [[MPMoviePlayerController alloc]init];
		[_player setRepeatMode:MPMovieRepeatModeOne];
		[_player setControlStyle:MPMovieControlStyleEmbedded];
		[_player setShouldAutoplay:YES];
		[_player.view setTranslatesAutoresizingMaskIntoConstraints:NO];
	}
	return _player;
}

- (void)viewDidAppear:(BOOL)animated
{
	[super viewDidAppear:animated];
	
	[self pageNumberChanged];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setMediaURL:(NSURL *)mediaURL
{
	[self.player setContentURL:mediaURL];
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    if(isVertical())
    {
        [self updatePortraiteConstraints];
    }
    else
    {
        [self updateLandscapeConstraints];
    }
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
	return self.pageControl.numberOfPages;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
	UICollectionViewCell * cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"UserGuideCell" forIndexPath:indexPath];
	
	for (UIView * view in cell.contentView.subviews)
	{
		[view removeFromSuperview];
	}
	
	UIView * view  = [self getPage:indexPath.row];
	[cell.contentView addSubview:view];
	
	return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
	return self.collectionView.bounds.size;
}

- (void)updateTitle:(NSUInteger)pageNumber
{
	NSArray * titles = @[@"USERGUIDE_INPUT_TEXT",@"USERGUIDE_ADJUST_TEXT",@"USERGUIDE_LAYOUT_TEXT",@"USERGUIDE_TEXT_EFFECT"];
	
	self.title = NSLocalizedString(titles[pageNumber], nil);
}

- (UIBarButtonItem *)rightBarItem:(NSUInteger)pageNumber
{
	if (pageNumber < self.pageControl.numberOfPages - 1)
	{
		UIBarButtonItem * rightBarItem = [[UIBarButtonItem alloc]initWithTitle:NSLocalizedString(@"USERGUIDE_NEXT", nil) style:UIBarButtonItemStylePlain target:self action:@selector(nextPage)];
		return rightBarItem;
	}
	else
	{
		UIBarButtonItem * rightBarItem = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(dismiss)];
								
		return rightBarItem;
	}
}

- (void)dismiss
{
	[self dismissViewControllerAnimated:YES completion:nil];
}

static NSArray * videoArray;

- (void)pageNumberChanged
{
	videoArray = @[@"input_text",@"3d_rotation",@"layout",@"apply_effect"];

	[self updateTitle:self.pageControl.currentPage];
	self.navigationItem.rightBarButtonItem = [self rightBarItem:self.pageControl.currentPage];
	
	[self setMediaURL:[[NSBundle mainBundle]URLForResource:videoArray[self.pageControl.currentPage] withExtension:@"m4v"]];
	if (self.player.playbackState == MPMoviePlaybackStatePlaying)
	{
		[self.player stop];
	}
	
	[self.player play];
}

- (void)nextPage
{
	if (self.pageControl.currentPage < self.pageControl.numberOfPages)
	{
		[self.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForRow:self.pageControl.currentPage + 1 inSection:0] atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally animated:YES];
	}
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
	int currentPage = floor(scrollView.contentOffset.x/scrollView.bounds.size.width);
	
	if (currentPage != self.pageControl.currentPage )
	{
		self.pageControl.currentPage = currentPage;
		[self pageNumberChanged];
	}
}

static NSArray * pageDescription;

- (UIView *)getPage:(NSUInteger)pageNumber
{
	pageDescription = @[@"USERGUIDE_INPUT_TEXT_DESC",@"USERGUIDE_ADJUST_TEXT_DESC",@"USERGUIDE_LAYOUT_TEXT_DESC",@"USERGUIDE_TEXT_EFFECT_DESC"];
	WODUserGuideView * view = [[WODUserGuideView alloc]initWithFrame:(CGRect){CGPointZero,self.collectionView.bounds.size}];
	view.textView.text = NSLocalizedString(pageDescription[pageNumber], nil);
		
	return view;
}

- (NSString *)videoForPage:(NSUInteger)pageNumber
{
	return @"";
}

@end
