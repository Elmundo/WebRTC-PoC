//
//  WebRTCVC.h
//  WebRTC-POC
//
//  Created by BARIS YILMAZ on 02/11/2017.
//  Copyright © 2017 BARIS YILMAZ. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <mavenir.webrtc/WebRTC.h>
#import <mavenir.webrtc/WebRTCiOS.h>
#import "WebRTCCall.h"
#import "NSString+WebRTC.h"


@interface WebRTCVC : UIViewController <WebRTCiOSDelegate>

@property (weak, nonatomic) IBOutlet UITableView *logTV;
@property (weak, nonatomic) IBOutlet UIView *statusIcon;
@property (weak, nonatomic) IBOutlet UIButton *clearLogBtn;
@property (weak, nonatomic) IBOutlet UIButton *reconnectBtn;

@property (weak, nonatomic) IBOutlet UITextField *authCodeTF;
@property (weak, nonatomic) IBOutlet UITextField *msisdnTF;
@property (weak, nonatomic) IBOutlet UITextField *targetMsisdnTF;
@property (weak, nonatomic) IBOutlet UITextField *secondTargetMsisdnTF;
@property (weak, nonatomic) IBOutlet UIButton *callBtn;

@property (strong, nonatomic) NSMutableArray<WebRTCCall *> *calls;

- (WebRTCCall *)getActiveWebRTCCall;
- (WebRTCCall *)getWebRTCCallWithState:(WebRTCCallState)state isOutgoing:(BOOL)isOutgoing;
- (WebRTCCall *)getWebRTCCallWithCallId:(NSString *)callId;
- (WebRTCCall *)getWebRTCCallWithCallUUID:(NSString *)callUUID;
- (WebRTCCall *)getFirstWebRTCCall;
- (void)addWebRTCCall:(WebRTCCall *)call;
- (void)removeWebRTCCall:(WebRTCCall *)call;

@end
