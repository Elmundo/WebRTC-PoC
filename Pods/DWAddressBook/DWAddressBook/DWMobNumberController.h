//
//  DWMobNumberController.h
//  DWAddressBookDemo
//
//  Created by dwang_sui on 2017/8/4.
//  Copyright © 2017年 dwang. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DWMobNumberController : UIViewController

/** 手机号数组 */
@property(nonatomic, strong) NSArray *cellModelArr;

/** 返回图片 */
@property(nonatomic, strong) UIImage *backimage;

@property(nonatomic, copy) void (^selectMobNumber)(NSString *name, NSString *mobNumber);

@end
