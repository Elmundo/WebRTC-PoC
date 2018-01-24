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
    NSString *_callId;
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
    if (_callId) {
        [self.secondCallL setHidden:false];
        std::string callId    = [_callId cStringWebRTC];
        WebRTC::mavInstance().mavCallHold(callId, false);
        secondCallBlock = ^{
            std::string callie    = [_secondtargetMsisdn cStringWebRTC];
            std::string caller    = [_caller cStringWebRTC];
            std::string dynamicId = [_sessionId cStringWebRTC];
            std::string callId    = [_callId cStringWebRTC];
            
            WebRTC::mavInstance().mavCallStart(callie, dynamicId, false, WEBRTC_AUDIO_WIRED_HEADSET, caller);
            [[CallManager sharedManager] startCall:_secondtargetMsisdn videoEnabled:false];
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
    
    if ([text isEqualToString:@"Hold"]) {
        if (_callId) {
            std::string c_callId = [_callId cStringWebRTC];
            WebRTC::mavInstance().mavCallHold(c_callId, true);
            [btn setTitle:@"Resume" forState:UIControlStateNormal];
            
            Call *call = [[CallManager sharedManager] getActiveCall];
            call.state = CallStateHeld;
            [[CallManager sharedManager] setHeld:call onHold:true];
        }
    }else if ([text isEqualToString:@"Resume"]) {
        if (_callId) {
            std::string c_callId = [_callId cStringWebRTC];
            WebRTC::mavInstance().mavCallUnhold(c_callId);
            [btn setTitle:@"Hold" forState:UIControlStateNormal];
            
            Call *call = [[CallManager sharedManager] getActiveCall];
            call.state = CallStateActive;
            [[CallManager sharedManager] setHeld:call onHold:false];
        }
    }
}

- (IBAction)mute_Action:(id)sender {
    UIButton *btn = (UIButton *)sender;
    NSString *text = btn.titleLabel.text;
    
    if ([text isEqualToString:@"Mute"]) {
        if (_callId) {
            std::string c_callId = [_callId cStringWebRTC];
            WebRTC::mavInstance().mavCallMute(c_callId);
            [btn setTitle:@"Unmute" forState:UIControlStateNormal];
            
            Call *call = [[CallManager sharedManager] getActiveCall];
            call.state = CallStateActive;
            [[CallManager sharedManager] setHeld:call onHold:false];
        }
        
    }else if ([text isEqualToString:@"Unmute"]) {
        if (_callId) {
            std::string c_callId = [_callId cStringWebRTC];
            WebRTC::mavInstance().mavCallUnMute(c_callId);
            [btn setTitle:@"Mute" forState:UIControlStateNormal];
            
            Call *call = [[CallManager sharedManager] getActiveCall];
            call.state = CallStateActive;
            [[CallManager sharedManager] setHeld:call onHold:false];
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
    
    if ([text isEqualToString:@"Speaker"]) {
        if (_callId) {
            std::string c_callId = [_callId cStringWebRTC];
        }
        [btn setTitle:@"Earpiece" forState:UIControlStateNormal];
        [[AudioService sharedManager] switchTo:AudioCallStateSpeaker];
        
    }else if ([text isEqualToString:@"Earpiece"]) {
        if (_callId) {
            std::string c_callId = [_callId cStringWebRTC];
        }
        [btn setTitle:@"Speaker" forState:UIControlStateNormal];
        [[AudioService sharedManager] switchTo:AudioCallStateEarPierce];
    }
}

- (IBAction)dialpad_Action:(id)sender {
    if (_callId != nil) {
        [self.view addSubview:dialpad];
    }
}

#pragma mark - Notifications

-(void)onCallActive_Action:(NSNotification *)userInfo {
    _callId = [userInfo.userInfo objectForKey:@"data"];
}

-(void)onCallStatus_Action:(NSNotification *)userInfo {
    _callId = [userInfo.userInfo objectForKey:@"data"];
}

-(void)onCallEnd_Action:(NSNotification *)userInfo {
    _callId = [userInfo.userInfo objectForKey:@"data"];
}

-(void)onCallReject_Action:(NSNotification *)userInfo {
    _callId = [userInfo.userInfo objectForKey:@"data"];
}

-(void)onCallHold_Action:(NSNotification *)userInfo {
    _callId = [userInfo.userInfo  objectForKey:@"data"];
    if (secondCallBlock) {
        secondCallBlock();
        secondCallBlock = nil;
    }
}

-(void)onCallUnhold_Action:(NSNotification *)userInfo {
    _callId = [userInfo.userInfo objectForKey:@"data"];
}

#pragma mark - Delegates
#pragma mark - JCDialPadDelegate
-(BOOL)dialPad:(JCDialPad *)dialPad shouldInsertText:(NSString *)text forButtonPress:(JCPadButton *)button {
    if ([text isEqualToString:@"T"]) {
        [dialPad removeFromSuperview];
    }else {
        NSLog(@"Pressed button is: %@", text);
        char digit = [text cStringWebRTC][0];
        WebRTC::mavInstance().mavCallDTMF([_callId cStringWebRTC] , digit);
    }
    return true;
}

@end
