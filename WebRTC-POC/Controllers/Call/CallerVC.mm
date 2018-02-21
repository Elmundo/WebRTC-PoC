//
//  CallerVC.m
//  WebRTC-POC
//
//  Created by BARIS YILMAZ on 17/11/2017.
//  Copyright © 2017 BARIS YILMAZ. All rights reserved.
//

#import <DWAddressBook.h>
#import <JCPadButton.h>
#import "CallerVC.h"
#import "CallManager.h"

typedef void (^SecondCallBlock)();

@interface CallerVC ()

@end

@implementation CallerVC
{
    WebRTC *webRTC;
    CNContactPickerViewController *contactController;
    DWAddressBook *addressbook;
    SecondCallBlock secondCallBlock;
    JCDialPad *dialpad;
}

-(void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - Build-in Methods
- (void)viewDidLoad {
    [super viewDidLoad];
    
    webRTC = &WebRTC::mavInstance();
    secondCallBlock = nil;
    
    [self initWidgets];
    [self initContactController];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onAudioSessionEvent:) name:AVAudioSessionInterruptionNotification object:nil];
}

- (void) onAudioSessionEvent: (NSNotification *) notification
{
    //Check the type of notification, especially if you are sending multiple AVAudioSession events here
    if ([notification.name isEqualToString:AVAudioSessionInterruptionNotification]) {
        NSLog(@"Interruption notification received!");
        
        //Check to see if it was a Begin interruption
        if ([[notification.userInfo valueForKey:AVAudioSessionInterruptionTypeKey] isEqualToNumber:[NSNumber numberWithInt:AVAudioSessionInterruptionTypeBegan]]) {
            NSLog(@"Interruption began!");
            
        } else {
            NSLog(@"Interruption ended!");
            //Resume your audio
        }
    }
}
-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self initDialPad];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self addObservers];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self removeObservers];
}

-(void) addObservers {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onCallActive_Action:) name:@"CallActive" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onCallStatus_Action:) name:@"CallStatus" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onCallEnd_Action:)    name:@"CallEnd" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onCallReject_Action:) name:@"CellRejected" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onCallHold_Action:)   name:@"CallHold" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onCallUnhold_Action:) name:@"CallUnhold" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onCallAdHocConf_Action:) name:@"AdHocConf" object:nil];
}

- (void)removeObservers {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)initDialPad {
    dialpad = [[JCDialPad alloc] initWithFrame:self.view.bounds];
    dialpad.buttons = [[JCDialPad defaultButtons] arrayByAddingObject:[self twilioButton]];
    dialpad.delegate = self;
}

- (void)initWidgets {
    self.callingPersonIV.layer.cornerRadius = self.callingPersonIV.frame.size.width/2;
    self.callingPersonIV.layer.masksToBounds = true;
    [self.callingPersonIV setBackgroundColor:[UIColor grayColor]];

    // Blur Effect
    UIBlurEffect *blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleDark];
    UIVisualEffectView *blurView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
    [blurView setTranslatesAutoresizingMaskIntoConstraints:false];
    [self.view insertSubview:blurView atIndex:0];

    [self setConstraintsWithBlurEffectView:blurView];
}

- (void)initContactController {
    [DWAddressBook requestAddressBookAuthorization];
    
    addressbook = [[DWAddressBook alloc] initWithResultBlock:^(NSString *name, NSString *mobNumber) {
        [self configureSecondCall];
    } failure:^{
        NSLog(@"Contact selection had been failed.");
    }];
}

- (JCPadButton *)twilioButton
{
    UIImage *twilioIcon = [UIImage imageNamed:@"Twilio"];
    UIImageView *iconView = [[UIImageView alloc] initWithImage:twilioIcon];
    iconView.contentMode = UIViewContentModeScaleAspectFit;
    JCPadButton *twilioButton = [[JCPadButton alloc] initWithInput:@"T" iconView:iconView subLabel:@""];
    return twilioButton;
}

- (void)setConstraintsWithBlurEffectView:(UIVisualEffectView *)blurView{
    NSMutableArray<NSLayoutConstraint*> *constraints = [[NSMutableArray<NSLayoutConstraint *> alloc] initWithCapacity:6];
    NSLayoutConstraint *constraint;
    constraint = [NSLayoutConstraint constraintWithItem:self.view
                                              attribute:NSLayoutAttributeWidth
                                              relatedBy:NSLayoutRelationEqual
                                                 toItem:blurView
                                              attribute:NSLayoutAttributeWidth
                                             multiplier:1.0f constant:0];
    [constraints addObject:constraint];
    
    constraint = [NSLayoutConstraint constraintWithItem:self.view
                                              attribute:NSLayoutAttributeHeight
                                              relatedBy:NSLayoutRelationEqual
                                                 toItem:blurView attribute:NSLayoutAttributeHeight
                                             multiplier:1.0f constant:0];
    [constraints addObject:constraint];

    [self.view addConstraints:constraints];
}

