//
//  WODFontManager.m
//  TOP
//
//  Created by ianluo on 13-12-12.
//  Copyright (c) 2013年 WOD. All rights reserved.
//

#import "WODFontManager.h"
#import <CoreText/CoreText.h>

@interface WODFontManager()

@end

@implementation WODFontManager

#define keyCustomFontFamilies @"keyCustomFontFamilies"
#define keyExtraFontFamilies @"keyExtraFontFamilies"

- (void)loadCustomFonts
{
	NSFileManager * fileManager = [NSFileManager defaultManager];
	NSString * file;
	NSMutableSet * set = [NSMutableSet set];
	NSString * dir = [NSString stringWithFormat:@"%@/Documents/fonts/",NSHomeDirectory()];
	NSEnumerator * e = [fileManager enumeratorAtPath:dir];
	while((file = [e nextObject]))
	{
		NSURL *fontURL = [NSURL fileURLWithPath:[dir stringByAppendingString:file]];
		assert(fontURL);
		CFErrorRef error = NULL;
		if (!CTFontManagerRegisterFontsForURL((__bridge CFURLRef)fontURL, kCTFontManagerScopeProcess, &error))
		{
			CFShow(error);
//			abort();
		}
		else
		{
			CFArrayRef fontDescriptor =  CTFontManagerCreateFontDescriptorsFromURL((__bridge CFURLRef)fontURL);
			CFIndex count = CFArrayGetCount(fontDescriptor);
			for (int i = 0; i < count; i ++)
			{
				CTFontDescriptorRef descriptor = CFArrayGetValueAtIndex(fontDescriptor, i);
				CFTypeRef value = CTFontDescriptorCopyAttribute(descriptor, kCTFontNameAttribute);
				if (value != NULL)
				{
					[set addObject:(__bridge NSString*)value];
				}
			}
		}
	}
	
	if (set.count > 0)
	{		
		[[NSUserDefaults standardUserDefaults]setObject:[set allObjects] forKey:keyCustomFontFamilies];
		[[NSUserDefaults standardUserDefaults]synchronize];
	}
}

- (void)loadExtraFonts
{
	NSFileManager * fileManager = [NSFileManager defaultManager];
	NSString * file;
	NSMutableSet * set = [NSMutableSet set];
	NSString * dir = [[[NSBundle mainBundle]resourcePath]stringByAppendingString:@"/extraFonts/"];
	NSEnumerator * e = [fileManager enumeratorAtPath:dir];
	while((file = [e nextObject]))
	{
		NSURL *fontURL = [NSURL fileURLWithPath:[dir stringByAppendingString:file]];
		assert(fontURL);
		CFErrorRef error = NULL;
		if ([@[@"ttf",@"otf"] containsObject:[fontURL pathExtension]]) {
			if (!CTFontManagerRegisterFontsForURL((__bridge CFURLRef)fontURL, kCTFontManagerScopeProcess, &error))
			{
				CFShow(error);
				//			abort();
			}
			else
			{
				CFArrayRef fontDescriptor =  CTFontManagerCreateFontDescriptorsFromURL((__bridge CFURLRef)fontURL);
				CFIndex count = CFArrayGetCount(fontDescriptor);
				for (int i = 0; i < count; i ++)
				{
					CTFontDescriptorRef descriptor = CFArrayGetValueAtIndex(fontDescriptor, i);
					CFTypeRef value = CTFontDescriptorCopyAttribute(descriptor, kCTFontNameAttribute);
					if (value != NULL)
					{
						NSString * string = (__bridge NSString*)value;// componentsSeparatedByString:@"-"][0];
						if (string.length > 0)
						{
							[set addObject:string];
						}
					}
				}
				CFRelease(fontDescriptor);
			}
		}
	}
	
	if (set.count > 0)
	{
		[[NSUserDefaults standardUserDefaults]setObject:[set allObjects] forKey:keyExtraFontFamilies];
		[[NSUserDefaults standardUserDefaults]synchronize];
	}
}

