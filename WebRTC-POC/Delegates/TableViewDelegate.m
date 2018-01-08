//
//  TableViewDelegate.m
//  WebRTC-POC
//
//  Created by BARIS YILMAZ on 08/01/2018.
//  Copyright © 2018 BARIS YILMAZ. All rights reserved.
//

#import "TableViewDelegate.h"
#import "LogTVC.h"

@implementation TableViewDelegate

#pragma mark - UITableViewDataSource
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.logs count];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    LogModel *model       = [self.logs objectAtIndex:indexPath.row];
    LogTVC *cell          = (LogTVC *)[tableView dequeueReusableCellWithIdentifier:@"LogTVC"];
    cell.logTextView.text = model.log;
    [cell.logTextView setFont:[UIFont systemFontOfSize:12.0f]];
    
    return cell;
}

#pragma mark - UITableViewDelegate
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [self calculateHeightOfCell:indexPath];
}

#pragma mark - Helper Methods
- (CGFloat)calculateHeightOfCell:(NSIndexPath *)indexPath {
    LogModel *model = [self.logs objectAtIndex:indexPath.row];
    NSString *text  = model.log;
    CGRect rect = [text boundingRectWithSize:CGSizeMake(340, 2000)
                                     options:NSStringDrawingUsesLineFragmentOrigin
                                  attributes:@{NSFontAttributeName: [UIFont systemFontOfSize:14.0f]}
                                     context:nil];
    NSInteger height = MAX(rect.size.height + 10, 44);
    return height;
}

@end
