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
	
	self.edgesForExtendedLayout = UIRectEdgeNone;
	
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

- (void)viewWillLayoutSubviews
{
	[self.view removeConstraints:self.view.constraints];
	
	UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
	
	if ((orientation == UIInterfaceOrientationLandscapeLeft || orientation == UIInterfaceOrientationLandscapeRight) && (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone))
	{
		[self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[collectionView]|" options:0 metrics:nil views:@{@"collectionView":self.collectionView}]];
		[self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[player]|" options:0 metrics:nil views:@{@"collectionView":self.collectionView,@"player":self.player.view}]];
		[self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|[collectionView(player)][player]|" options:0 metrics:nil views:@{@"collectionView":self.collectionView,@"player":self.player.view}]];
		
		[self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[pageControl]|" options:0 metrics:nil views:@{@"pageControl":self.pageControl,@"player":self.player.view}]];
		[self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|[pageControl][player]|" options:0 metrics:nil views:@{@"pageControl":self.pageControl,@"player":self.player.view}]];
	}
	else
	{
		[self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|[collectionView]|" options:0 metrics:nil views:@{@"collectionView":self.collectionView}]];
		[self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|[player]|" options:0 metrics:nil views:@{@"collectionView":self.collectionView,@"player":self.player.view}]];
		[self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[collectionView(player)][player]|" options:0 metrics:nil views:@{@"collectionView":self.collectionView,@"player":self.player.view}]];
		
		[self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[pageControl][player]|" options:0 metrics:nil views:@{@"pageControl":self.pageControl,@"player":self.player.view}]];
		[self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|[pageControl]|" options:0 metrics:nil views:@{@"pageControl":self.pageControl}]];
	}
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
	NSMutableArray * visibaleIndexPaths = [NSMutableArray array];
	for(UICollectionViewCell * cell in [self.collectionView visibleCells])
	{
		NSIndexPath * indexPath = [self.collectionView indexPathForCell:cell];
		[visibaleIndexPaths addObject:indexPath];
	}
	
	[self.collectionView reloadItemsAtIndexPaths:[NSArray arrayWithArray:visibaleIndexPaths]];
	[self.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForRow:self.pageControl.currentPage inSection:0] atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally animated:YES];
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