#pragma mark - Methdos
- (void)configureSecondCall {
    WebRTCCall *webrtcCall = [_webRTCController getActiveWebRTCCall];
    if (webrtcCall) {
        [self.secondCallL setHidden:false];
        std::string callId    = [webrtcCall.callId cStringWebRTC];
        WebRTC::mavInstance().mavCallHold(callId, false);
        NSLog(@"CallerVC::configureSecondCall  mavCallHold: callId: %@   callUUID: %@", webrtcCall.callId, [webrtcCall.callUUID UUIDString]);
        webrtcCall.state = WebRTCCallStateHold;
        
        // When first call is holded, this block of code will be executed immediately.
        secondCallBlock = ^{
            std::string callie       = [_secondtargetMsisdn cStringWebRTC];
            std::string caller       = [_caller cStringWebRTC];
            std::string secondCallId = [@"" cStringWebRTC];

            WebRTC::mavInstance().mavCallStart(callie, secondCallId, false, WEBRTC_AUDIO_WIRED_HEADSET, caller);
            NSString *ns_secondCallId = [NSString stringWithUTF8String:secondCallId.c_str()];
        
            WebRTCCall *webrtcCall = [[WebRTCCall alloc] initWith:ns_secondCallId msisdn:_caller callee:_secondtargetMsisdn outgoing:true];
            [_webRTCController addWebRTCCall:webrtcCall];
            [[CallManager sharedManager] startCall:_secondtargetMsisdn videoEnabled:false webrtcCall:webrtcCall];
        };
    }
}

#pragma mark - Actions
- (IBAction)decline_Action:(UIButton *)sender {
    if (self.delegate) {
        [self.delegate callDeclined];
    }
    
    [self dismissViewControllerAnimated:true completion:nil];
}

- (IBAction)hold_Action:(id)sender {
    UIButton *btn = (UIButton *)sender;
    NSString *text = btn.titleLabel.text;
    
    // TODO: Baris - This need to be checked cause it needs to be removed where call is end.
    if ([_webRTCController calls].count > 1) {
        WebRTCCall *firstOne = [[_webRTCController calls] firstObject];
        NSLog(@"************************* Removed One => CallerVC::hold_Action: CallID = %@", firstOne.callId);
        [[_webRTCController calls] removeObjectAtIndex:0];
    }
    
    WebRTCCall *webrtcCall = [[_webRTCController calls] firstObject];
    if (webrtcCall) {
        if ([text isEqualToString:@"Hold"]) {
            std::string c_callId = [webrtcCall.callId cStringWebRTC];
            WebRTC::mavInstance().mavCallHold(c_callId, true);
            [btn setTitle:@"Resume" forState:UIControlStateNormal];
            webrtcCall.state = WebRTCCallStateHold;
            
            Call *call = [[CallManager sharedManager] callWithUUID:webrtcCall.callUUID];
            NSLog(@"************************* CallerVC::hold_Action: CallID = %@ callUUID: %@", webrtcCall.callId, [call.uuid UUIDString]);
        }else if ([text isEqualToString:@"Resume"]) {
            
            std::string c_callId = [webrtcCall.callId cStringWebRTC];
            WebRTC::mavInstance().mavCallUnhold(c_callId);
            [btn setTitle:@"Hold" forState:UIControlStateNormal];
            webrtcCall.state = WebRTCCallStateActive;
            
            Call *call = [[CallManager sharedManager] callWithUUID:webrtcCall.callUUID];
            NSLog(@"************************* CallerVC::unHold_Action: CallID = %@ callUUID: %@", webrtcCall.callId, [call.uuid UUIDString]);
        }
    }
}

- (IBAction)mute_Action:(id)sender {
    UIButton *btn = (UIButton *)sender;
    NSString *text = btn.titleLabel.text;
    
    WebRTCCall *webrtcCall = [[_webRTCController calls] firstObject];
    if (webrtcCall) {
        if ([text isEqualToString:@"Mute"]) {
            std::string c_callId = [webrtcCall.callId cStringWebRTC];
            WebRTC::mavInstance().mavCallMute(c_callId);
            [btn setTitle:@"Unmute" forState:UIControlStateNormal];

            Call *call = [[CallManager sharedManager] callWithUUID:webrtcCall.callUUID];
            if (call) {
                call.state = CallStateActive;
                [[CallManager sharedManager] setMute:call isMuted:true];
            }
            
        }else if ([text isEqualToString:@"Unmute"]) {
            std::string c_callId = [webrtcCall.callId cStringWebRTC];
            WebRTC::mavInstance().mavCallUnMute(c_callId);
            [btn setTitle:@"Mute" forState:UIControlStateNormal];

            Call *call = [[CallManager sharedManager] callWithUUID:webrtcCall.callUUID];
            if (call) {
                call.state = CallStateActive;
                [[CallManager sharedManager] setMute:call isMuted:false];
            }
        }
    }
}

