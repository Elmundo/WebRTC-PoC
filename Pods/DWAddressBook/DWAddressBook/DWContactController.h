//
//  DWContactController.h
//  DWAddressBookDemo
//
//  Created by dwang_sui on 2017/7/28.
//  Copyright © 2017年 dwang. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DWContactController : UITableViewController

/** 存储A～Z的数组 */
@property(nonatomic, strong) NSArray *cellModelKeysArr;

/** 联系人详情的模型 */
@property(nonatomic, strong) NSDictionary *cellModelDict;

/** 多个号码时是否跳转push到下一控制器 */
@property(nonatomic, assign) BOOL showTableView;

/** 是否显示联系人总和/在最后一行cell中显示 */
@property(nonatomic, assign) BOOL showTotalNumber;

/** 返回图片 */
@property(nonatomic, strong) UIImage *backimage;

@property(nonatomic, copy) void (^selectMobNumber)(NSString *name, NSString *mobNumber);

@end
