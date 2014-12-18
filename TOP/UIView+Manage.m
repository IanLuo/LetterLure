//
//  UIView+Manage.m
//  AutoGang
//
//  Created by ian luo on 14/10/20.
//  Copyright (c) 2014年 com.qcb008.QiCheApp. All rights reserved.
//

#import "UIView+Manage.h"

@implementation UIView(manage)

- (void)removeAllSubviews
{
    for (UIView * sub in self.subviews)
    {
        [sub removeFromSuperview];
    }
}

@end
