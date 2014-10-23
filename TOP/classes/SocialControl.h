//
//  SocialControl.h
//  YouPlay
//
//  Created by ianluo on 14-7-26.
//  Copyright (c) 2014年 WOD. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SocialControl : NSObject

@property (nonatomic, strong)NSString * message;
@property (nonatomic, strong)UIImage * image;

- (void)shareToFacebook:(void(^)(void))complete;

- (void)shareToTwitter:(void(^)(void))complete;

- (void)shareToWeibo:(void(^)(void))complete;

- (void)shareToWeChat:(void(^)(void))complete;

- (void)shareToEmail:(void(^)(void))complete;

- (void)saveToImageRoll:(void(^)(void))complete;

@end
