//
//  WODEffectReader.m
//  TOP
//
//  Created by ianluo on 13-12-13.
//  Copyright (c) 2013年 WOD. All rights reserved.
//

#import "WODEffectReader.h"

//pattern
NSString * const kPatternType = @"patternType";
NSString * const kPatternIsStencil = @"isStencil";
NSString * const kPatternImagePath = @"imagePatternImagePath";
NSString * const kPatternGeneratorKey = @"genericPatternKey";
NSString * const kPatternAlpha = @"patternAlpha";// for per pattern alpha
NSString * const kPatternWidth = @"imagePatternWidth";
NSString * const kPatternHeight = @"imagePatternHeigth";

NSString * const kPatternFillPatterns = @"fillPattern";
NSString * const kPatternFillPatternAlpha = @"fillPatternAlpha";// for total patterns alpha

NSString * const kPatternStrokePatterns = @"strokePattern";
NSString * const kPatternStrokePatternAlpha = @"strokePatternAlpha";

//gradient
NSString * const kGradientType = @"type";
NSString * const kGradientBlendMode = @"blendMode";
NSString * const kGradient = @"gradient";
NSString * const kGradientRed = @"red";
NSString * const kGradientGreen = @"green";
NSString * const kGradientBlue = @"blue";
NSString * const kGradientAlpha = @"alpha";
NSString * const kGradientLocation = @"location";
NSString * const kGradientColorArray = @"colorArray";
NSString * const kGradientLineAttrAngle = @"lineAttrAngle";
NSString * const kGradientRadialAttrCenter1XPercentage = @"center1XPercentage";
NSString * const kGradientRadialAttrCenter1YPercentage = @"center1YPercentage";
NSString * const kGradientRadialAttrCenter2XPercentage = @"center2XPercentage";
NSString * const kGradientRadialAttrCenter2YPercentage = @"center2YPercentage";
NSString * const kGradientRadialAttrRadialGradientRadius1Percentage = @"radialGradientRadius1Percentage";
NSString * const kGradientRadialAttrRadialGradientRadius2Percentage = @"radialGradientRadius2Percentage";

//strokeGradient
NSString * const kStrokeGradientType = @"type";
NSString * const kStrokeGradient = @"strokerGadient";
NSString * const kStrokeGradientRed = @"red";
NSString * const kStrokeGradientGreen = @"green";
NSString * const kStrokeGradientBlue = @"blue";
NSString * const kStrokeGradientAlpha = @"alpha";
NSString * const kStrokeGradientLocation = @"location";
NSString * const kStrokeGradientColorArray = @"colorArray";
NSString * const kStrokeGradientLineAttrAngle = @"lineAttrAngle";
NSString * const kStrokeGradientRadialAttrCenter1XPercentage = @"center1XPercentage";
NSString * const kStrokeGradientRadialAttrCenter1YPercentage = @"center1YPercentage";
NSString * const kStrokeGradientRadialAttrCenter2XPercentage = @"center2XPercentage";
NSString * const kStrokeGradientRadialAttrCenter2YPercentage = @"center2YPercentage";
NSString * const kStrokeGradientRadialAttrRadialGradientRadius1Percentage = @"radialGradientRadius1Percentage";
NSString * const kStrokeGradientRadialAttrRadialGradientRadius2Percentage = @"radialGradientRadius2Percentage";

//shadow
NSString * const kShadowColor = @"shadowColor";
NSString * const kShadowOffset = @"shadowOffset";
NSString * const kShadowBlur = @"shadowBlur";

//stroke
NSString * const kStrokeWidthPercent = @"strokWidthPercent";
NSString * const kStrokeColor = @"strokeColor";

@interface WODEffectReader()<NSXMLParserDelegate>
{
	void (^completeActionBlock)(NSDictionary * result);
}

@property (nonatomic, strong)NSMutableDictionary * xmlData;

@property (nonatomic, strong) NSMutableArray * fillPatternArray;
@property (nonatomic, assign) CGFloat fillPatternAlpha;

@property (nonatomic, strong) NSMutableArray * strokePatternArray;
@property (nonatomic, assign) CGFloat strokePatternAlpha;


@end

@implementation WODEffectReader

- (void)readEffect:(NSString *)path complete:(void(^)(NSDictionary * result))block
{
	completeActionBlock = block;
	[self parseXML:path];
}

