//
//  CallieVC.h
//  WebRTC-POC
//
//  Created by BARIS YILMAZ on 17/11/2017.
//  Copyright © 2017 BARIS YILMAZ. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol CallieDelegate

-(void)callieCallDeclined;
-(void)callieCallAccepted;

@end

@interface CallieVC : UIViewController

@property (weak, nonatomic) IBOutlet UILabel *callingPersonL;
@property (weak, nonatomic) IBOutlet UILabel *constantCallingL;
@property (weak, nonatomic) IBOutlet UIImageView *callingPersonIV;
@property (weak, nonatomic) IBOutlet UIButton *declineBtn;
@property (weak, nonatomic) IBOutlet UIButton *acceptBtn;
@property (weak, nonatomic) IBOutlet UIView *containerView;

@property (weak, nonatomic) id<CallieDelegate> delegate;

@end
