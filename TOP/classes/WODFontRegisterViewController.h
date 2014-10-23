//
//  WODFontRigisterViewController.h
//  TOP
//
//  Created by ianluo on 14-2-8.
//  Copyright (c) 2014年 WOD. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FUISwitch.h"

@interface WODFontRegisterViewController : UIViewController

@end

@interface WODFontRegisterTableCell:UITableViewCell

typedef enum
{
	CellStyleSwitch = 0,
	CellStyleCredit,
	CellStyleNone,
}CellStyle;

@property (nonatomic, strong)FUISwitch * isRigesterd;

@property (nonatomic, assign)CellStyle cellStyle;

- (void)setSwitchBlock:(void(^)(bool isOn))action;

- (void)setCellStyle:(CellStyle)style;

@end