- (NSString *)getExtroFontCredit:(NSString *)fontFamilyName
{
	NSString * familyName = [fontFamilyName componentsSeparatedByString:@"-"][0];
	NSString * path = [[[NSBundle mainBundle]resourcePath]stringByAppendingFormat:@"/extraFonts/%@.txt",familyName];
	
	NSFileManager * fileManager = [NSFileManager defaultManager];
	if ([fileManager fileExistsAtPath:path])
	{
		NSError * error;
		NSString * content = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:&error];
		if (error)
		{
			NSLog(@"error when fetch font credit file:%@",path);
		}
		return content;
	}
	else
	{
		return nil;
	}
}

- (void)unloadExtraFonts
{
	NSFileManager * fileManager = [NSFileManager defaultManager];
	NSString * file;
	NSString * dir = [[[NSBundle mainBundle]resourcePath]stringByAppendingString:@"/extraFonts/"];
	NSEnumerator * e = [fileManager enumeratorAtPath:dir];
	while((file = [e nextObject]))
	{
		NSURL *fontURL = [NSURL fileURLWithPath:[dir stringByAppendingString:file]];
		assert(fontURL);
		if ([@[@"ttf",@"otf"] containsObject:[fontURL pathExtension]])
		{
			CFErrorRef error = NULL;
			if (!CTFontManagerUnregisterFontsForURL((__bridge CFURLRef)fontURL, kCTFontManagerScopeProcess, &error))
			{
				CFShow(error);
				//			abort();
			}
		}
	}
	
	[[NSUserDefaults standardUserDefaults]removeObjectForKey:keyExtraFontFamilies];
	[[NSUserDefaults standardUserDefaults]synchronize];
}

- (NSArray *)extraFontFamilies
{
	return [[NSUserDefaults standardUserDefaults]objectForKey:keyExtraFontFamilies];
}

- (NSArray *)customFontFamilies
{
	return [[NSUserDefaults standardUserDefaults]objectForKey:keyCustomFontFamilies];
}

- (void)importFont:(NSURL*)fontURL
{
#ifdef DEBUGMODE
	NSLog(@"Got Font file:\n %@",fontURL);
#endif
	
	[self copyFontToDocument:fontURL];
}

- (void)copyFontToDocument:(NSURL *)fontURL
{
	NSFileManager * fileManager = [NSFileManager defaultManager];
	if([fileManager fileExistsAtPath:fontURL.path])
	{
	
		NSString * fileDir = [NSString stringWithFormat:@"%@/Documents/fonts/",NSHomeDirectory()];
		
		BOOL isDir = YES;
		if (![fileManager fileExistsAtPath:fileDir isDirectory:&isDir])
		{
			NSError * error;
			[fileManager createDirectoryAtPath:fileDir withIntermediateDirectories:YES attributes:nil error:&error];
			if (error)
			{
				NSLog(@"Fail creating dir:%@",error);
			}
		}
		
		NSString * filePathToSave = [NSString stringWithFormat:@"%@%@",fileDir,[fontURL lastPathComponent]];
		
		NSError * error;
		
		if (![fileManager fileExistsAtPath:filePathToSave])
		{
			NSURL * destURL = [NSURL fileURLWithPath:filePathToSave];
			[fileManager moveItemAtURL:fontURL toURL:destURL error:&error];
			
			if (error)
			{
				NSLog(@"ERROR: \n%@",error);
			}
			else
			{
				assert(fontURL);
				CFErrorRef error = NULL;
				if (!CTFontManagerRegisterFontsForURL((__bridge CFURLRef)destURL, kCTFontManagerScopeProcess, &error))
				{
					CFShow(error);
				}
				else
				{
					[[[UIAlertView alloc] initWithTitle:@"Font Successfully Loaded" message:[NSString stringWithFormat:@"%@",[[fontURL lastPathComponent]stringByDeletingPathExtension]] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
				}

			}
		}
		else
		{
			NSLog(@"ERROR: File already existed");
			[[[UIAlertView alloc] initWithTitle:@"ERROR" message:@"File already existed" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
		}
	}
}

- (NSArray *)unregisteredFontFamilies
{
	return [[NSUserDefaults standardUserDefaults]objectForKey:KEY_UNREGISTERED_FONTS];
}

@end
