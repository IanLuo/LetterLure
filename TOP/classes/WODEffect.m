//
//  WODEffect.m
//  TOP
//
//  Created by ianluo on 13-12-13.
//  Copyright (c) 2013年 WOD. All rights reserved.
//

#import "WODEffect.h"
#import "WODSystemPatternGenerator.h"
#import "WODEffectReader.h"
#import "WODEffectPackageManager.h"

#pragma mark - type def
typedef enum
{
	PatternTypeGeneric,
	PatternTypeImage,
}PatternType;

#define fillPattern 10
#define strokePattern 11

#pragma mark - private objedt : WODEffect_Pattern

@interface WODEffect_Pattern : NSObject

@property (nonatomic, assign) PatternType patternType;
@property (nonatomic, assign) CGSize size;
@property (nonatomic, strong) NSString * imagePatternPath;
@property (nonatomic, strong) NSString * systemPatternKey;
@property (nonatomic, assign) CGFloat patternAlpha;
@property (nonatomic, assign) BOOL isStencil;
@property (nonatomic, strong) NSNumber * renderScale;//used for full size render

@end


@implementation WODEffect_Pattern
@end

#pragma mark - private objedt : WODEffect_Gradient

typedef enum
{
	GradientTypeLine = 0,
	GradientTypeRadial,
}GradientType;

@interface WODEffect_Gradient : NSObject

@property (nonatomic, strong) NSArray * colorArray;
@property (nonatomic, strong) NSArray * locationArray;
@property (nonatomic, assign)CGFloat lineGradientAngle;
@property (nonatomic, assign)CGPoint radialGradientCenter1Percentage;
@property (nonatomic, assign)CGFloat radialGradientRadius1Percentage;
@property (nonatomic, assign)CGPoint radialGradientCenter2Percentage;
@property (nonatomic, assign)CGFloat radialGradientRadius2Percentage;
@property (nonatomic, assign)NSInteger blendMode;

@property (nonatomic, assign) GradientType gradientType;

@end

@implementation WODEffect_Gradient
@end

#pragma mark - Implementation

@interface WODEffect()

@property (nonatomic, strong) NSDictionary * effectComfigureData;

@property (nonatomic, strong)NSMutableArray * patternTypes;

@property (nonatomic, assign) float scale;

//this scale is the ration of image size with the windowsize, which eaquals to the render scale in text view
@property (nonatomic, assign) float renderScale;

@end

@implementation WODEffect

- (NSMutableArray *)patternTypes
{
	if (!_patternTypes)
	{
		_patternTypes = [NSMutableArray array];
	}
	return _patternTypes;
}

- (id)init
{
	self = [super init];
	if (self)
	{
		self.scale = [UIScreen mainScreen].scale;
	}
	return self;
}

- (id)initWithXMLFilePath:(NSString *)xmlFilePath
{
	self = [self init];
	if (self)
	{
		self.effectXMLFilePath = xmlFilePath;
		
	}
	return self;
}

- (void)dealloc
{
	[self clearCache];
}

#define cacheFill @"fillCache.png"
#define cacheStroke @"strokeCache.png"
#define cachePath

- (void)clearCache
{
	NSFileManager * fm = [NSFileManager defaultManager];
	NSError * error;
	if ([fm fileExistsAtPath:[NSTemporaryDirectory() stringByAppendingFormat:@"%d.png",fillPattern]])
		[fm removeItemAtPath:[NSTemporaryDirectory() stringByAppendingFormat:@"%d.png",fillPattern] error:&error];

	if (error)
		NSLog(@"faile to delete fill patter: %@",error);
#ifdef DEBUGMODE
	else
		NSLog(@"fill pattern cleared");
#endif
	
	error = nil;
		
	if ([fm fileExistsAtPath:[NSTemporaryDirectory() stringByAppendingFormat:@"%d.png",strokePattern]])
		[fm removeItemAtPath:[NSTemporaryDirectory() stringByAppendingFormat:@"%d.png",strokePattern] error:&error];

	if (error)
		NSLog(@"faile to delete stroke patter: %@",error);
#ifdef DEBUGMODE
	else
		NSLog(@"stroke pattern cleared");
#endif
}

- (void)addCache:(CGImageRef)image WithType:(int)type
{
	NSString * path = [NSTemporaryDirectory() stringByAppendingFormat:@"%d.png",type];

	/*BOOL result =*/ [UIImagePNGRepresentation([UIImage imageWithCGImage:image]) writeToFile:path atomically:NO];
	
//	NSLog(@"%@ to save %@ cache file",result == YES ? @"sucess" : @"fail", type == fillPattern ? @"fill pattern" : @"stroke pattern");
}

