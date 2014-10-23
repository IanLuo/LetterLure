//
//  TOPTests.m
//  TOPTests
//
//  Created by ianluo on 13-12-12.
//  Copyright (c) 2013年 WOD. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "WODEffectReader.h"

@interface TOPTests : XCTestCase

@end

@implementation TOPTests

- (void)setUp
{
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown
{
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testExample
{
	NSString * path = [[NSBundle mainBundle]pathForResource:@"effect_template" ofType:@"xml"];
	[[WODEffectReader new]readEffect:path complete:nil];
}

@end
