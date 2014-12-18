//
//  WODFontPicker.m
//  TOP
//
//  Created by ianluo on 13-12-12.
//  Copyright (c) 2013年 WOD. All rights reserved.
//

#import "WODFontPicker.h"
#import "RPVerticalStepper.h"
#import "WODFontManager.h"

#define fontFamilyTableTag 2
#define fontNameTableTag 3

@interface WODFontPicker()<UITableViewDelegate,UITableViewDataSource>

@property (nonatomic, strong)NSArray * allFontFamilies;
@property (nonatomic, strong)UITableView * fontFamilyTable;
@property (nonatomic, strong)UITableView * fontNameTable;
@property (nonatomic, strong)UILabel * fontSizeLabel;
@property (nonatomic, strong)RPVerticalStepper * fontSizeSteper;

@end

@implementation WODFontPicker

- (NSArray *)allFontFamilies
{
	if (!_allFontFamilies)
	{
		NSMutableArray * allFamilies = [NSMutableArray arrayWithArray: [UIFont familyNames]];
		NSArray * unregesteredFontFamilies = [[WODFontManager new]unregisteredFontFamilies];
		
		for (NSArray * urff in unregesteredFontFamilies)
		{
			if ([allFamilies containsObject:urff])
				[allFamilies removeObject:urff];
		}
		_allFontFamilies = [NSArray arrayWithArray:allFamilies];
	}
	return _allFontFamilies;
}

- (id)init
{
    self = [super init];
    if (self)
	{
		self.backgroundColor = color_black;
		self.currentFontSize = [self savedLastUsingFontSize] ? [self savedLastUsingFontSize].intValue : (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad ? DEFAULT_FONT_SIZE_IPAD : DEFAULT_FONT_SIZE_IPHONE);
		
		[self addSubview:self.fontFamilyTable];
		[self addSubview:self.fontNameTable];
		/*hide size steper in picker, show in toolbar[self addSubview:self.fontSizeSteper];*/
		/*hide size steper in picker, show in toolbar[self addSubview:self.fontSizeLabel];*/
				
		[self addObserver:self forKeyPath:@"currentFontSize" options:NSKeyValueObservingOptionNew context:nil];
    }
    return self;
}

- (void)dealloc
{
#ifdef DEBUGMODE
	NSLog(@"(%@,%i):deallocing..",[[NSString stringWithUTF8String:__FILE__]lastPathComponent],__LINE__);
#endif
	[self removeObserver:self forKeyPath:@"currentFontSize"];
}

- (UITableView *)fontFamilyTable
{
	if(!_fontFamilyTable)
	{
#define fontFamilyTableCell @"fontFamilyTableCell"
		_fontFamilyTable = [UITableView new];
		_fontFamilyTable.dataSource = self;
		_fontFamilyTable.delegate = self;
		_fontFamilyTable.tag = fontFamilyTableTag;
		_fontFamilyTable.translatesAutoresizingMaskIntoConstraints = NO;
		_fontFamilyTable.backgroundColor = [UIColor clearColor];
		_fontFamilyTable.separatorStyle = UITableViewCellSeparatorStyleNone;
		[_fontFamilyTable registerClass:[UITableViewCell class] forCellReuseIdentifier:fontFamilyTableCell];
	}
	return _fontFamilyTable;
}

- (UITableView *)fontNameTable
{
	if(!_fontNameTable)
	{
#define fontNameTableCell @"fontNameTableCell"
		_fontNameTable = [UITableView new];
		_fontNameTable.dataSource = self;
		_fontNameTable.delegate = self;
		_fontNameTable.tag = fontNameTableTag;
		_fontNameTable.translatesAutoresizingMaskIntoConstraints = NO;
		_fontNameTable.backgroundColor = [UIColor clearColor];
		_fontNameTable.separatorStyle = UITableViewCellSeparatorStyleNone;
		[_fontNameTable registerClass:[UITableViewCell class] forCellReuseIdentifier:fontNameTableCell];
	}
	return _fontNameTable;
}

//- (UILabel*)fontSizeLabel
//{
//	if (!_fontSizeLabel)
//	{
//		_fontSizeLabel = [UILabel new];
//		_fontSizeLabel.font = [UIFont flatFontOfSize:14];
//		_fontSizeLabel.textColor = COLOR_TEXT_TITLE;
//		_fontSizeLabel.translatesAutoresizingMaskIntoConstraints = NO;
//		_fontSizeLabel.textAlignment = NSTextAlignmentLeft;
//	}
//	return _fontSizeLabel;
//}

