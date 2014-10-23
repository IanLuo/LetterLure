//
//  WODFontManager.h
//  TOP
//
//  Created by ianluo on 13-12-12.
//  Copyright (c) 2013年 WOD. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WODFontManager : NSObject

- (void)loadCustomFonts;
- (void)loadExtraFonts;
- (void)unloadExtraFonts;

- (void)importFont:(NSURL*)fontURL;

- (NSArray *)unregisteredFontFamilies;

- (NSArray *)extraFontFamilies;

- (NSString *)getExtroFontCredit:(NSString *)fontFamilyName;

- (NSArray *)customFontFamilies;

@end
