//
//  TableViewDelegate.h
//  WebRTC-POC
//
//  Created by BARIS YILMAZ on 08/01/2018.
//  Copyright © 2018 BARIS YILMAZ. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "LogModel.h"



@interface TableViewDelegate : NSObject<UITableViewDelegate, UITableViewDataSource>

@property(nonatomic, strong) NSArray<LogModel*> *logs;

@end