- (CGImageRef)getCachedImageFor:(int)type
{
	NSString * path = [NSTemporaryDirectory() stringByAppendingFormat:@"%d.png",type];
	
	if ([[NSFileManager defaultManager] fileExistsAtPath:path])
	{
		return [UIImage imageWithContentsOfFile:path].CGImage;
	}
	else
	{
		return NULL;
	}
}

- (void)prepare:(void(^)(void))complte
{
	[[WODEffectReader new] readEffect:self.effectXMLFilePath complete:^(NSDictionary *result)
	 {
		 self.effectComfigureData = result;
		 
		 if ([self.effectComfigureData objectForKey:kPatternFillPatterns])
			 self.hasPattern = YES;
			 
		 if ([self.effectComfigureData objectForKey:kGradient])
			 self.hasGradient = YES;
			 
		 if ([self.effectComfigureData objectForKey:kPatternStrokePatterns])
			 self.hasStrokePattern = YES;
			 
		 if ([self.effectComfigureData objectForKey:kStrokeGradient])
			 self.hasStrokGradient = YES;
		 
		 complte();
	 }];
}

- (void)setRenderSize:(CGSize)renderSize
{
	if (!CGSizeEqualToSize(_renderSize, renderSize))
	{
		[self clearCache];
	}
	
	_renderSize = renderSize;
}

#pragma mark - textview effect delegates

- (CGFloat)fillPatternAlpha
{
	if (!_fillPatternAlpha && [self.effectComfigureData objectForKey:kPatternFillPatternAlpha])
	{
		_fillPatternAlpha = [[self.effectComfigureData objectForKey:kPatternFillPatternAlpha]floatValue];
	}
	return _fillPatternAlpha;
}

- (CGFloat)strokePatternAlpha
{
	if (!_strokePatternAlpha && [self.effectComfigureData objectForKey:kPatternStrokePatternAlpha])
	{
		_strokePatternAlpha = [[self.effectComfigureData objectForKey:kPatternStrokePatternAlpha]floatValue];
	}
	return _strokePatternAlpha;
}

- (WODEffect_Gradient *)gradient
{
	NSDictionary * gradientData = [self.effectComfigureData objectForKey:kGradient];
	if (!_gradient && gradientData)
	{
		NSArray * gradientValues = [gradientData objectForKey:kGradientColorArray];
		
		NSMutableArray * colors = [NSMutableArray array];
		NSMutableArray * locations = [NSMutableArray array];
			
		NSDictionary * value;
		float r,g,b,a,l;
		for (int i = 0; i < gradientValues.count; i++)
		{
			value = gradientValues[i];
			r = [[value objectForKey:kGradientRed]floatValue]/256;
			g = [[value objectForKey:kGradientGreen]floatValue]/256;
			b = [[value objectForKey:kGradientBlue]floatValue]/256;
			a = [[value objectForKey:kGradientAlpha]floatValue];
			
			l = [[value objectForKey:kGradientLocation]floatValue];
			
			[colors addObject:(id)[UIColor colorWithRed:r green:g blue:b alpha:a].CGColor];
			[locations addObject:@(l)];
		}
				
		_gradient = [WODEffect_Gradient new];
		_gradient.colorArray = [NSArray arrayWithArray:colors];
		_gradient.locationArray = [NSArray arrayWithArray:locations];
		_gradient.gradientType = [[gradientData objectForKey:kGradientType]floatValue];
		_gradient.blendMode = [[gradientData objectForKey:kGradientBlendMode]intValue];
		
		if (_gradient.gradientType == GradientTypeLine)
		{
			_gradient.lineGradientAngle = [[gradientData objectForKey:kGradientLineAttrAngle]floatValue];
		}
		
		if (_gradient.gradientType == GradientTypeRadial)
		{
			_gradient.radialGradientCenter1Percentage = CGPointMake([[gradientData objectForKey:kGradientRadialAttrCenter1XPercentage]floatValue], [[gradientData objectForKey:kGradientRadialAttrCenter1YPercentage]floatValue]);
			_gradient.radialGradientCenter2Percentage = CGPointMake([[gradientData objectForKey:kGradientRadialAttrCenter2XPercentage]floatValue], [[gradientData objectForKey:kGradientRadialAttrCenter2YPercentage]floatValue]);
			_gradient.radialGradientRadius1Percentage = [[gradientData objectForKey:kGradientRadialAttrRadialGradientRadius1Percentage] floatValue];
			_gradient.radialGradientRadius2Percentage = [[gradientData objectForKey:kGradientRadialAttrRadialGradientRadius2Percentage] floatValue];
		}
		
	}
	return _gradient;
}