- (void)parseXML:(NSString *)xmlFilePath
{
	NSXMLParser * parser = [[NSXMLParser alloc] initWithData:[NSData dataWithContentsOfFile:xmlFilePath]];
	[parser setDelegate:self];
	[parser parse];
}

#pragma mark - NSXMLParser delegate methods

NSString * const kElementFillPattern = @"fillPattern";
NSString * const kElementStrokePattern = @"strokePattern";
NSString * const kElementPatternArray = @"patternArray";
NSString * const kElementPattern = @"pattern";
NSString * const kElementPatternImagePatternPath = @"imagePatternPath";
NSString * const kElementPatternSysPatternKey = @"systemPatternKey";

NSString * const kElementGradient = @"gradient";
NSString * const kElementGradientLineGradientAttrs = @"lineGradientAttrs";
NSString * const kElementGradientRadialGradientAttrs = @"radialGradientAttrs";
NSString * const kElementGradientValue = @"gradientValue";

NSString * const kElementStrokeGradient = @"strokeGradient";
NSString * const kElementGradientLineStrokeGradientAttrs = @"lineStrokeGradientAttrs";
NSString * const kElementGradientRadialStrokeGradientAttrs = @"radialStrokeGradientAttrs";

NSString * const kElementStrokeGradientValue = @"strokeGradientValue";

//shadow
NSString * const kElementShadowColor = @"shadowColor";
NSString * const kElementShadowOffset = @"shadowOffset";
NSString * const kElementShadowBlur = @"shadowBlur";

//stroke
NSString * const kElementStrokeWidthPercent = @"strokeWidthPercent";
NSString * const kElementStrokeColor = @"strokeColor";

 NSString * kElementCharactorValue;
 NSMutableDictionary * currentPattern;
 NSMutableArray * currentPatternArray;

 NSMutableDictionary * currentGradient;
 NSMutableArray * currentGradientColorArray;
 NSMutableDictionary * currentStrokeGradient;
 NSMutableArray * currentStrokeGradientColorArray;

- (void)parserDidStartDocument:(NSXMLParser *)parser
{
	_xmlData = [NSMutableDictionary dictionary];
}