- (RPVerticalStepper *)fontSizeSteper
{
	if(!_fontSizeSteper)
	{
		_fontSizeSteper = [RPVerticalStepper new];
		_fontSizeSteper.minimumValue = 10;
		_fontSizeSteper.maximumValue = 1000;
		_fontSizeSteper.value = self.currentFontSize;
		_fontSizeSteper.autoRepeatInterval = 0.03;
		_fontSizeSteper.translatesAutoresizingMaskIntoConstraints = NO;
		_fontSizeSteper.tintColor = color_white;
		[_fontSizeSteper addTarget:self action:@selector(fontSizeSteperValueChanged:) forControlEvents:UIControlEventValueChanged];		
	}
	return _fontSizeSteper;
}

- (void)setupSelectedValues
{
	if (self.textView.text.length == 0)
	{
		self.currentFontFamily = [self savedLastUsingFontFamily] ? [self savedLastUsingFontFamily] : @"Georgia";
		self.currentFontName = [self savedLastUsingFontName] ? [self savedLastUsingFontName] : @"Georgia-Bold";
	}
	else
	{
		NSRange range = NSMakeRange(self.textView.text.length - 1, 1);
		NSDictionary * attrs = [self.textView.attributedText attributesAtIndex:self.textView.text.length - 1 effectiveRange:&range];
		
		UIFont * font = [attrs objectForKey:NSFontAttributeName];
		if (font)
		{
			self.currentFontFamily = [font familyName];
			self.currentFontName = [font fontName];
			self.currentFontSize = [font pointSize];
		}
	}
	
	//init value for fontSizeSteper
	self.fontSizeSteper.value = self.currentFontSize;
	
	//update the font name table, according to the current font family value(self.currentFontFamily)
//	[self.pickerView reloadComponent:1];
	
	//find the
	[self.allFontFamilies enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop)
	{
		if ([(NSString *)obj caseInsensitiveCompare:[self.currentFontFamily stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]]] == NSOrderedSame)
		{
			[self.fontFamilyTable selectRowAtIndexPath:[NSIndexPath indexPathForRow:idx inSection:0] animated:YES scrollPosition:UITableViewScrollPositionMiddle];
			BOOL isStop = YES;
			stop = &isStop;
		}
	}];
	
	
	[[UIFont fontNamesForFamilyName:self.currentFontFamily] enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop)
	 {
		 if ([(NSString *)obj isEqualToString:self.currentFontName])
		 {
			 [self.fontNameTable selectRowAtIndexPath:[NSIndexPath indexPathForRow:idx inSection:0] animated:YES scrollPosition:UITableViewScrollPositionMiddle];
			 BOOL isStop = YES;
			 stop = &isStop;
		 }
	 }];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	return 30;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	NSInteger rowNumber = 0;
	if (tableView.tag == fontFamilyTableTag)
	{
		rowNumber = self.allFontFamilies.count;
	}
	else if(tableView.tag == fontNameTableTag)
	{
		rowNumber = [UIFont fontNamesForFamilyName:self.currentFontFamily].count;
	}
	return rowNumber;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	UITableViewCell * cell;
	
	if (tableView.tag == fontFamilyTableTag)
	{
		cell = [tableView dequeueReusableCellWithIdentifier:fontFamilyTableCell];
		cell.textLabel.text = self.allFontFamilies[indexPath.row];
		cell.textLabel.font = [UIFont fontWithName:[UIFont fontNamesForFamilyName:cell.textLabel.text][0] size:15];
	}
	
	if (tableView.tag == fontNameTableTag)
	{
		cell = [tableView dequeueReusableCellWithIdentifier:fontNameTableCell];
		NSString * fontName = [UIFont fontNamesForFamilyName:self.currentFontFamily][indexPath.row];
		NSArray * fontNameComponents = [fontName componentsSeparatedByString:@"-"];
		fontName = fontNameComponents.count > 1 ? fontNameComponents[1] : [fontName isEqualToString:self.currentFontFamily] ? @"Regular" : [fontName stringByReplacingOccurrencesOfString:self.currentFontFamily withString:@""];
		cell.textLabel.text = fontName;
		cell.textLabel.font = [UIFont fontWithName:cell.textLabel.text size:12];
	}
	
	[cell.textLabel setTextColor:color_white];
	[cell setBackgroundColor:[UIColor clearColor]];
	
	return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	switch (tableView.tag)
	{
		case fontFamilyTableTag:
		{
			self.currentFontFamily = self.allFontFamilies[indexPath.row];
			[self.fontNameTable reloadData];
			self.currentFontName = [UIFont fontNamesForFamilyName:self.currentFontFamily][0];
			
			[self.fontNameTable selectRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] animated:YES scrollPosition:UITableViewScrollPositionMiddle];
			break;
		}
		case fontNameTableTag:
		{
			self.currentFontName = [UIFont fontNamesForFamilyName:self.currentFontFamily][indexPath.row];
			break;
		}
	}
	
	[self saveLastUsingFont:self.currentFontName family:self.currentFontFamily andSize:(int)self.currentFontSize];
	
	if([self.delegate respondsToSelector:@selector(didFinishPickingFont:picker:)])
		[self.delegate didFinishPickingFont:[UIFont fontWithName:self.currentFontName size:self.currentFontSize] picker:self];
}

