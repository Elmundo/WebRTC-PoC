//
//  CallerVC.m
//  WebRTC-POC
//
//  Created by BARIS YILMAZ on 17/11/2017.
//  Copyright © 2017 BARIS YILMAZ. All rights reserved.
//

#import <DWAddressBook.h>

#import "CallerVC.h"

@interface CallerVC ()

@end

@implementation CallerVC
{
    NSString *_callId;
    CNContactPickerViewController *contactController;
    DWAddressBook *addressbook;
}
-(void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - Build-in Methods
- (void)viewDidLoad {
    [super viewDidLoad];
    [self initWidgets];
    [self initContactController];
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
        NSLog(@"");
    } failure:^{
        NSLog(@"Contact selection had been failed.");
    }];
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
        }
    }else if ([text isEqualToString:@"Resume"]) {
        if (_callId) {
            std::string c_callId = [_callId cStringWebRTC];
            WebRTC::mavInstance().mavCallUnhold(c_callId);
            [btn setTitle:@"Hold" forState:UIControlStateNormal];
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
        }
        
    }else if ([text isEqualToString:@"Unmute"]) {
        if (_callId) {
            std::string c_callId = [_callId cStringWebRTC];
            WebRTC::mavInstance().mavCallUnMute(c_callId);
            [btn setTitle:@"Mute" forState:UIControlStateNormal];
        }
    }
}

- (IBAction)addCall_ACtion:(id)sender {
    [self presentViewController:addressbook animated:true completion:nil];
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
}

-(void)onCallUnhold_Action:(NSNotification *)userInfo {
    _callId = [userInfo.userInfo objectForKey:@"data"];
}

#pragma mark - Delegates

@end
