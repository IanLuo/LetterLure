//
//  WODInputTextViewController.m
//  TOP
//
//  Created by ianluo on 13-12-25.
//  Copyright (c) 2013年 WOD. All rights reserved.
//

#import "WODInputTextViewController.h"
#import "WODColorPicker.h"
#import "WODFontPicker.h"
#import "WODButton.h"
#import "WODTextConfigureView.h"
#import "UIView+Appearance.h"
#import "UIImage+Generate.h"

#define toolbar_height 39
#define colorButtonTag 9
#define fontButtonTag 10
#define textConfigureButtonTag 8
#define COLOR_SELECTION [UIColor colorWithRed:18.0/255 green:97/255.0 blue:212/255.0 alpha:0.2]

@interface WODInputTextViewController ()<UITextViewDelegate,WODColorPickerDelegate,WODFontPickerDelegate,WODTextConfigureDelegate>
{
	float keyboardViewHeight;
}

@property (nonatomic, strong) UIView * toolbar;
@property (nonatomic, strong) NSArray * pickerConstraints;
@property (nonatomic, strong) UIColor * currentColor;
@property (nonatomic, strong) UIFont * currentFont;
@property (nonatomic, strong) WODColorPicker * colorPicker;
@property (nonatomic, strong) WODFontPicker * fontPicker;
@property (nonatomic, strong) WODTextConfigureView * configurePicker;

@end

@implementation WODInputTextViewController

- (id)init
{
    self = [super init];
    if (self)
    {
		self.view.backgroundColor = color_black;
				
		[[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(keyboardDidShow:) name:UIKeyboardWillShowNotification object:nil];
    }
    return self;
}

- (void)dealloc
{
    WODDebug(@"deallocing..");
    
	[self.textView resignFirstResponder];
    
	[[NSNotificationCenter defaultCenter]removeObserver:self];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
		
	[self setTitle:iStr(@"VC_TITLE_INPUT_TEXT")];
    
    [self setAutomaticallyAdjustsScrollViewInsets:NO];
	
	UIBarButtonItem * back = [[UIBarButtonItem alloc]initWithImage:[[UIImage imageNamed:@"cross_mark.png"]imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] style:UIBarButtonItemStylePlain target:self action:@selector(back)];
	[self.navigationItem setLeftBarButtonItem:back];
	
	UIBarButtonItem * ok = [[UIBarButtonItem alloc]initWithImage:[[UIImage imageNamed:@"check_mark.png"]imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] style:UIBarButtonItemStylePlain  target:self action:@selector(ok)];
	[self.navigationItem setRightBarButtonItem:ok];
	
	[self.view addSubview:self.textView];
    
    [self.view addSubview:self.toolbar];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];

	[self.textView becomeFirstResponder];
		
	// use the setted attrs
	[self applyTextInputAttrs];
}

- (void)setupDefaultFontValues
{
    //set the font to the last text font, if the textview is empty, will set the default font, defined in WODFontPicker
    [self setCurrentFont:[UIFont fontWithName:self.fontPicker.currentFontName size:self.fontPicker.currentFontSize]];

    //only need to call those functions when there's text in the textview
    if (self.textView.text.length > 0)
    {

        //set the color to the last text color
        NSRange range = NSMakeRange(self.textView.text.length - 1, 1);
        UIColor *color = [self.textView.attributedText attributesAtIndex:self.textView.text.length - 1 effectiveRange:&range][NSForegroundColorAttributeName];

        if (color)
        {
            self.currentColor = color;
            [self updateToolbarColorButton];
        }
    }
}

- (void)back
{	
	if ([self.delegate respondsToSelector:@selector(didCancelInputtingText:)])
		[self.delegate didCancelInputtingText:self];
}

- (void)ok
{
	if ([self.delegate respondsToSelector:@selector(didFinishInputtingText:text:)])
		[self.delegate didFinishInputtingText:self text:self.textView.attributedText];
}