- (WODEffect_Gradient *)strokeGradient
{
	NSDictionary * strokeGradientData = [self.effectComfigureData objectForKey:kStrokeGradient];
	if (!_strokeGradient && strokeGradientData)
	{
		NSArray * gradientValues = [strokeGradientData objectForKey:kStrokeGradientColorArray];
		
		NSMutableArray * colors = [NSMutableArray array];
		NSMutableArray * locations = [NSMutableArray array];
		
		NSDictionary * value;
		float r,g,b,a,l;
		for (int i = 0; i < gradientValues.count; i++)
		{
			value = gradientValues[i];
			r = [[value objectForKey:kStrokeGradientRed]floatValue]/256;
			g = [[value objectForKey:kStrokeGradientGreen]floatValue]/256;
			b = [[value objectForKey:kStrokeGradientBlue]floatValue]/256;
			a = [[value objectForKey:kStrokeGradientAlpha]floatValue];
			
			l = [[value objectForKey:kStrokeGradientLocation]floatValue];
			
			[colors addObject:(id)[UIColor colorWithRed:r green:g blue:b alpha:a].CGColor];
			[locations addObject:@(l)];
		}
		
		_strokeGradient = [WODEffect_Gradient new];
		_strokeGradient.colorArray = [NSArray arrayWithArray:colors];
		_strokeGradient.locationArray = [NSArray arrayWithArray:locations];
		_strokeGradient.gradientType = [[strokeGradientData objectForKey:kStrokeGradientType]floatValue];
		_strokeGradient.blendMode = [[strokeGradientData objectForKey:kGradientBlendMode]intValue];
		
		if (_strokeGradient.gradientType == GradientTypeLine)
		{
			_strokeGradient.lineGradientAngle = [[strokeGradientData objectForKey:kStrokeGradientLineAttrAngle]floatValue];
		}
		
		if (_strokeGradient.gradientType == GradientTypeRadial)
		{
			_strokeGradient.radialGradientCenter1Percentage = CGPointMake([[strokeGradientData objectForKey:kStrokeGradientRadialAttrCenter1XPercentage]floatValue], [[strokeGradientData objectForKey:kStrokeGradientRadialAttrCenter1YPercentage]floatValue]);
			_strokeGradient.radialGradientCenter2Percentage = CGPointMake([[strokeGradientData objectForKey:kStrokeGradientRadialAttrCenter2XPercentage]floatValue], [[strokeGradientData objectForKey:kStrokeGradientRadialAttrCenter2YPercentage]floatValue]);
			_strokeGradient.radialGradientRadius1Percentage = [[strokeGradientData objectForKey:kStrokeGradientRadialAttrRadialGradientRadius1Percentage] floatValue];
			_strokeGradient.radialGradientRadius2Percentage = [[strokeGradientData objectForKey:kStrokeGradientRadialAttrRadialGradientRadius2Percentage] floatValue];
		}
		
	}
	return _strokeGradient;
}

- (NSArray *)fillPatterns
{
	if (!_fillPatterns && [self.effectComfigureData objectForKey:kPatternFillPatterns])
	{
		NSArray * patternDataArray = [self.effectComfigureData objectForKey:kPatternFillPatterns];
		
		NSMutableArray * patternArray = [NSMutableArray array];

		for (NSDictionary * data in patternDataArray)
		{
			WODEffect_Pattern * pattern = [WODEffect_Pattern new];
			pattern.patternType = [[data objectForKey:kPatternType]floatValue];
			pattern.size = CGSizeMake([[data objectForKey:kPatternWidth]floatValue], [[data objectForKey:kPatternHeight]floatValue]);
			pattern.patternAlpha = [[data objectForKey:kPatternAlpha]floatValue];
			pattern.isStencil = [[data objectForKey:kPatternIsStencil]boolValue];
			
			switch (pattern.patternType)
			{
				case PatternTypeGeneric:
					pattern.systemPatternKey = [data objectForKey:kPatternGeneratorKey];
					break;
				case PatternTypeImage:
				{
					NSString * fileName = [data objectForKey:kPatternImagePath];
					NSString * path = [[self.effectXMLFilePath stringByDeletingLastPathComponent] stringByAppendingFormat:@"/%@",fileName];
					
					if (![[NSFileManager defaultManager]fileExistsAtPath:path])
					{
						path = [[WODEffectPackageManager new] pathForSystemTexture:fileName];
					}
					
					pattern.imagePatternPath = path;
				
					break;
				}
			}
			
			[patternArray addObject:pattern];
		}
		_fillPatterns = [NSArray arrayWithArray:patternArray];
	}
	return _fillPatterns;
}

