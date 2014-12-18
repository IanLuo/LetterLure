//
//  WODTextViewTextLayer.m
//  TOP
//
//  Created by ianluo on 14-1-3.
//  Copyright (c) 2014年 WOD. All rights reserved.
//

#import "WODTextViewTextLayerDelegate.h"
#import "WODEffect.h"
#import <CoreText/CoreText.h>

@interface WODTextViewTextLayerDelegate()

@property (nonatomic, strong)NSArray * cPositions;

@end

@implementation WODTextViewTextLayerDelegate
{
	int scaleFactor;
	float renderScale;
	
	float fullsizeRenderScale;
	BOOL isFullSizeRender;
}

- (id)init
{
	self = [super init];
	if (self)
	{
		scaleFactor = 1;
		UIScreen* screen = [UIScreen mainScreen];
		if ([screen respondsToSelector:@selector(scale)])
			scaleFactor = (int) [screen scale];
			
	}
	return self;
}

- (UIImage *)renderImage
{
	if (self.textView.needGenerateImage || [WODConstants getCachedImageForKey:self.textView.cacheKey] == nil)
	{
		CGSize suggestedSize = [self adjustRenderSize];
		
		if (self.textView.currentTypeSet == TypesetLayoutProvider)
		{
			UIGraphicsBeginImageContextWithOptions(suggestedSize, NO, 1);
			[self prepareLayout];
			[self sizeAndPositions:UIGraphicsGetCurrentContext()];
			UIGraphicsEndImageContext();
			suggestedSize = [self adjustRenderSize];
		}
		
		UIGraphicsBeginImageContextWithOptions(suggestedSize, NO, renderScale * scaleFactor);
		CGContextRef context = UIGraphicsGetCurrentContext();
		
		[self renderImageInContext:context];
		
		CGImageRef cgImage = CGBitmapContextCreateImage(context);
		UIImage * image = [UIImage imageWithCGImage:cgImage scale:scaleFactor orientation:UIImageOrientationUp];
		CGImageRelease(cgImage);
		UIGraphicsEndImageContext();
		
#ifdef DEBUGMODE
		NSLog(@"(%@,%i):image size:%@",[[NSString stringWithUTF8String:__FILE__]lastPathComponent],__LINE__,NSStringFromCGSize(CGSizeApplyAffineTransform(image.size, CGAffineTransformMakeScale(image.scale, image.scale))));
		NSLog(@"(%@,%i):textview size:%@",[[NSString stringWithUTF8String:__FILE__]lastPathComponent],__LINE__,NSStringFromCGSize(CGSizeApplyAffineTransform(suggestedSize, CGAffineTransformMakeScale(renderScale * scaleFactor, renderScale * scaleFactor))));
#endif
		
		if (!isFullSizeRender)
		{
			[WODConstants addOrUpdateImageCache:image forKey:self.textView.cacheKey];
		}
		
		self.textView.needGenerateImage = NO;
		
		return image;
	}
	else
	{
		return [WODConstants getCachedImageForKey:self.textView.cacheKey];
	}
}

- (UIImage *)renderFullSizeImage:(float)fullsizeScale
{
	fullsizeRenderScale = fullsizeScale;
	isFullSizeRender = YES;
	UIImage * image = [self renderImage];
	isFullSizeRender = NO;
	fullsizeRenderScale = 1.0;
	return image;
}

// used for size down if the image is too big
- (CGSize)adjustRenderSize
{
	CGSize suggestedSize = self.textView.bounds.size;
	
	CGSize imageSize = CGSizeApplyAffineTransform(suggestedSize, CGAffineTransformMakeScale(scaleFactor, scaleFactor));
	CGSize windowSize = CGSizeApplyAffineTransform([WODConstants currentSize], CGAffineTransformMakeScale(scaleFactor, scaleFactor));
	
	renderScale = 1.0;
	
	if (imageSize.width > windowSize.width)
	{
		renderScale = imageSize.width / windowSize.width;
	}
	
	if (imageSize.height > windowSize.height)
	{
		renderScale = MAX(renderScale, imageSize.height / windowSize.height);
	}
	
	renderScale = 1 / renderScale;
	
	if (isFullSizeRender)
	{
		renderScale *= fullsizeRenderScale;
	}
	
	return suggestedSize;
}