- (void)layout
{
	[self hidePikcerViewIfNeeded];
}

- (void)keyboardDidShow:(NSNotification *)notification
{
	CGRect keyboardBounds = [(notification.userInfo)[UIKeyboardFrameEndUserInfoKey] CGRectValue];
	keyboardBounds = [self.view convertRect:keyboardBounds toView:nil];
	keyboardViewHeight = keyboardBounds.size.height;

    [self setupDefaultFontValues];

    [self updateToolbarFontButton];
    
    [self updateSubviewConstraints];
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    [self updateSubviewConstraints];
}

- (void)updateSubviewConstraints
{
    ws(wself);
    
    NSUInteger topOffset = HEIGHT_STATUS_AND_NAV_BAR;
    if (!isVertical())
    {
        topOffset = HEIGHT_STATUS_AND_NAV_BAR_LANDSCAPE;
    }
    
    [self.textView mas_remakeConstraints:^(MASConstraintMaker *make) {
        
        make.edges.equalTo(wself.view).insets(UIEdgeInsetsMake(topOffset + 10, 10, keyboardViewHeight + toolbar_height, 10));
        
        WODDebug(@"textview frame : %@",NSStringFromCGRect(wself.textView.frame));
    }];
    
    [self.toolbar mas_remakeConstraints:^(MASConstraintMaker *make) {
        
        make.top.equalTo(wself.textView.mas_bottom).offset(-5);
        make.right.equalTo(wself.view).offset(-10);
        make.left.equalTo(wself.view).offset(5);
        make.height.mas_equalTo(@(toolbar_height));
        
        WODDebug(@"toolbar frame : %@",NSStringFromCGRect(wself.toolbar.frame));
    }];
}

#pragma mark - text view delegate

- (void)textViewDidChangeSelection:(UITextView *)textView
{
	NSRange selectedRange = [textView selectedRange];
	
	if (self.textView.attributedText.length >= selectedRange.location)
	{
		if (self.textView.attributedText.length == 0)
		{
			return;
		}
		
		NSDictionary * attribute;
		if (self.textView.attributedText.length == selectedRange.location)
		{
			NSRange range = NSMakeRange(self.textView.text.length - 1, 1);
			attribute = [self.textView.attributedText attributesAtIndex:range.location effectiveRange:&range];
			return;
		}
		else
		{
			attribute = [self.textView.attributedText attributesAtIndex:selectedRange.location effectiveRange:&selectedRange];
		}
		
		if (attribute) {
			self.textView.typingAttributes = attribute;
			
			if (attribute[NSForegroundColorAttributeName])
			{
				self.currentColor = attribute[NSForegroundColorAttributeName];
				[self updateToolbarColorButton];
			}
			if (attribute[NSFontAttributeName])
			{
				self.currentFont = attribute[NSFontAttributeName];
				[self updateToolbarFontButton];
			}
		}
		else
		{
			[self applyTextInputAttrs];
		}
	}
	else
	{
		[self applyTextInputAttrs];
	}
	
	//a acceptable workaround for textview bug, which don't autoscroll to the typing line
	//TODO: fix it
	[textView scrollRangeToVisible: [textView selectedRange]];
}

- (void)textViewDidBeginEditing:(UITextView *)textView
{
	NSMutableAttributedString * mutableAttrString = [[NSMutableAttributedString alloc] initWithAttributedString:self.textView.attributedText];
	
	for (int i = 0; i < self.textView.text.length; i++)
	{
		NSRange range = NSMakeRange((NSUInteger) i, 1);
		if ([mutableAttrString attribute:NSBackgroundColorAttributeName atIndex:i effectiveRange:&range])
		{
			[mutableAttrString removeAttribute:NSBackgroundColorAttributeName range:range];
		}
	}
	[self.textView setAttributedText:mutableAttrString];
}

