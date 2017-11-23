//
//  LogTVC.m
//  WebRTC-POC
//
//  Created by BARIS YILMAZ on 17/11/2017.
//  Copyright © 2017 BARIS YILMAZ. All rights reserved.
//

#import "LogTVC.h"

@implementation LogTVC

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    
    self.logTextView.contentInset       = UIEdgeInsetsMake(0.0, 0.0, 0.0, 0.0);
    self.logTextView.textContainerInset = UIEdgeInsetsMake(0.0, 0.0, 0.0, 0.0);
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