- (CGFloat)strokeWidthPercentage
{
	if (!_strokeWidthPercentage && [self.effectComfigureData objectForKey:kStrokeWidthPercent])
	{
		_strokeWidthPercentage = [[self.effectComfigureData objectForKey:kStrokeWidthPercent] floatValue];
	}
	return _strokeWidthPercentage;
}

- (NSArray *)strokePatterns
{
	if (!_strokePatterns && [self.effectComfigureData objectForKey:kPatternStrokePatterns])
	{
		NSArray * patternDataArray = [self.effectComfigureData objectForKey:kPatternStrokePatterns];
		
		NSMutableArray * patternArray = [NSMutableArray array];

		for (NSDictionary * data in patternDataArray)
		{
			WODEffect_Pattern * pattern = [WODEffect_Pattern new];
			pattern.patternType = [[data objectForKey:kPatternType]floatValue];
			pattern.size = CGSizeMake([[data objectForKey:kPatternWidth]floatValue], [[data objectForKey:kPatternHeight]floatValue]);
			pattern.patternAlpha = [[data objectForKey:kPatternAlpha]floatValue];
			pattern.isStencil = [[data objectForKey:kPatternIsStencil]boolValue];
			
			switch (pattern.patternType)
			{
				case PatternTypeGeneric:
					pattern.systemPatternKey = [data objectForKey:kPatternGeneratorKey];
					break;
				case PatternTypeImage:
				{
					NSString * fileName = [data objectForKey:kPatternImagePath];
					NSString * path = [[self.effectXMLFilePath stringByDeletingLastPathComponent] stringByAppendingFormat:@"/%@",fileName];
					
					if (![[NSFileManager defaultManager]fileExistsAtPath:path])
					{
						path = [[WODEffectPackageManager new] pathForSystemTexture:fileName];
					}
					
					pattern.imagePatternPath = path;
					
					break;
				}
			}
			
			[patternArray addObject:pattern];
		}
		_strokePatterns = [NSArray arrayWithArray:patternArray];
	}
	return _strokePatterns;
}

- (CGColorRef)strokeColor
{
	if(!_strokeColor && [self.effectComfigureData objectForKey:kStrokeColor])
	{
		_strokeColor = [(UIColor *)[self.effectComfigureData objectForKey:kStrokeColor] CGColor];
	}
	return _strokeColor;
}

- (CGColorRef)shadowColor
{
	if(!_shadowColor && [self.effectComfigureData objectForKey:kShadowColor])
	{
		_shadowColor = [(UIColor *)[self.effectComfigureData objectForKey:kShadowColor] CGColor];
	}
	return _shadowColor;
}

- (CGSize)shadowOffset
{
	if(CGSizeEqualToSize(_shadowOffset, CGSizeZero) && [self.effectComfigureData objectForKey:kShadowOffset])
	{
		_shadowOffset = [[self.effectComfigureData objectForKey:kShadowOffset] CGSizeValue];
	}
	return _shadowOffset;
}

- (CGFloat)shadowBlur
{
	if(!_shadowBlur && [self.effectComfigureData objectForKey:kShadowBlur])
	{
		_shadowBlur = [[self.effectComfigureData objectForKey:kShadowBlur] floatValue];
	}
	return _shadowBlur;
}

- (CGBlendMode)getBlendModeForGradient:(NSInteger)blendMode
{
	return (CGBlendMode)(kCGBlendModeNormal + blendMode);
}

#pragma mark - pattern and gradiant drawing

