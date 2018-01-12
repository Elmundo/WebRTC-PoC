//
//  DWMobNumberController.m
//  DWAddressBookDemo
//
//  Created by dwang_sui on 2017/8/4.
//  Copyright © 2017年 dwang. All rights reserved.
//

#import "DWMobNumberController.h"

@interface DWMobNumberController ()<UITableViewDelegate, UITableViewDataSource>
@end

@implementation DWMobNumberController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"resources.bundle/返回@2x.png" ofType:nil]] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] style:UIBarButtonItemStylePlain target:self action:@selector(leftBarButtonItemDidClick)];
    UITableView *tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStyleGrouped];
    tableView.delegate = self;
    tableView.dataSource = self;
    [self.view addSubview:tableView];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return CGFLOAT_MIN;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return CGFLOAT_MIN;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.cellModelArr.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 44;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *identifier = @"cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    cell.textLabel.text = self.cellModelArr[indexPath.row];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (self.selectMobNumber) {
        self.selectMobNumber(self.title, self.cellModelArr[indexPath.row]);
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (void)leftBarButtonItemDidClick {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)setBackimage:(UIImage *)backimage {
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[backimage imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] style:UIBarButtonItemStylePlain target:self action:@selector(leftBarButtonItemDidClick)];
}


- (NSArray *)cellModelArr {
    if (!_cellModelArr) {
        _cellModelArr = [NSArray array];
    }
    return _cellModelArr;
}

@end