- (IBAction)addCall_ACtion:(id)sender {
    [self configureSecondCall];
//    [self presentViewController:addressbook animated:true completion:nil];
}

- (IBAction)speaker_Action:(id)sender {
    UIButton *btn = (UIButton *)sender;
    NSString *text = btn.titleLabel.text;
    
    WebRTCCall *webrtcCall = [[_webRTCController calls] firstObject];
    if (webrtcCall) {
        if ([text isEqualToString:@"Speaker"]) {
            std::string c_callId = [webrtcCall.callId cStringWebRTC];
            [btn setTitle:@"Earpiece" forState:UIControlStateNormal];
            [[AudioService sharedManager] switchTo:AudioCallStateSpeaker];
            WebRTC::mavInstance().uccSetAudioOutputDevice(WEBRTC_AUDIO_SPEAKER, [webrtcCall.callId cStringWebRTC]);
            
        }else if ([text isEqualToString:@"Earpiece"]) {
            std::string c_callId = [webrtcCall.callId cStringWebRTC];
            [btn setTitle:@"Speaker" forState:UIControlStateNormal];
            [[AudioService sharedManager] switchTo:AudioCallStateEarPierce];
            WebRTC::mavInstance().uccSetAudioOutputDevice(WEBRTC_AUDIO_EAR_PIECE, [webrtcCall.callId cStringWebRTC]);
        }
    }
}

- (IBAction)dialpad_Action:(id)sender {
    WebRTCCall *webrtcCall = [_webRTCController getActiveWebRTCCall];
    if (webrtcCall) {
        [self.view addSubview:dialpad];
    }
}

#pragma mark - Notifications

-(void)onCallActive_Action:(NSNotification *)userInfo {
    WebRTCCall *webrtcCall = [userInfo.userInfo objectForKey:@"data"];
}

-(void)onCallStatus_Action:(NSNotification *)userInfo {
    WebRTCCall *webrtcCall = [userInfo.userInfo objectForKey:@"data"];
}

-(void)onCallEnd_Action:(NSNotification *)userInfo {
    WebRTCCall *webrtcCall = [userInfo.userInfo objectForKey:@"data"];
}

-(void)onCallReject_Action:(NSNotification *)userInfo {
    WebRTCCall *webrtcCall = [userInfo.userInfo objectForKey:@"data"];
}

-(void)onCallHold_Action:(NSNotification *)userInfo {
    WebRTCCall *webrtcCall = [userInfo.userInfo  objectForKey:@"data"];
    if (secondCallBlock) {
        secondCallBlock();
        secondCallBlock = nil;
    }
}

-(void)onCallAdHocConf_Action:(NSNotification *)userInfo {
    WebRTCCall *webrtcCall = [userInfo.userInfo  objectForKey:@"data"];
    self.constantCallingL.text = @"AdHocCallConf is made!";
    self.secondCallL.text = [NSString stringWithFormat:@"AdHocConf CallID: %@", webrtcCall.callId];
}

- (IBAction)onCallMerge:(id)sender {
    WebRTCCall *webrtcSecondCall = [_webRTCController getActiveWebRTCCall];
    WebRTCCall *webrtcHoldedCall = [_webRTCController getWebRTCCallWithState:WebRTCCallStateHold isOutgoing:true];

    std::string confcallId  = [@"" cStringWebRTC];
    std::string callId      = [webrtcSecondCall.callId cStringWebRTC];
    std::string activeUri   = [webrtcSecondCall.callee cStringWebRTC];
    std::string holdUri     = [webrtcHoldedCall.callee cStringWebRTC];
    std::string lineinfo    = [webrtcSecondCall.msisdn cStringWebRTC];

    WebRTC::mavInstance().mavStartAdHocConf(confcallId, callId, activeUri, holdUri, WEBRTC_AUDIO_EAR_PIECE, lineinfo);
}

-(void)onCallUnhold_Action:(NSNotification *)userInfo {
    WebRTCCall *webrtcCall = [userInfo.userInfo objectForKey:@"data"];
}

#pragma mark - Delegates
#pragma mark - JCDialPadDelegate
-(BOOL)dialPad:(JCDialPad *)dialPad shouldInsertText:(NSString *)text forButtonPress:(JCPadButton *)button {
    if ([text isEqualToString:@"T"]) {
        [dialPad removeFromSuperview];
    }else {
        NSLog(@"Pressed button is: %@", text);
        char digit = [text cStringWebRTC][0];
        WebRTCCall *webrtcCall = [_webRTCController getActiveWebRTCCall];
        if (webrtcCall) {
            WebRTC::mavInstance().mavCallDTMF([webrtcCall.callId cStringWebRTC] , digit);
        }
    }
    return true;
}

#pragma mark - GETTERS & SETTERS
-(NSMutableArray<WebRTCCall *> *)webrtcCalls {
    return self.webRTCController.calls;
}

@end