- (void)renderImageInContext:(CGContextRef)contextIn
{
	CGContextRef context = contextIn;
		
#ifdef DEBUGMODE
	CFAbsoluteTime beginTime = CFAbsoluteTimeGetCurrent();
#endif
	
	CFMutableAttributedStringRef attrString = CFAttributedStringCreateMutableCopy(NULL, self.textView.text.length, (__bridge CFMutableAttributedStringRef)(self.textView.text));
	
	CGContextTranslateCTM(context, 0, self.textView.bounds.size.height);
    CGContextScaleCTM(context, 1.0, -1.0);
		
	//fix the attributes of the attribute string
	for(int i = 0; i < self.textView.text.length; i++)
	{
		NSDictionary * nsAttribute = [self.textView.text attributesAtIndex:i effectiveRange:NULL];
		if ([nsAttribute.allKeys containsObject:NSForegroundColorAttributeName])
		{
			CGColorRef color = [(UIColor *)[nsAttribute objectForKey:NSForegroundColorAttributeName]CGColor];
			CFAttributedStringSetAttribute(attrString, CFRangeMake(i, 1), (__bridge CFStringRef)NSForegroundColorAttributeName, color);
		}
	}
	
#pragma mark > set look and feel
	
	if (!self.textView.hideFeatures)
	{
		if (self.textView.effectProvider)
		{
			WODEffect * effect = self.textView.effectProvider;
			effect.renderSize = self.textView.bounds.size;
			
			if (effect.strokeWidthPercentage > 0)
			{
				CGContextSetTextDrawingMode(context, kCGTextFillStroke);
			}
			
			if (effect.hasPattern || effect.hasGradient)
			{
				//remove the color for the text, which will replace the fill pattern
				for(int i = 0; i < self.textView.text.length; i++)
				{
					NSDictionary * nsAttribute = [self.textView.text attributesAtIndex:i effectiveRange:NULL];
					if ([nsAttribute.allKeys containsObject:NSForegroundColorAttributeName])
					{
						CFAttributedStringRemoveAttribute(attrString, CFRangeMake(i, 1), (__bridge CFStringRef)NSForegroundColorAttributeName);
					}
				}
				
				CGColorSpaceRef patternSpace = CGColorSpaceCreatePattern (NULL);
				CGContextSetFillColorSpace (context, patternSpace);
				CGColorSpaceRelease (patternSpace);
				
				CGFloat alpha = effect.fillPatternAlpha;
				CGPatternRef pattern = [effect createFillPattern:renderScale];
				CGContextSetFillPattern(context, pattern, &alpha);
				CGPatternRelease(pattern);
			}
			
			if (effect.hasStrokGradient || effect.hasStrokePattern)
			{
				CGColorSpaceRef patternSpace = CGColorSpaceCreatePattern (NULL);
				CGContextSetStrokeColorSpace (context, patternSpace);
				CGColorSpaceRelease (patternSpace);
				
				CGFloat alpha = effect.strokePatternAlpha;
				CGPatternRef pattern = [effect createStrokPattern:renderScale];
				CGContextSetStrokePattern(context, pattern, &alpha);
				CGPatternRelease(pattern);
			}
			else
			{
				if (effect.strokeColor)
					CGContextSetStrokeColorWithColor(context,effect.strokeColor);
			}
			
//#warning save icon for effects
//			CGContextSaveGState(context);
//			CGMutablePathRef samplePath = CGPathCreateMutable();
//			CGFloat min = MIN(self.textView.bounds.size.width,self.textView.bounds.size.height);
//			CGPathAddEllipseInRect(samplePath, NULL, CGRectMake(5, 5, min - 10, min - 10));
//			CGContextAddPath(context, samplePath);
//			CGContextSetLineWidth(context, effect.strokeWidthPercentage > 0 ? 5 : 0);
//			if (!CGSizeEqualToSize(effect.shadowOffset, CGSizeZero))
//			{
//				CGContextSetShadowWithColor(context, CGSizeMake(3.0, 3.0), 0, effect.shadowColor);
//			}
//			CGContextSetTextDrawingMode(context, kCGTextFillStroke);
//			CGContextFillPath(context);
//			CGContextAddPath(context, samplePath);
//			CGContextStrokePath(context);
//			CGImageRef image = CGBitmapContextCreateImage(context);
//			
//			float scale1 = 60/min;
//			float scale2 = 30/min;
//			[UIImagePNGRepresentation([WODConstants resizeImage:[UIImage imageWithCGImage:image] scale:scale1]) writeToFile:[NSTemporaryDirectory() stringByAppendingString:@"icon@2x.png"] atomically:NO];
//			[UIImagePNGRepresentation([WODConstants resizeImage:[UIImage imageWithCGImage:image] scale:scale2]) writeToFile:[NSTemporaryDirectory() stringByAppendingString:@"icon.png"] atomically:NO];
//			CGPathRelease(samplePath);
//			CGContextRestoreGState(context);
		}
	}
	
	
	
#pragma mark > set the text typeset with layout provider
	
	if (self.textView.currentTypeSet == TypesetLayoutProvider)
	{
//		dispatch_async(dispatch_get_main_queue(), ^{
//			self.textView.backgroundLayer.hidden = YES;
//		});
		
		CTLineRef line = CTLineCreateWithAttributedString(attrString);
		CFArrayRef runArray = CTLineGetGlyphRuns(line);
		CFIndex runcount = CFArrayGetCount(runArray);
		CFIndex index = 0;
		
		for (CFIndex i = 0;i < runcount;i++)
		{
			CTRunRef run = (CTRunRef)CFArrayGetValueAtIndex(runArray, i);
			CFIndex runGlyphCount = CTRunGetGlyphCount(run);
			
			for (CFIndex j = 0; j < runGlyphCount; j++)
			{
				if (self.cPositions.count <= index)
				{
					NSLog(@"Warning: ** Postion points is not enough");
					break;
				}
				CGContextSaveGState(context);
				
				CFDictionaryRef attributes = CTRunGetAttributes(run);
				
				//show the text stroke color and fill color if need, if the color exists, which means no fill and stroke pattern or gradient is set, otherwise they will have been removed earlier
				if(CFDictionaryGetValue(attributes, NSForegroundColorAttributeName))
				{
					CGContextSetStrokeColorWithColor(context, (CGColorRef)CFDictionaryGetValue(attributes, NSForegroundColorAttributeName));
					CGContextSetFillColorWithColor(context,(CGColorRef)CFDictionaryGetValue(attributes, NSForegroundColorAttributeName));
				}
				
				CTFontRef runFont = CFDictionaryGetValue(attributes, kCTFontAttributeName);
				CGContextSetFont(context, CTFontCopyGraphicsFont(runFont, NULL));
				CGContextSetFontSize(context, CTFontGetSize(runFont));
				
				CPosition cPosition;
				[(NSValue *)self.cPositions[index] getValue:&cPosition];
				
				// -->draw single text
				CFRange range = CFRangeMake(j, 1);
				CGGlyph glyph;
				CTRunGetGlyphs(run, range, &glyph);
				CGPoint point = cPosition.point;
				
				CGFloat ascent,descent,leading;
				CGFloat width = CTRunGetTypographicBounds(run, range, &ascent, &descent, &leading);
				
				CGAffineTransform myTextTransform =  CGAffineTransformRotate(CGAffineTransformMakeTranslation(width/2, 0),cPosition.angle);
				CGAffineTransform transform = CGAffineTransformTranslate(myTextTransform,-width/2, 0);
				CGContextSetTextMatrix (context, transform); //transform for the whole text space
				
				point = CGPointApplyAffineTransform(point, CGAffineTransformMakeRotation(-cPosition.angle)); // transform the points back to the user space
				
				//calculate the shadow offset witht the percentage and glyph size
				CGRect rect = CTRunGetImageBounds(run, context, range);
				if (self.textView.effectProvider && !self.textView.hideFeatures)
				{
					WODEffect * effect = self.textView.effectProvider;
					CGContextSetShadowWithColor(context, [self getShadowOffset:rect.size context:context], effect.shadowBlur, effect.shadowColor);
					
					if (!effect.strokeColor && !effect.hasStrokePattern && !effect.hasStrokGradient)
					{
						CGContextSetStrokeColorWithColor(context, (CGColorRef)CFDictionaryGetValue(attributes, NSForegroundColorAttributeName));
					}
				}
				
				[self handleStrokeWidth:rect.size.height context:context];
								
				CGContextShowGlyphsAtPositions(context, &glyph, &point, 1);
				
				CGContextRestoreGState(context);
				//<-- complete draw single text
				
				index++;
			}
		}
	}
#pragma mark > the text layout with a cgpath
	else
	{
		//because when using layout path, the background will be shown
//		dispatch_async(dispatch_get_main_queue(), ^{
//			self.textView.backgroundLayer.hidden = NO;
//		});
				
		//crate frame setter with the attributed string
		CTFramesetterRef framesetter = CTFramesetterCreateWithAttributedString(attrString);
		
		CGPathRef path = NULL;
		
		// if the path need to be scaled, create a new scaled new path, and keep the current path untouched, the reason is the transformation is permanetly, so if the path need to be restored later, we will need a backup.
		if (self.textView.pathScaleFactor != 1)
		{
			path = [self.textView newScaledPath];
		}
		else
		{
			path = self.textView.layoutShapPath;
		}
		
		//when the background color is set, show it
//		if (path)
//		{
//			[self.textView.backgroundLayer setFillPath:path];
//			[self.textView.backgroundLayer performSelectorOnMainThread:@selector(setNeedsDisplay) withObject:nil waitUntilDone:NO];
//		}
		
		//create the acture display frame, which contains information the lines and the glyphs will be placed, we will use that to locate each glyph in the text view's bounds.
		CTFrameRef frame = CTFramesetterCreateFrame(framesetter, CFRangeMake(0, 0), path, NULL);
		
		if (self.textView.shouldShowPath)
		{
			CGContextSaveGState(context);
			UIColor * color = color_black;
			CGContextSetStrokeColorWithColor(context, color.CGColor);
			CGContextAddPath(context, path);
			CGContextStrokePath(context);
			CGContextRestoreGState(context);
		}
				 
		 //get all lined with the CTFrameRef, which is calculated by the system
		 CFArrayRef lines = CTFrameGetLines(frame);

		
		//This step will give us the actural position of the first glyph of each lines in the frame, we use that to place the first glyph of tach line, and put other glyphs behind one after another.
		CGPoint origins[CFArrayGetCount(lines)];
		CTFrameGetLineOrigins(frame, CFRangeMake(0, 0), origins);
		
		int lineIndex = 0;
		
		//first loop is for lines, second is for each glyph runs in that line, and the thried loop is for all glyphs in each glyph run, and atrual disply is happend there.
		for (int i = 0; i < CFArrayGetCount(lines); i++)
		{
			CFArrayRef runs = CTLineGetGlyphRuns(CFArrayGetValueAtIndex(lines, i));
			
			float glyphOffset = origins[i].x;
			
			//loop for each glyphs runs
			for (int j = 0; j < CFArrayGetCount(runs); j++)
			{
				CTRunRef run = CFArrayGetValueAtIndex(runs, j);
				
				//loop for each glyph in one glyph run, and show that glyph
				for (int k = 0; k < CTRunGetGlyphCount(run);k++)
				{
					CGContextSaveGState(context);
					
					CFDictionaryRef attributes = CTRunGetAttributes(run);
					
					//show the text stroke color and fill color if need, if the color exists, which means no fill and stroke pattern or gradient is set, otherwise they will have been removed earlier
					if(CFDictionaryGetValue(attributes, NSForegroundColorAttributeName))
					{
						CGContextSetStrokeColorWithColor(context, (CGColorRef)CFDictionaryGetValue(attributes, NSForegroundColorAttributeName));
						CGContextSetFillColorWithColor(context,(CGColorRef)CFDictionaryGetValue(attributes, NSForegroundColorAttributeName));
					}
					
					// set the glyph's information
					CTFontRef runFont = CFDictionaryGetValue(attributes, kCTFontAttributeName);
					CGContextSetFont(context, CTFontCopyGraphicsFont(runFont, NULL));
					CGContextSetFontSize(context, CTFontGetSize(runFont));
										
					//calculate the glyphs size and use it later.
					CFRange glyphRange = CFRangeMake(k, 1);
					CGGlyph glyph;
					CTRunGetGlyphs(run, glyphRange, &glyph);
					CGRect rect = CTRunGetImageBounds(run, context, glyphRange);
					CGFloat ascent, descent, leading;
					CGFloat width = CTRunGetTypographicBounds(run, glyphRange, &ascent, &descent, &leading);
										
					CGPoint position = CGPointMake(glyphOffset, origins[i].y);
										
					glyphOffset += width;
					
					if (self.textView.effectProvider && !self.textView.hideFeatures)
					{
						WODEffect * effect = self.textView.effectProvider;
						CGContextSetShadowWithColor(context, [self getShadowOffset:rect.size context:context], effect.shadowBlur, effect.shadowColor);
					}
					
					//set the stroke width based on the glyph's height, so different size of text will show different width of stroke, to avoid when text it too small, the storke take up too much space
					[self handleStrokeWidth:rect.size.height context:context];
					
					CGContextShowGlyphsAtPositions(context, &glyph, &position, 1);
					CGContextRestoreGState(context);
				}
			}
			lineIndex ++;
		}
				
		CFRelease(attrString);
		CFRelease(frame);
		CFRelease(framesetter);
	}
	
#ifdef DEBUGMODE
	NSLog(@"%.0f ms",(CFAbsoluteTimeGetCurrent() - beginTime)*1000);
#endif
	
	if(self.textView.effectProvider)
	{
		[(WODEffect *)self.textView.effectProvider clearCache];
	}
}