- (void)textViewDidEndEditing:(UITextView *)textView
{
	if (self.textView.selectedRange.length>0)
	{
		NSRange range = self.textView.selectedRange;
		NSMutableAttributedString * mutableAttrString = [[NSMutableAttributedString alloc] initWithAttributedString:self.textView.attributedText];
		[mutableAttrString addAttribute:NSBackgroundColorAttributeName value:COLOR_SELECTION range:range];
		[self.textView setAttributedText:mutableAttrString];
		self.textView.selectedRange = range;
	}
}

- (void)updateToolbarColorButton
{
	WODButton * color = (WODButton *)[self.toolbar viewWithTag:colorButtonTag];
	[color setBackgroundColor:self.currentColor];
}

- (void)updateToolbarFontButton
{
	WODButton * font = (WODButton *)[self.toolbar viewWithTag:fontButtonTag];
	[font setTitle:[NSString stringWithFormat:@"Abc %.0f",self.currentFont.pointSize] forState:UIControlStateNormal];
	font.titleLabel.font = [UIFont fontWithName:self.currentFont.fontName size:16];
}

- (void)updateToolbarTextAlignmentButton
{
	WODButton * font = (WODButton *)[self.toolbar viewWithTag:textConfigureButtonTag];
	
	UIImage * icon;
	if (self.textView.textAlignment == NSTextAlignmentLeft)
	{
		icon = [[UIImage imageNamed:@"text_align_left"]imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
	}
	
	else if (self.textView.textAlignment == NSTextAlignmentCenter)
	{
		icon = [[UIImage imageNamed:@"text_align_center"]imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
	}
	
	else if (self.textView.textAlignment == NSTextAlignmentRight)
	{
		icon = [[UIImage imageNamed:@"text_align_right"]imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
	}
	
	[font setImage:icon forState:UIControlStateNormal];
}

#pragma mark - text color and font edit

#define pickerViewTag 11

- (void)showColorPicker:(UIButton *)button
{
	[self hidePikcerViewIfNeeded];
	[self.textView resignFirstResponder];
	
	self.colorPicker.tag = pickerViewTag;
	[self.view addSubview:self.colorPicker];
	
	NSMutableArray * array = [NSMutableArray arrayWithArray:[NSLayoutConstraint constraintsWithVisualFormat:@"|[colorPicker]|" options:(NSLayoutFormatOptions) 0 metrics:nil views:@{@"colorPicker" : self.colorPicker}]];
	self.pickerConstraints = [array arrayByAddingObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[colorPicker(keyboardViewHeight)]|" options:(NSLayoutFormatOptions) 0 metrics:@{@"keyboardViewHeight" : @(keyboardViewHeight), @"toolbarHeight" : @(toolbar_height)} views:@{@"colorPicker" : self.colorPicker}]];
	
	[self.view addConstraints:self.pickerConstraints];
	
	if (self.textView.selectedRange.length == 0) {
		NSRange range = NSMakeRange(0, self.textView.text.length);
		[self.textView setSelectedRange:range];
	}
}

- (void)showFontPicker:(UIButton *)button
{
	[self hidePikcerViewIfNeeded];
	[self.textView resignFirstResponder];
	
	self.fontPicker.tag = pickerViewTag;
	[self.view addSubview:self.fontPicker];
	
	NSMutableArray * array = [NSMutableArray arrayWithArray:[NSLayoutConstraint constraintsWithVisualFormat:@"|[fontPicker]|" options:(NSLayoutFormatOptions) 0 metrics:nil views:@{@"fontPicker" : self.fontPicker}]];
	self.pickerConstraints = [array arrayByAddingObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[fontPicker(keyboardViewHeight)]|" options:0 metrics:@{@"keyboardViewHeight":@(keyboardViewHeight),@"toolbarHeight":@(toolbar_height)} views:@{@"fontPicker":self.fontPicker}]];
	
	[self.view addConstraints:self.pickerConstraints];
	
	if (self.textView.selectedRange.length == 0) {
		NSRange range = NSMakeRange(0, self.textView.text.length);
		[self.textView setSelectedRange:range];
	}
}

- (void)showTextConfigure:(WODButton *)button
{
	[self hidePikcerViewIfNeeded];
	[self.textView resignFirstResponder];
	
	self.fontPicker.tag = pickerViewTag;
	[self.view addSubview:self.configurePicker];
	
	NSMutableArray * array = [NSMutableArray arrayWithArray:[NSLayoutConstraint constraintsWithVisualFormat:@"|[picker]|" options:(NSLayoutFormatOptions) 0 metrics:nil views:@{@"picker" : self.configurePicker}]];
	self.pickerConstraints = [array arrayByAddingObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[picker(keyboardViewHeight)]|" options:0 metrics:@{@"keyboardViewHeight":@(keyboardViewHeight),@"toolbarHeight":@(toolbar_height)} views:@{@"picker":self.configurePicker}]];
	
	[self.view addConstraints:self.pickerConstraints];
}

#pragma mark - color and font and text configure picker delegate

- (void)didFinishPickingColor:(UIColor *)color picker:(WODColorPicker *)colorPicker
{
	if (!color)
		return;
		
	self.currentColor = color;
	
	[self applyTextInputAttrs];
	[self updateToolbarColorButton];
	
	NSRange range;
	if (self.textView.selectedRange.length > 0)
	{
		range = self.textView.selectedRange;
	}
	
	NSMutableAttributedString * mutableAttrString = [[NSMutableAttributedString alloc] initWithAttributedString:self.textView.attributedText];
	
	[mutableAttrString removeAttribute:NSForegroundColorAttributeName range:self.textView.selectedRange];
	[mutableAttrString addAttribute:NSForegroundColorAttributeName value:self.currentColor range:self.textView.selectedRange];
	
	[mutableAttrString removeAttribute:NSBackgroundColorAttributeName range:self.textView.selectedRange];
	[mutableAttrString addAttribute:NSBackgroundColorAttributeName value:COLOR_SELECTION range:self.textView.selectedRange];
	
	[self.textView setAttributedText:mutableAttrString];
	self.textView.selectedRange = range;
}

- (void)fontSizeSteperValueChanged:(UIStepper *)steper
{
	if (self.textView.selectedRange.length == 0) {
		NSRange range = NSMakeRange(0, self.textView.text.length);
		[self.textView setSelectedRange:range];
	}
	
	self.fontPicker.currentFontSize = (NSInteger) steper.value;
	UIFont * newFont = [UIFont fontWithName:self.fontPicker.currentFontName size:(CGFloat) steper.value];
	
	[self applyNewFont:newFont hasSelectionBG:YES];
}

- (void)applyNewFont:(UIFont *)font hasSelectionBG:(BOOL)ifHasSelectionBG;
{
	if (!font)
		return;
	
	self.currentFont = font;
	
	[self applyTextInputAttrs];
	[self updateToolbarFontButton];
	
	if (self.textView.selectedRange.length > 0)
	{
		NSRange range = self.textView.selectedRange;
		NSMutableAttributedString * mutableAttrString = [[NSMutableAttributedString alloc] initWithAttributedString:self.textView.attributedText];
		
		[mutableAttrString removeAttribute:NSFontAttributeName range:self.textView.selectedRange];
		[mutableAttrString addAttribute:NSFontAttributeName value:self.currentFont range:self.textView.selectedRange];
		
		if (!ifHasSelectionBG)
		{
			[mutableAttrString removeAttribute:NSBackgroundColorAttributeName range:self.textView.selectedRange];
			[mutableAttrString addAttribute:NSBackgroundColorAttributeName value:COLOR_SELECTION range:self.textView.selectedRange];
		}
		
		[self.textView setAttributedText:mutableAttrString];
		self.textView.selectedRange = range;
	}
}

- (void)didFinishPickingFont:(UIFont *)font picker:(WODFontPicker *)colorPicker
{
	[self applyNewFont:font hasSelectionBG:NO];
}

- (void)applyTextInputAttrs
{
	if (self.currentFont && self.currentColor)
		self.textView.typingAttributes = @{NSFontAttributeName:self.currentFont,NSForegroundColorAttributeName:self.currentColor};
}

- (void)didFinishTextConfigureAlignment:(NSTextAlignment)alignment configureView:(WODTextConfigureView *)configureView
{
	self.textView.textAlignment = alignment;
	
	[self updateToolbarTextAlignmentButton];
}

- (void)hidePikcerViewIfNeeded
{
	[[self.view viewWithTag:pickerViewTag]removeFromSuperview];
	if(self.pickerConstraints)
	{
//		[self.view removeConstraints:self.pickerConstraints];
	}
}


#pragma mark - getter

- (UITextView *)textView
{
    if (!_textView)
    {
        _textView = [[UITextView alloc] initWithFrame:self.view.bounds];
        self.textView.delegate = self;
        self.textView.allowsEditingTextAttributes = YES;
        [self.textView setKeyboardAppearance:UIKeyboardAppearanceLight];
        self.textView.backgroundColor = color_black;
        self.textView.attributedText = [NSAttributedString new];
        self.textView.autocorrectionType = UITextAutocorrectionTypeNo;
        [self.textView setTextAlignment:NSTextAlignmentLeft];
        self.textView.contentInset = UIEdgeInsetsMake(10, 0, 0, 0);
    }
    
    return _textView;
}

- (WODColorPicker *)colorPicker
{
    if (_colorPicker == nil)
    {
        _colorPicker = [WODColorPicker new];
        _colorPicker.translatesAutoresizingMaskIntoConstraints = NO;
        _colorPicker.delegate = self;
    }
    return _colorPicker;
}

- (WODFontPicker *)fontPicker
{
    if (_fontPicker == nil)
    {
        _fontPicker = [WODFontPicker new];
        _fontPicker.translatesAutoresizingMaskIntoConstraints = NO;
        _fontPicker.delegate = self;
        [_fontPicker setTextView: self.textView];
        [_fontPicker setupSelectedValues];
    }
    return _fontPicker;
}

- (WODTextConfigureView *)configurePicker
{
    if (!_configurePicker)
    {
        _configurePicker = [WODTextConfigureView new];
        _configurePicker.translatesAutoresizingMaskIntoConstraints = NO;
        _configurePicker.delegate = self;
    }
    return _configurePicker;
}

- (UIView *)toolbar
{
    if (_toolbar == nil)
    {
        _toolbar = [UIView new];
        self.toolbar.backgroundColor = color_gray;
        [self.toolbar roundCorner:4];
        self.toolbar.frame = CGRectMake(0, 0, self.view.viewWidth, toolbar_height);
        [self.toolbar align:ViewAlignmentBottomLeft relativeToPoint:CGPointMake(0, keyboardViewHeight)];
        
        self.currentColor = [UIColor whiteColor];
        
        WODButton * color = [[WODButton alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
        [color align:ViewAlignmentTopLeft relativeToPoint:CGPointMake(10, 5)];
        color.tag = colorButtonTag;
        [color setBackgroundColor:self.currentColor];
        color.style = WODButtonStyleRoundCorner;
        [color addTarget:self action:@selector(showColorPicker:) forControlEvents:UIControlEventTouchUpInside];
        [self.toolbar addSubview:color];
        
        WODButton * font = [[WODButton alloc]initWithFrame:CGRectMake(color.viewRightEdge + 10, 5, 100, 30)];
        font.tag = fontButtonTag;
        [font setBackgroundImage:[UIImage squareImageWithColor:color_black andSize:font.viewSize] forState:UIControlStateNormal];
        font.style = WODButtonStyleRoundCorner;
        [font setTitle:[NSString stringWithFormat:@"Abc %.0f",self.currentFont.pointSize] forState:UIControlStateNormal];
        font.titleLabel.font = [UIFont fontWithName:self.currentFont.fontName size:16];
        [font addTarget:self action:@selector(showFontPicker:) forControlEvents:UIControlEventTouchUpInside];
        [self.toolbar addSubview:font];
        
        WODButton * textConfigure = [[WODButton alloc]initWithFrame:CGRectMake(0, 5, 40, 30)];
        textConfigure.tag = textConfigureButtonTag;
        [textConfigure setBackgroundImage:[UIImage squareImageWithColor:color_black andSize:font.viewSize] forState:UIControlStateNormal];
        [textConfigure align:ViewAlignmentTopLeft relativeToPoint:CGPointMake(font.viewRightEdge + 10, 5)];
        textConfigure.style = WODButtonStyleRoundCorner;
        [textConfigure addTarget:self action:@selector(showTextConfigure:) forControlEvents:UIControlEventTouchUpInside];
        [self.toolbar addSubview:textConfigure];
        [self updateToolbarTextAlignmentButton];
        
        UIStepper *fontSizeSteper = [UIStepper new];
        [fontSizeSteper align:ViewAlignmentTopLeft relativeToPoint:CGPointMake(textConfigure.viewRightEdge + 10, 5)];
        fontSizeSteper.minimumValue = 10;
        fontSizeSteper.maximumValue = 1000;
        fontSizeSteper.value = self.fontPicker.currentFontSize;
        fontSizeSteper.stepValue = 1;
        fontSizeSteper.autorepeat = YES;
        fontSizeSteper.tintColor = color_white;
        fontSizeSteper.backgroundColor = color_black;
        fontSizeSteper.layer.cornerRadius = 10;
        fontSizeSteper.layer.masksToBounds = YES;
        [fontSizeSteper setBackgroundImage:self.emptyImageForSteper forState:UIControlStateNormal];
        [fontSizeSteper setBackgroundImage:self.emptyImageForSteper forState:UIControlStateHighlighted];
        [fontSizeSteper setDividerImage:self.emptyImageForSteper forLeftSegmentState:UIControlStateNormal rightSegmentState:UIControlStateNormal];
        [fontSizeSteper setDividerImage:self.emptyImageForSteperHighlited forLeftSegmentState:UIControlStateHighlighted rightSegmentState:UIControlStateHighlighted];
        [fontSizeSteper setDecrementImage:[UIImage imageNamed:@"font_size_decrease"] forState:UIControlStateNormal];
        [fontSizeSteper setIncrementImage:[UIImage imageNamed:@"font_size_increase"] forState:UIControlStateNormal];
        [fontSizeSteper addTarget:self action:@selector(fontSizeSteperValueChanged:) forControlEvents:UIControlEventValueChanged];
        [self.toolbar addSubview:fontSizeSteper];
    }
    return _toolbar;
}

- (UIImage *)emptyImageForSteper
{
    UIGraphicsBeginImageContext(CGSizeMake(1, 1));
    CGContextRef context = UIGraphicsGetCurrentContext();
    UIColor * color = color_black;
    CGContextSetFillColorWithColor(context, color.CGColor);
    CGContextFillRect(context, CGRectMake(0, 0, 1, 1));
    UIImage * image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

- (UIImage *)emptyImageForSteperHighlited
{
    UIGraphicsBeginImageContext(CGSizeMake(1, 1));
    CGContextRef context = UIGraphicsGetCurrentContext();
    UIColor * color = color_white;
    CGContextSetFillColorWithColor(context, color.CGColor);
    CGContextFillRect(context, CGRectMake(0, 0, 1, 1));
    UIImage * image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}
@end
