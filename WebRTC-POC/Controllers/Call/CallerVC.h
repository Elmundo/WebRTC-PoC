//
//  CallerVC.h
//  WebRTC-POC
//
//  Created by BARIS YILMAZ on 17/11/2017.
//  Copyright © 2017 BARIS YILMAZ. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol CallerDelegate

-(void)callDeclined;

@end

@interface CallerVC : UIViewController
@property (weak, nonatomic) IBOutlet UILabel *callingPersonL;
@property (weak, nonatomic) IBOutlet UILabel *constantCallingL;
@property (weak, nonatomic) IBOutlet UIImageView *callingPersonIV;
@property (weak, nonatomic) IBOutlet UIButton *declineBtn;
@property (weak, nonatomic) IBOutlet UIView *containerView;

@property (weak, nonatomic) id<CallerDelegate> delegate;

@end