- (void)fontSizeSteperValueChanged:(RPVerticalStepper *)steper
{
	self.currentFontSize = steper.value;
	
	UIFont * font = [UIFont fontWithName:self.currentFontName size:self.currentFontSize];
	
	if([self.delegate respondsToSelector:@selector(didFinishPickingFont:picker:)])
		[self.delegate didFinishPickingFont:font picker:self];
		
	UILabel * previewLabel = [UILabel new];
	[previewLabel setText:@"A"];
	[previewLabel setFont:font];
	[previewLabel sizeToFit];
	[previewLabel setTextColor:[UIColor whiteColor]];
	
	[previewLabel setCenter:CGPointMake(self.bounds.size.width/2, self.bounds.size.height/2)];
	[self addSubview:previewLabel];
	
	[UIView animateWithDuration:0.2 animations:^{
		previewLabel.alpha = 1;
	} completion:^(BOOL finished) {
		[UIView animateWithDuration:0.4 animations:^{
			previewLabel.alpha = 0;
		} completion:^(BOOL finished) {
			[previewLabel removeFromSuperview];
		}];
	}];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
// update font size label when 'currntFontSize' changed
	if ([keyPath isEqualToString:@"currentFontSize"])
	{
		[self saveLastUsingFont:self.currentFontName family:self.currentFontFamily andSize:(int)self.currentFontSize];
//		self.fontSizeLabel.text = [NSString stringWithFormat:@"%ld",(long)self.currentFontSize];
	}
}

- (void)layoutSubviews
{
	[super layoutSubviews];
	
	[self removeConstraints:self.constraints];
	
	CGSize size = [WODConstants currentSize];
	float familyTableSize = size.width * 0.65, fontNameTableSize = size.width * 0.35 /*hide size steper in picker, show in toolbar  ,  fonSizeSteperSize = size.width * 0.1*/;
	
	[self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|[fontFamilyTable(familyTableSize)][fontNameTable(fontNameTable)]|" options:0 metrics:@{@"familyTableSize":@(familyTableSize),@"fontNameTableSize":@(fontNameTableSize)} views:@{@"fontFamilyTable":self.fontFamilyTable,@"fontNameTable":self.fontNameTable}]];
	/*hide size steper in picker, show in toolbar  [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"[fontSizeLabel(fonSizeSteperSize)]-|" options:0 metrics:@{@"fonSizeSteperSize":@(fonSizeSteperSize)} views:@{@"fontSizeLabel":self.fontSizeLabel}]];*/
	
	[self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[fontFamilyTable]|" options:0 metrics:nil views:@{@"fontFamilyTable":self.fontFamilyTable}]];
	[self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[fontNameTable]|" options:0 metrics:nil views:@{@"fontNameTable":self.fontNameTable}]];
	/*hide size steper in picker, show in toolbar[self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-[fontSizeLabel]-|" options:0 metrics:nil views:@{@"sizeSteper":self.fontSizeSteper}]];*/
	
	[super layoutSubviews];
}

#define k_lastUsingFontFamily @"k_lastUsingFontFamily"
#define k_lastUsingFontName @"k_lastUsingFontName"
#define k_lastUsingFontSize @"k_lastUsingFontSize"

- (void)saveLastUsingFont:(NSString *)fontName family:(NSString *)family andSize:(int)size
{
	[[NSUserDefaults standardUserDefaults]setObject:family forKey:k_lastUsingFontFamily];
	[[NSUserDefaults standardUserDefaults]setObject:fontName forKey:k_lastUsingFontName];
	[[NSUserDefaults standardUserDefaults]setObject:@(size) forKey:k_lastUsingFontSize];
	[[NSUserDefaults standardUserDefaults]synchronize];
}

- (NSString *)savedLastUsingFontFamily
{
	return [[NSUserDefaults standardUserDefaults]objectForKey:k_lastUsingFontFamily];
}

- (NSString *)savedLastUsingFontName
{
	return [[NSUserDefaults standardUserDefaults]objectForKey:k_lastUsingFontName];
}

- (NSNumber *)savedLastUsingFontSize
{
	return [[NSUserDefaults standardUserDefaults]objectForKey:k_lastUsingFontSize];
}

@end