- (void)handleStrokeWidth:(float)glyphHeight context:(CGContextRef)context
{
	WODEffect * effect = self.textView.effectProvider;
	if (effect.strokeWidthPercentage)
	{
		NSAssert(effect.strokeWidthPercentage < 1, @"stroke width much a persect, range is: [0,1]");
		
		CGContextSetLineWidth(context, effect.strokeWidthPercentage * glyphHeight);
	}
}

- (CGSize)getShadowOffset:(CGSize)glyphSize context:(CGContextRef)context
{
	WODEffect * effect = self.textView.effectProvider;
	if (!CGSizeEqualToSize(effect.shadowOffset, CGSizeZero))
	{
		NSAssert(effect.shadowOffset.width < 1, @"shadow width much a persect, range is: [0,1]");
		NSAssert(effect.shadowOffset.height < 1, @"shadow height much a persect, range is: [0,1]");
		
		return CGSizeMake(effect.shadowOffset.width * glyphSize.width, effect.shadowOffset.height * glyphSize.height);
	}
	return CGSizeZero;
}


- (void)prepareLayout
{
	//other
	
	if ([self.textView.layoutProvider respondsToSelector:@selector(spaceSize)])
	{
		self.textView.spaceSize = [self.textView.layoutProvider spaceSize];
	}
}