- (CGPatternRef)createFillPattern:(float)renderScale
{
	self.renderScale = self.scale * renderScale;
	
	CGPatternCallbacks pCallbacks;
	pCallbacks.version = 0;
	pCallbacks.drawPattern = &drawFillPattern;
	pCallbacks.releaseInfo = &releasePattern;
	
	float xStep = self.renderSize.width, yStep = self.renderSize.height;
	
	return CGPatternCreate((void *)self, CGRectMake(0, 0, xStep, yStep), CGAffineTransformIdentity, xStep, yStep, kCGPatternTilingNoDistortion, YES, &pCallbacks);
}

- (CGPatternRef)createStrokPattern:(float)renderScale
{
	self.renderScale = self.scale * renderScale;
	
	CGPatternCallbacks pCallbacks;
	pCallbacks.version = 0;
	pCallbacks.drawPattern = &drawStrokePattern;
	pCallbacks.releaseInfo = &releasePattern;
	
	float xStep = self.renderSize.width, yStep = self.renderSize.height;
	
	return CGPatternCreate((void *)self, CGRectMake(0, 0, xStep, yStep), CGAffineTransformIdentity, xStep, yStep, kCGPatternTilingNoDistortion, YES, &pCallbacks);
}

- (CGContextRef)newEffectContext
{
	CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
	float renderScaleFixed = self.renderScale == 0 ? 1 : self.renderScale;
	CGContextRef context =  CGBitmapContextCreate(NULL, self.renderSize.width * renderScaleFixed, self.renderSize.height * renderScaleFixed, 8, 0, colorSpace, (CGBitmapInfo)kCGImageAlphaPremultipliedLast);
	CGColorSpaceRelease(colorSpace);
	return context;
}

void drawFillPattern(void * info,CGContextRef context)
{
	WODEffect * self = (__bridge WODEffect *)info;
	
	NSArray * patterns = self.fillPatterns;
	[patterns setValue:@(self.renderScale) forKey:@"renderScale"];
	WODEffect_Gradient * gradient = self.gradient;
	
	drawPattern(self,patterns,gradient,context,fillPattern);
}

void drawStrokePattern(void * info,CGContextRef context)
{
	if (!info)
		return;
		
	WODEffect * self = (__bridge WODEffect *)info;
	
	NSArray * patterns = self.strokePatterns;
	WODEffect_Gradient * gradient = self.strokeGradient;
	
	drawPattern(self,patterns,gradient,context,strokePattern);
}

