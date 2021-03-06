//
//  CallerVC.h
//  WebRTC-POC
//
//  Created by BARIS YILMAZ on 17/11/2017.
//  Copyright © 2017 BARIS YILMAZ. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <ContactsUI/ContactsUI.h>
#import <Contacts/Contacts.h>
#import <mavenir.webrtc/WebRTC.h>
#import <mavenir.webrtc/WebRTCiOS.h>
#import <JCDialPad.h>
#import "WebRTCCall.h"
#import "WebRTCVC.h"

#import "NSString+WebRTC.h"
#import "AudioService.h"

@protocol CallerDelegate

-(void)callDeclined;

@end

@interface CallerVC : UIViewController<JCDialPadDelegate>
@property (weak, nonatomic) IBOutlet UILabel *callingPersonL;
@property (weak, nonatomic) IBOutlet UILabel *constantCallingL;
@property (weak, nonatomic) IBOutlet UILabel *secondCallL;
@property (weak, nonatomic) IBOutlet UIImageView *callingPersonIV;
@property (weak, nonatomic) IBOutlet UIButton *declineBtn;
@property (weak, nonatomic) IBOutlet UIView *containerView;
@property (weak, nonatomic) IBOutlet UIButton *holdBtn;
@property (weak, nonatomic) IBOutlet UIButton *muteBtn;
@property (weak, nonatomic) IBOutlet UIButton *addCallBtn;
@property (weak, nonatomic) IBOutlet UIButton *speakerBtn;
@property (weak, nonatomic) IBOutlet UIButton *mergeBtn;
@property (weak, nonatomic) IBOutlet UIButton *dialPad;

@property (weak, nonatomic) id<CallerDelegate> delegate;

@property (nonatomic, copy) NSString *caller;
@property (nonatomic, copy) NSString *secondtargetMsisdn;
@property (nonatomic, copy) NSString *sessionInfo;

@property (weak, nonatomic) WebRTCVC *webRTCController;
@property (weak, nonatomic) NSMutableArray<WebRTCCall *> *webrtcCalls;

@end