- (void)sizeAndPositions:(CGContextRef)context
{
	CTLineRef line = CTLineCreateWithAttributedString((__bridge CFMutableAttributedStringRef) self.textView.text);
	CFArrayRef runArray = CTLineGetGlyphRuns(line);
	
	if ([self.textView.layoutProvider respondsToSelector:@selector(textview:positionForCharacters:glyphInfo:)])
	{
		NSMutableArray * glyphsMetrix = [NSMutableArray array];
		NSMutableArray * glyphsBounds = [NSMutableArray array];
		
		CFIndex index = 0;
		for (int i = 0; i < CFArrayGetCount(runArray); i ++)
		{
			CTRunRef run = CFArrayGetValueAtIndex(runArray,i);
			CFIndex glyphCount = CTRunGetGlyphCount(run);
			
			for (int j = 0; j < glyphCount; j ++)
			{
				CFRange glyphRange = CFRangeMake(j, 1);
				CGRect glyphMetrix = CTRunGetImageBounds(run, context, glyphRange);
				
				if (glyphMetrix.size.width == 0)
					glyphMetrix.size.width = self.textView.spaceSize;
				
				CGFloat ascent, descent;
				
				float width = CTRunGetTypographicBounds(run, glyphRange, &ascent, &descent, NULL);
				// The glyph is centered around the y-axis
				CGRect glyphBounds = CGRectMake(0, 0, width, ascent + descent);
				
				[glyphsMetrix insertObject:[NSValue valueWithCGRect:glyphMetrix] atIndex:index];
				[glyphsBounds insertObject:[NSValue valueWithCGRect:glyphBounds] atIndex:index];
				
				index++;
			}
		}
		
		CGRect lineBounds = CTLineGetImageBounds(line, context);
		
		NSDictionary * glyphInfo = @{@"glyphsMetrix":glyphsMetrix,
									 @"glyphsBounds":glyphsBounds,
									 @"lineBounds":[NSValue valueWithCGRect:lineBounds]};
		
		self.cPositions = [self.textView.layoutProvider textview:self.textView positionForCharacters:self.textView.text glyphInfo:glyphInfo];
	}
	
	CFRelease(line);
}

#pragma mark - CAAction delegate

- (id<CAAction>)actionForLayer:(CALayer *)theLayer forKey:(NSString *)theKey
{
	CATransition *theAnimation=nil;
    if ([theKey isEqualToString:@"contents"])
	{
        theAnimation = [[CATransition alloc] init];
        theAnimation.duration = 0.2;
        theAnimation.timingFunction = [CAMediaTimingFunction
									   functionWithName:kCAMediaTimingFunctionEaseIn];
        theAnimation.type = kCATransitionFade;
    }
	else if([theKey isEqualToString:@"bounds"]||[theKey isEqualToString:@"position"])
	{
		theAnimation = [[CATransition alloc] init];
        theAnimation.duration =0;
		theAnimation.type = kCATransitionFade;
	}
	
//	NSLog(@"animation name:%@",theKey);
	
    return theAnimation;
}

@end