- (void)parserDidEndDocument:(NSXMLParser *)parser
{
//	NSLog(@"%@",self.xmlData);
	
	if (completeActionBlock)
	{
		completeActionBlock(self.xmlData);
	}
	
	kElementCharactorValue = nil;
	currentPattern = nil;
	currentPatternArray = nil;
	
	currentGradient = nil;
	currentGradientColorArray= nil;
	currentStrokeGradient= nil;
	currentStrokeGradientColorArray= nil;
}

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict
{

	// parse pattern
	if ([elementName isEqualToString:kElementFillPattern])
	{
		NSAssert([attributeDict objectForKey:@"alpha"], @"fillPattern> 'alpha' can't be empty");
		[self.xmlData setObject:[attributeDict objectForKey:@"alpha"] forKey:kPatternFillPatternAlpha];
	}
	
	// parse stroke pattern
	else if ([elementName isEqualToString:kElementStrokePattern])
	{
		NSAssert([attributeDict objectForKey:@"alpha"], @"strokePattern> 'alpha' can't be empty");
		[self.xmlData setObject:[attributeDict objectForKey:@"alpha"] forKey:kPatternStrokePatternAlpha];
	}
	else if ([elementName isEqualToString:kElementPatternArray])
	{
		currentPatternArray = [NSMutableArray array];
	}
	else if ([elementName isEqualToString:kElementPattern])
	{
		currentPattern = [NSMutableDictionary dictionary];
		
		NSAssert([attributeDict objectForKey:@"type"], @"'type' can't be empty");
		NSAssert([attributeDict objectForKey:@"width"], @"'width' can't be empty");
		NSAssert([attributeDict objectForKey:@"height"], @"'height' can't be empty");
		NSAssert([attributeDict objectForKey:@"alpha"], @"'alpha' can't be empty");
		
		[currentPattern setObject:[attributeDict objectForKey:@"type"] forKey:kPatternType];
		[currentPattern setObject:[attributeDict objectForKey:@"width"] forKey:kPatternWidth];
		[currentPattern setObject:[attributeDict objectForKey:@"height"] forKey:kPatternHeight];
		[currentPattern setObject:[attributeDict objectForKey:@"alpha"] forKey:kPatternAlpha];
		
		if ([attributeDict objectForKey:@"isStencil"])
		{
			[currentPattern setObject:[attributeDict objectForKey:@"isStencil"] forKey:kPatternIsStencil];
		}
	}
	else if ([elementName isEqualToString:kElementPatternImagePatternPath])
	{
		kElementCharactorValue = @"";
	}
	else if ([elementName isEqualToString:kElementPatternSysPatternKey])
	{
		kElementCharactorValue = @"";
	}
	
	// parse gradient
	
	else if ([elementName isEqualToString:kElementGradient])
	{
		NSAssert([attributeDict objectForKey:@"type"], @"gradient> 'type' can't be empty");
		currentGradient = [NSMutableDictionary dictionary];
		[currentGradient setObject:[attributeDict objectForKey:@"type"] forKey:kGradientType];
		
		id obj = [attributeDict objectForKey:@"blendMode"];
		if (obj)
		{
			[currentGradient setObject:obj forKey:kGradientBlendMode];
		}
		else
		{
			[currentGradient setObject:@1 forKey:kGradientBlendMode]; // make defualt blend mode multipy
		}
		
		currentGradientColorArray = [NSMutableArray array];
	}
	else if ([elementName isEqualToString:kElementGradientValue])
	{
		NSAssert([attributeDict objectForKey:@"red"], @"gradient> 'red' can't be empty");
		NSAssert([attributeDict objectForKey:@"green"], @"gradient> 'green' can't be empty");
		NSAssert([attributeDict objectForKey:@"blue"], @"gradient> 'blue' can't be empty");
		NSAssert([attributeDict objectForKey:@"alpha"], @"gradient> 'alpha' can't be empty");
		NSAssert([attributeDict objectForKey:@"location"], @"gradient> 'location' can't be empty");
		
		NSDictionary * gradientValue = @{kGradientRed:[attributeDict objectForKey:@"red"],
										 kGradientGreen:[attributeDict objectForKey:@"green"],
										 kGradientBlue:[attributeDict objectForKey:@"blue"],
										 kGradientAlpha:[attributeDict objectForKey:@"alpha"],
										 kGradientLocation:[attributeDict objectForKey:@"location"]};
								
		[currentGradientColorArray addObject:gradientValue];
	}
	else if ([elementName isEqualToString:kElementGradientLineGradientAttrs])
	{
		NSAssert([attributeDict objectForKey:@"angle"], @"lineGradientAttrs> 'angle' can't be empty");
		[currentGradient setObject:[attributeDict objectForKey:@"angle"] forKey:kGradientLineAttrAngle];
	}
	else if ([elementName isEqualToString:kElementGradientRadialGradientAttrs])
	{
		NSAssert([attributeDict objectForKey:@"center1XPercentage"], @"radialGradientAttrs> 'center1XPercentage' can't be empty");
		NSAssert([attributeDict objectForKey:@"center1YPercentage"], @"radialGradientAttrs> 'center1YPercentage' can't be empty");
		NSAssert([attributeDict objectForKey:@"radialGradientRadius1Percentage"], @"radialGradientAttrs> 'radialGradientRadius1Percentage' can't be empty");
		NSAssert([attributeDict objectForKey:@"radialGradientRadius2Percentage"], @"radialGradientAttrs> 'radialGradientRadius2Percentage' can't be empty");
	
		[currentGradient setObject:[attributeDict objectForKey:@"center1XPercentage"] forKey:kGradientRadialAttrCenter1XPercentage];
		[currentGradient setObject:[attributeDict objectForKey:@"center1YPercentage"] forKey:kGradientRadialAttrCenter1YPercentage];
		[currentGradient setObject:[attributeDict objectForKey:@"center2XPercentage"] forKey:kGradientRadialAttrCenter2XPercentage];
		[currentGradient setObject:[attributeDict objectForKey:@"center2YPercentage"] forKey:kGradientRadialAttrCenter2YPercentage];
		[currentGradient setObject:[attributeDict objectForKey:@"radialGradientRadius1Percentage"] forKey:kGradientRadialAttrRadialGradientRadius1Percentage];
		[currentGradient setObject:[attributeDict objectForKey:@"radialGradientRadius2Percentage"] forKey:kGradientRadialAttrRadialGradientRadius2Percentage];
	}
	// parse stroke gradient
	
	else if ([elementName isEqualToString:kElementStrokeGradient])
	{
		NSAssert([attributeDict objectForKey:@"type"], @"gradient> 'type' can't be empty");
		currentStrokeGradient = [NSMutableDictionary dictionary];
		[currentStrokeGradient setObject:[attributeDict objectForKey:@"type"] forKey:kStrokeGradientType];
		id obj = [attributeDict objectForKey:@"blendMode"];
		if (obj)
		{
			[currentStrokeGradient setObject:[attributeDict objectForKey:@"blendMode"] forKey:kGradientBlendMode];
		}
		
		currentStrokeGradientColorArray = [NSMutableArray array];
	}
	else if ([elementName isEqualToString:kElementStrokeGradientValue])
	{
		NSAssert([attributeDict objectForKey:@"red"], @"stroke gradient> 'red' can't be empty");
		NSAssert([attributeDict objectForKey:@"green"], @"stroke gradient> 'green' can't be empty");
		NSAssert([attributeDict objectForKey:@"blue"], @"stroke gradient> 'blue' can't be empty");
		NSAssert([attributeDict objectForKey:@"alpha"], @"stroke gradient> 'alpha' can't be empty");
		NSAssert([attributeDict objectForKey:@"location"], @"stroke gradient> 'location' can't be empty");
		
		NSDictionary * gradientValue = @{kStrokeGradientRed:[attributeDict objectForKey:@"red"],
										 kStrokeGradientGreen:[attributeDict objectForKey:@"green"],
										 kStrokeGradientBlue:[attributeDict objectForKey:@"blue"],
										 kStrokeGradientAlpha:[attributeDict objectForKey:@"alpha"],
										 kStrokeGradientLocation:[attributeDict objectForKey:@"location"]};
		
		[currentStrokeGradientColorArray addObject:gradientValue];
	}
	else if ([elementName isEqualToString:kElementGradientLineStrokeGradientAttrs])
	{
		NSAssert([attributeDict objectForKey:@"angle"], @"lineStrokeGradientAttrs> 'angle' can't be empty");
		[currentStrokeGradient setObject:[attributeDict objectForKey:@"angle"] forKey:kStrokeGradientLineAttrAngle];
	}
	else if ([elementName isEqualToString:kElementGradientRadialStrokeGradientAttrs])
	{
		NSAssert([attributeDict objectForKey:@"center1XPercentage"], @"radialGradientAttrs> 'center1XPercentage' can't be empty");
		NSAssert([attributeDict objectForKey:@"center1YPercentage"], @"radialGradientAttrs> 'center1YPercentage' can't be empty");
		NSAssert([attributeDict objectForKey:@"radialGradientRadius1Percentage"], @"radialGradientAttrs> 'radialGradientRadius1Percentage' can't be empty");
		NSAssert([attributeDict objectForKey:@"radialGradientRadius2Percentage"], @"radialGradientAttrs> 'radialGradientRadius2Percentage' can't be empty");
		
		[currentStrokeGradient setObject:[attributeDict objectForKey:@"center1XPercentage"] forKey:kStrokeGradientRadialAttrCenter1XPercentage];
		[currentStrokeGradient setObject:[attributeDict objectForKey:@"center1YPercentage"] forKey:kStrokeGradientRadialAttrCenter1YPercentage];
		[currentStrokeGradient setObject:[attributeDict objectForKey:@"center2XPercentage"] forKey:kStrokeGradientRadialAttrCenter2XPercentage];
		[currentStrokeGradient setObject:[attributeDict objectForKey:@"center2YPercentage"] forKey:kStrokeGradientRadialAttrCenter2YPercentage];
		[currentStrokeGradient setObject:[attributeDict objectForKey:@"radialGradientRadius1Percentage"] forKey:kStrokeGradientRadialAttrRadialGradientRadius1Percentage];
		[currentStrokeGradient setObject:[attributeDict objectForKey:@"radialGradientRadius2Percentage"] forKey:kStrokeGradientRadialAttrRadialGradientRadius2Percentage];
	}
	
	//shadow
	else if ([elementName isEqualToString:kElementShadowColor])
	{
		NSAssert([attributeDict objectForKey:@"red"], @"shadowColor: > 'red' can't be empty");
		NSAssert([attributeDict objectForKey:@"green"], @"shadowColor> 'green' can't be empty");
		NSAssert([attributeDict objectForKey:@"blue"], @"shadowColor> 'blue' can't be empty");
		NSAssert([attributeDict objectForKey:@"alpha"], @"shadowColor> 'alpha' can't be empty");
		
		[self.xmlData setObject:[UIColor colorWithRed:[[attributeDict objectForKey:@"red"]floatValue]/256 green:[[attributeDict objectForKey:@"green"]floatValue]/256 blue:[[attributeDict objectForKey:@"blue"]floatValue]/256 alpha:[[attributeDict objectForKey:@"alpha"]floatValue]] forKey:kShadowColor];
	}
	else if ([elementName isEqualToString:kElementShadowOffset])
	{
		NSAssert([attributeDict objectForKey:@"widthPercentage"], @"shadowOffset: > 'widthPercentage' can't be empty");
		NSAssert([attributeDict objectForKey:@"heightPercentage"], @"shadowOffset> 'heightPercentage' can't be empty");
		
		[self.xmlData setObject:[NSValue valueWithCGSize:CGSizeMake([[attributeDict objectForKey:@"widthPercentage"]floatValue], [[attributeDict objectForKey:@"heightPercentage"]floatValue])] forKey:kShadowOffset];
	}
	else if ([elementName isEqualToString:kElementShadowBlur])
	{
		NSAssert([attributeDict objectForKey:@"value"], @"shadowBlur: > 'value' can't be empty");
		
		[self.xmlData setObject:[attributeDict objectForKey:@"value"] forKey:kShadowBlur];
	}
	
	//stroke
	else if ([elementName isEqualToString:kElementStrokeWidthPercent])
	{
		NSAssert([attributeDict objectForKey:@"value"], @"strokeWidthPercent: > 'value' can't be empty");
		
		[self.xmlData setObject:[attributeDict objectForKey:@"value"] forKey:kStrokeWidthPercent];
	}
	else if ([elementName isEqualToString:kElementStrokeColor])
	{
		NSAssert([attributeDict objectForKey:@"red"], @"strokeColor: > 'red' can't be empty");
		NSAssert([attributeDict objectForKey:@"green"], @"strokeColor> 'green' can't be empty");
		NSAssert([attributeDict objectForKey:@"blue"], @"strokeColor> 'blue' can't be empty");
		NSAssert([attributeDict objectForKey:@"alpha"], @"strokeColor> 'alpha' can't be empty");
		
		[self.xmlData setObject:[UIColor colorWithRed:[[attributeDict objectForKey:@"red"]floatValue]/255 green:[[attributeDict objectForKey:@"green"]floatValue]/255 blue:[[attributeDict objectForKey:@"blue"]floatValue]/255 alpha:[[attributeDict objectForKey:@"alpha"]floatValue]] forKey:kStrokeColor];
	}
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName
{
	if ([elementName isEqualToString:kElementFillPattern])
	{
		if (currentPatternArray)
		{
			[self.xmlData setObject:currentPatternArray forKey:kPatternFillPatterns];
			
			//clearn the pattern incase the next tag using array got the dirty data
			currentPatternArray = nil;
		}
	}
	else if ([elementName isEqualToString:kElementStrokePattern])
	{
		if (currentPatternArray)
		{
			[self.xmlData setObject:currentPatternArray forKey:kPatternStrokePatterns];
			
			//clearn the pattern incase the next tag using array got the dirty data
			currentPatternArray = nil;

		}
	}
		
	else if ([elementName isEqualToString:kElementPattern])
	{
		[currentPatternArray addObject:currentPattern];
		currentPattern = nil;
	}
	else if ([elementName isEqualToString:kElementPatternImagePatternPath])
	{
		[currentPattern setObject:kElementCharactorValue forKey:kPatternImagePath];
	}
	else if ([elementName isEqualToString:kElementPatternSysPatternKey])
	{
		[currentPattern setObject:kElementCharactorValue forKey:kPatternGeneratorKey];
	}
	
	//gradient
	else if ([elementName isEqualToString:kElementGradient])
	{
		[currentGradient setObject:currentGradientColorArray forKey:kGradientColorArray];
		[self.xmlData setObject:currentGradient forKey:kGradient];
	}
	
	//stroke gradient
	else if ([elementName isEqualToString:kElementStrokeGradient])
	{
		[currentStrokeGradient setObject:currentStrokeGradientColorArray forKey:kGradientColorArray];
		[self.xmlData setObject:currentStrokeGradient forKey:kStrokeGradient];
	}
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string
{
	kElementCharactorValue = [kElementCharactorValue stringByAppendingString:string];
}

- (void)parser:(NSXMLParser *)parser parseErrorOccurred:(NSError *)parseError
{
	NSLog(@"ERROR:\n %@",parseError.description);
}

@end