void drawPattern(WODEffect * self, NSArray * patterns,WODEffect_Gradient * gradient,CGContextRef context,int type)
{
	CGRect bounds = CGRectMake(0, 0, self.renderSize.width * self.renderScale, self.renderSize.height * self.renderScale);
	
	CGImageRef cache = [self getCachedImageFor:type];
		
	if (cache == NULL)
	{
		CGContextRef tempContext = [self newEffectContext];
#pragma mark - draw patterns
		for (WODEffect_Pattern * patternObj in patterns)
		{
			CGPatternCallbacks pCallbacks;
			pCallbacks.version = 0;
			pCallbacks.drawPattern = &drawSubPattern;
			pCallbacks.releaseInfo = NULL;
			
			CGColorSpaceRef baseSpace = NULL;
			
			// don't know how to make the stencil pattern work
//			if (patternObj.isStencil)
//			{
//				baseSpace = CGColorSpaceCreateDeviceCMYK();
//			}
//			
//			bool isColored = patternObj.isStencil ? false : true;
			
			CGColorSpaceRef  patternSpace = CGColorSpaceCreatePattern(baseSpace);
			CGContextSetFillColorSpace(tempContext, patternSpace);
			CGColorSpaceRelease (patternSpace);
			
			CGFloat alpha = patternObj.patternAlpha;
			CGRect patthernRect = bounds;
			CGPatternRef pattern = CGPatternCreate((void *)patternObj, patthernRect, CGAffineTransformIdentity, patternObj.size.width * self.renderScale, patternObj.size.height * self.renderScale, kCGPatternTilingConstantSpacing, true, &pCallbacks);
			CGContextSetFillPattern(tempContext, pattern, &alpha); // draw fill pattern
			CGContextFillRect(tempContext,patthernRect);
			CGPatternRelease(pattern);
		}
		
#pragma mark - draw gradient
		if (gradient)
		{
			//set the blend mode for gradien blending with pattern
			CGContextSetBlendMode(tempContext, [self getBlendModeForGradient:gradient.blendMode]);
			
			CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
			CGGradientRef grRef = NULL;
			
			if (gradient.locationArray)
			{
				CGFloat locatoins[gradient.locationArray.count];
				
				CFIndex i = 0;
				for (NSNumber * loc in gradient.locationArray)
				{
					locatoins[i] = [loc floatValue];
					i ++;
				}
				
				grRef = CGGradientCreateWithColors(colorSpace,  (__bridge CFArrayRef)gradient.colorArray, locatoins);
			}
			else
			{
				grRef = CGGradientCreateWithColors(colorSpace,  (__bridge CFArrayRef)gradient.colorArray, NULL);
			}
			CGColorSpaceRelease(colorSpace);
			
			float gradientWidth = self.renderSize.width * self.renderScale, gradientHeight = self.renderSize.height * self.renderScale;
			
			if (gradient.gradientType == GradientTypeLine)
			{
				CGFloat degree = gradient.lineGradientAngle * M_PI / 180;
				CGPoint center = CGPointMake(gradientWidth/2, gradientHeight/2);
				CGPoint startPoint = CGPointMake(center.x - cos (degree)*gradientWidth/2,center.y - sin(degree)*gradientHeight/2);
				CGPoint endPoint = CGPointMake(center.x + cos (degree)*gradientWidth/2,center.y + sin(degree)*gradientHeight/2);
				
//				NSLog(@"start point:%@ \n, end point: %@",NSStringFromCGPoint(startPoint),NSStringFromCGPoint(endPoint));
				
				CGContextDrawLinearGradient(tempContext, grRef, startPoint,endPoint, kCGGradientDrawsBeforeStartLocation|kCGGradientDrawsAfterEndLocation);
			}
			
			if (gradient.gradientType == GradientTypeRadial)
			{
				CGPoint startCenter = CGPointMake(gradientWidth * gradient.radialGradientCenter1Percentage.x, gradientHeight * gradient.radialGradientCenter1Percentage.y);
				
				CGPoint endCenter = CGPointMake(gradientWidth * gradient.radialGradientCenter2Percentage.x, gradientHeight * gradient.radialGradientCenter2Percentage.y);
				
				CGFloat startRadius = gradientWidth * gradient.radialGradientRadius1Percentage;
				CGFloat endRadius = gradientWidth * gradient.radialGradientRadius2Percentage;
				
				CGContextDrawRadialGradient(tempContext, grRef, startCenter, startRadius, endCenter, endRadius, kCGGradientDrawsBeforeStartLocation|kCGGradientDrawsAfterEndLocation);
			}
			if (grRef != NULL)
			{
				CGGradientRelease(grRef);
			}
		}
				
		CGImageRef patternImage = CGBitmapContextCreateImage(tempContext);
		[self addCache:patternImage WithType:type];
		CGContextDrawImage(context, CGRectMake(0, 0, self.renderSize.width, self.renderSize.height), patternImage);
		CGImageRelease(patternImage);
		CGContextRelease(tempContext);
	}
	
#ifdef DEBUGMODE
	NSLog(@"(%@,%i):pattern size:%@",[[NSString stringWithUTF8String:__FILE__]lastPathComponent],__LINE__,NSStringFromCGSize(CGSizeApplyAffineTransform(self.renderSize, CGAffineTransformMakeScale(self.renderScale, self.renderScale))));
	NSLog(@"(%@,%i):context bounding box:%@",[[NSString stringWithUTF8String:__FILE__]lastPathComponent],__LINE__,NSStringFromCGRect(CGRectApplyAffineTransform((CGRect)CGContextGetClipBoundingBox(context), CGAffineTransformMakeScale(self.renderScale, self.renderScale))));
#endif
	
	CGContextDrawImage(context, CGRectMake(0, 0, self.renderSize.width, self.renderSize.height), cache);
}

void drawSubPattern(void * info,CGContextRef context)
{
	WODEffect_Pattern * pattern = (__bridge WODEffect_Pattern *)info;
	
	if (pattern.patternType == PatternTypeGeneric)
	{
		WODSystemPatternGenerator * patternGenerator = [WODSystemPatternGenerator new];
		[patternGenerator generatePatternWithKey:pattern.systemPatternKey size:pattern.size inContext:context];
	}
	
	if (pattern.patternType == PatternTypeImage)
	{
		UIImage * image = [UIImage imageWithContentsOfFile:pattern.imagePatternPath];
		
		CGContextDrawImage(context, CGRectMake(0, 0, pattern.size.width * pattern.renderScale.floatValue, pattern.size.height * pattern.renderScale.floatValue), image.CGImage);
	}
}

static void releasePattern()
{
	
}


@end
