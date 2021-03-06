//
//  WebRTCVC.m
//  WebRTC-POC
//
//  Created by BARIS YILMAZ on 02/11/2017.
//  Copyright © 2017 BARIS YILMAZ. All rights reserved.
//

#import <Reachability/Reachability.h>
#import <CoreTelephony/CoreTelephonyDefines.h>
#import <CoreTelephony/CTTelephonyNetworkInfo.h>

#import "WebRTCVC.h"
#import "Call/CallerVC.h"
#import "Call/CallieVC.h"
#import "LogModel.h"
#import "LogTVC.h"
#import "ProviderManager.h"
#import "CallManager.h"
#import "TableViewDelegate.h"
#import "AudioService.h"

#define NSSTRING_TO_STRING(str) [NSString stringWithUTF8String:str.c_str()]
#define NSSTRING_APPEND(str1, str2) [str1 stringByAppendingString:str2]
#define STRING_TO_NSSTRING(str) [NSString stringWithCString:str.c_str() encoding:[NSString defaultCStringEncoding]]

#define kScreenWidth [[UIScreen mainScreen] bounds].size.width
#define kScreenHeight [[UIScreen mainScreen] bounds].size.height

@interface WebRTCVC () <WebRTCiOSDelegate, UIPickerViewDelegate, UIPickerViewDataSource, CallerDelegate, CallieDelegate>
{
    WebRTC *webRTC;
    
    // Delegates
    TableViewDelegate *_tableViewDelegate;
    
    // Widgets
    UIPickerView *authCodePV;
    UIPickerView *msisdnPV;
    UIPickerView *targetMsisdnPV;
    UIPickerView *secondTargetMsisdnPV;
    UIAlertController *alertController;
    
    // Properties
    NSString *_authCode;
    NSString *_msisdn;
    NSString *_targetMsisdn;
    NSString *_secondTargetMsisdn;

    NSString *_sessionInfo;
    NSString *_sessionId;
    NSString *_clientId;
    
    NSArray<NSString *> *authCodes;
    NSArray<NSString *> *msisdnList;
    NSMutableArray<LogModel *> *logs;
    
    NSTimer *timer;
    
    bool onCall;
    bool isWebRTCAvailable;
    bool needReRegister;
    int activeConnectionCount;
    bool isInternetOnline;
}
@end

@implementation WebRTCVC

#pragma mark - Built-in Methods
- (void)viewDidLoad {
    [super viewDidLoad];

    [self initDatas];
    [self initWidgets];
    [self initPickerViews];
    [self initTableView];
    [self initWebRTC];
    [self initReachability];

    [self addNotifications];
    
    _sessionInfo = [self getUserDefaultsWithKey:@"sessionInfo"];
    WEBRTC_STATUS_CODE status;
    if (_sessionInfo) {
        status = WebRTC::mavInstance().mavRegisterAgain([_sessionInfo cStringWebRTC]);
    }
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
}

- (void)addNotifications {
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(applicationWillResignActive:)
                                                 name:UIApplicationWillResignActiveNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(applicationWillEnterForeground:)
                                                 name:UIApplicationWillEnterForegroundNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(applicationDidBecomeActive:)
                                                 name:UIApplicationDidBecomeActiveNotification object:nil];
}

- (void)removeNotifications {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - Init Methods
- (void)initDatas {
    
    self.calls = [[NSMutableArray<WebRTCCall*> alloc] init];
    
    [[ProviderManager sharedManager] setWebrtcController:self];
    logs       = [[NSMutableArray<LogModel *> alloc] init];
    authCodes  = [[NSArray<NSString *> alloc] initWithObjects:@"eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJhdXRoIjoiQmVhcmVyIiwiYWdlbnQiOiJNb3ppbGxhLzUuMCAoV2luZG93cyBOVCA2LjEpIEFwcGxlV2ViS2l0LzUzNy4zNiAoS0hUTUwsIGxpa2UgR2Vja28pIENocm9tZS82NC4wLjMyODIuMTg2IFNhZmFyaS81MzcuMzYiLCJwcm9kdWN0aWQiOiIxIiwidXNlcmlkIjoiNWE5NmJjYjYyNDllYTZiMGVhNWExM2E0IiwidG9rZW5UeXBlIjoxLCJleHAiOjE1MjU4MjgxNTAsImlhdCI6MTUxOTgyODE1MH0.PA4jpdTVMNDOF7ajZuq0X9jhc-vYXIT59ABz2LwVuHE",
                  @"49", @"50", @"56", @"57", @"59", @"eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJhdXRoIjoiQmVhcmVyIiwiYWdlbnQiOiJNb3ppbGxhLzUuMCAoV2luZG93cyBOVCA2LjEpIEFwcGxlV2ViS2l0LzUzNy4zNiAoS0hUTUwsIGxpa2UgR2Vja28pIENocm9tZS82My4wLjMyMzkuMTMyIFNhZmFyaS81MzcuMzYiLCJwcm9kdWN0aWQiOiIxIiwidXNlcmlkIjoiNWE3ZDU4YWIyNDllYTZiMGVhNWEwZDAwIiwidG9rZW5UeXBlIjoxLCJleHAiOjE1MjU3MTYzMzAsImlhdCI6MTUxOTcxNjMzMH0.1tGdMte8oq4ozafozCRaWza5kWxpR5UMIzn3OtlVOOw",
                  nil];
    
    msisdnList = [[NSArray<NSString *> alloc] initWithObjects:
                  @"908502284041@superims.com", @"908502284042@superims.com",
                  @"905390000098@ims.mnc001.mcc286.3gppnetwork.org", @"905390000530@ims.mnc001.mcc286.3gppnetwork.org",
                  @"905390000058@ims.mnc001.mcc286.3gppnetwork.org", @"05390000058@ims.mnc001.mcc286.3gppnetwork.org",
                  @"05332108283@ims.mnc001.mcc286.3gppnetwork.org" , @"905326704476@ims.mnc001.mcc286.3gppnetwork.org",
                  @"905308812074@ims.mnc001.mcc286.3gppnetwork.org", @"905390001903@ims.mnc001.mcc286.3gppnetwork.org",
                  @"05304556754@ims.mnc001.mcc286.3gppnetwork.org" , @"05322106528@ims.mnc001.mcc286.3gppnetwork.org",
                  @"908502290000@ims.mnc001.mcc286.3gppnetwork.org", @"05368657930@ims.mnc001.mcc286.3gppnetwork.org",
                  @"05360760924@ims.mnc001.mcc286.3gppnetwork.org" , @"05332109683@ims.mnc001.mcc286.3gppnetwork.org",
                  @"05398602011@ims.mnc001.mcc286.3gppnetwork.org" , @"05332109203@ims.mnc001.mcc286.3gppnetwork.org",
                  @"05307339475@ims.mnc001.mcc286.3gppnetwork.org" , @"05376306220@ims.mnc001.mcc286.3gppnetwork.org",
                  @"05557090896@ims.mnc001.mcc286.3gppnetwork.org" , @"05322104683@ims.mnc001.mcc286.3gppnetwork.org",
                  nil];
    
    _authCode           = [authCodes objectAtIndex:6];
    _msisdn             = [msisdnList objectAtIndex:18];
    _targetMsisdn       = [msisdnList objectAtIndex:20];
    _secondTargetMsisdn = [msisdnList objectAtIndex:19];
    
    self.authCodeTF.text           = _authCode;
    self.msisdnTF.text             = _msisdn;
    self.targetMsisdnTF.text       = _targetMsisdn;
    self.secondTargetMsisdnTF.text = _secondTargetMsisdn;
    needReRegister    = false;
    isWebRTCAvailable = false;
    onCall            = false;
    
    self.logTV.tableFooterView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, 1.0f)];
}

- (void)initWidgets {
    self.statusIcon.layer.cornerRadius  = self.statusIcon.layer.frame.size.width / 2;
    self.statusIcon.layer.masksToBounds = true;
    self.callBtn.layer.cornerRadius     = 6.0f;
    self.callBtn.layer.masksToBounds    = true;
}

- (void)initPickerViews {
    [self initAuthCodePickerView];
    [self initMsisdnPickerView];
    [self initTargetMsisdnPickerView];
    [self initSecondTargetMsisdnPickerView];
}

- (void)initAuthCodePickerView {
    authCodePV                         = [[UIPickerView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 216.0f)];
    authCodePV.delegate                = self;
    authCodePV.dataSource              = self;
    self.authCodeTF.inputView          = authCodePV;
    self.authCodeTF.inputAccessoryView = [self getNewToolbar];
}

- (void)initMsisdnPickerView {
    msisdnPV                         = [[UIPickerView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 216.0f)];
    msisdnPV.delegate                = self;
    msisdnPV.dataSource              = self;
    self.msisdnTF.inputView          = msisdnPV;
    self.msisdnTF.inputAccessoryView = [self getNewToolbar];
}

- (void)initTargetMsisdnPickerView {
    targetMsisdnPV                         = [[UIPickerView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 216.0f)];
    targetMsisdnPV.delegate                = self;
    targetMsisdnPV.dataSource              = self;
    self.targetMsisdnTF.inputView          = targetMsisdnPV;
    self.targetMsisdnTF.inputAccessoryView = [self getNewToolbar];
}

- (void)initSecondTargetMsisdnPickerView {
    secondTargetMsisdnPV                         = [[UIPickerView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 216.0f)];
    secondTargetMsisdnPV.delegate                = self;
    secondTargetMsisdnPV.dataSource              = self;
    self.secondTargetMsisdnTF.inputView          = secondTargetMsisdnPV;
    self.secondTargetMsisdnTF.inputAccessoryView = [self getNewToolbar];
}

- (void)initTableView {
    _tableViewDelegate            = [[TableViewDelegate alloc] init];
    _tableViewDelegate.logs       = logs;
    
    self.logTV.delegate           = _tableViewDelegate;
    self.logTV.dataSource         = _tableViewDelegate;
    self.logTV.layer.cornerRadius = 6.0;
    self.logTV.layer.borderWidth  = 2.0;
    self.logTV.layer.borderColor  = [UIColor darkGrayColor].CGColor;
}

- (void)initReachability {
    Reachability *reach = [Reachability reachabilityWithHostName:@"www.google.com"];

    static bool isInternetGoneFirst = false;
    reach.reachableBlock = ^(Reachability *reachability) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (isInternetGoneFirst) {
                [self addLog:@"Internet if online."];
                if (_sessionInfo) {
                    std::string sessionInfo  = [_sessionInfo cStringWebRTC];
                    if (isInternetOnline == false) {
                        WebRTC::mavInstance().mavRegisterAgain(sessionInfo);
                    }
                }else {
                    if (isInternetOnline == false) {
                        [self registerWebRTC];
                    }
                }
            }
            isInternetOnline = true;
        });
    };

    reach.unreachableBlock = ^(Reachability *reachability) {
        dispatch_async(dispatch_get_main_queue(), ^{
            isInternetOnline = false;
            [self setWebRTCStatus:false];
            isInternetGoneFirst = true;
            WebRTCCall *webrtcCall = [self getFirstWebRTCCall];
            if (webrtcCall) {
                webrtcCall.state = WebRTCCallStateEndPending;
                WebRTC::mavInstance().mavCallEnd([webrtcCall.callId cStringWebRTC]);
                if (self.presentedViewController) {
                    [self.presentedViewController dismissViewControllerAnimated:true completion:nil];
                }
                NSArray<Call*> *calls = [[CallManager sharedManager] getCalls];
                if (calls) {
                    for (Call* call in calls) {
                        [[CallManager sharedManager] endCall:call];
                    }
                }
            }
            [self addLog:@"Internet if offline."];
        });
    };

    [reach startNotifier];
}

- (void)showAlertWithMessage:(NSString *)message {
    alertController = [UIAlertController alertControllerWithTitle:@"Warning" message:message preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *action = [UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
    }];
    
    [alertController addAction:action];
    [self presentViewController:alertController animated:true completion:nil];
}

- (UIToolbar *)getNewToolbar {
    UIToolbar *toolBar          = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 44.0f)];
    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithTitle:@"Done"
                                                                   style:UIBarButtonItemStylePlain
                                                                  target:self
                                                                  action:@selector(doneButtonTaped_Action)];
    [doneButton setTitleTextAttributes:@{NSFontAttributeName:[UIFont boldSystemFontOfSize:17]} forState:UIControlStateNormal];
    UIBarButtonItem *fixedSpace            = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    UIBarButtonItem *flexibleSpace         = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    NSArray<UIBarButtonItem *> *barButtons = @[flexibleSpace, fixedSpace, doneButton];
    toolBar.items                          = barButtons;
    
    return toolBar;
}

#pragma mark - WebRTC Framework methods

- (void)initWebRTC {
    WebRTCConfig config;
    config.TurnServerIP = "stun.l.google.com";
    config.TurnServerUDPPort = 19302;
    
    std::string sdkBuildVersionInfo = [@"" cStringWebRTC];
    WEBRTC_STATUS_CODE status = WebRTC::mavInstance().mavInitialize(config, sdkBuildVersionInfo);
    
    NSString *sdkVersion  = [NSString stringWithFormat:@"SDK Build Version: %@", [NSString stringWithCharList:sdkBuildVersionInfo.c_str()]];
    WebRTCiOS *controller = [WebRTCiOS mavGetInstance];
    controller.delegate   = self;
    
    switch (status) {
        case WEBRTC_STATUS_OK:
            [self addLog:@"WebRTC initiated."];
            [self addLog:[NSString stringWithFormat:@"SDK Build Version: %@", sdkVersion]];
            break;
            
        case WEBRTC_STATUS_FAILED:
            [self addLog:@"WebRTC initialization failed!"];
            break;
            
        default:
            break;
    }
}

- (void)registerWebRTC {
    std::string authCode    = [_authCode cStringWebRTC];
    std::string baseURL     = "https://91.93.249.10:8082";
    std::string displayName = "Baris Yilmaz";
    std::string deviceName  = "Baris - iPhone 7";
    std::string msisdn      = [_msisdn cStringWebRTC];
    std::string workline    = "WebRTC worline";
    

    _sessionInfo = [self getUserDefaultsWithKey:@"sessionInfo"];
    WEBRTC_STATUS_CODE status;
    if (_sessionInfo) {
        status = WebRTC::mavInstance().mavRegisterAgain([_sessionInfo cStringWebRTC]);
    }else {
        status = WebRTC::mavInstance().mavRegister(baseURL, // Base URL
                                                   authCode,    // IAM Auth code
                                                   displayName,              // Display name of URI
                                                   deviceName,          // Friendly name used switch device
                                                   msisdn,      // Phone number of device
                                                   workline            // ??? Common workline
                                                   );
    }

    switch (status) {
        case WEBRTC_STATUS_OK:
//            [self addLog:@"WebRTC registration is success!"];
            break;
            
        case WEBRTC_STATUS_NOTACTIVATED:
            [self addLog:@"WebRTC registration not activated!"];
            break;
            
        case WEBRTC_STATUS_OPERATIONFAILED:
            [self addLog:@"WebRTC registration operations is failed!"];
            break;
            
        default:
            break;
    }
}
    
- (void) unregisterWebRTC {
//    WebRTC::mavInstance().mavUnRegister(true);
//    needReRegister = true;
}

#pragma mark - Methods

- (void)navigateToCallerVC {
    self.definesPresentationContext = true;
    CallerVC *vc                    = [[CallerVC alloc] initWithNibName:nil bundle:nil];
    vc.webRTCController             = self;
    vc.delegate                     = self;
    vc.modalPresentationStyle       = UIModalPresentationOverCurrentContext;
    vc.modalTransitionStyle         = UIModalTransitionStyleCrossDissolve;
    
    vc.caller                       = _msisdn;
    vc.secondtargetMsisdn           = _secondTargetMsisdn;
    vc.sessionInfo                  = _sessionInfo;
    
    UINavigationController *navigation = [[UINavigationController alloc] initWithRootViewController:vc];
    [navigation setNavigationBarHidden:true];
    [self presentViewController:navigation animated:true completion:nil];
}

- (void)navigateToCallieVC {
    self.definesPresentationContext = true;
    CallieVC *vc                    = [[CallieVC alloc] initWithNibName:nil bundle:nil];
    vc.delegate                     = self;
    vc.modalPresentationStyle       = UIModalPresentationOverCurrentContext;
    vc.modalTransitionStyle         = UIModalTransitionStyleCrossDissolve;
    [self presentViewController:vc animated:true completion:nil];
}

-(void)setWebRTCStatus:(bool)status {
    if ([NSThread isMainThread]) {
        isWebRTCAvailable = status;
        if (status) {
            self.statusIcon.backgroundColor = [UIColor greenColor];
        }else {
            self.statusIcon.backgroundColor = [UIColor redColor];
        }
    }else {
        dispatch_async(dispatch_get_main_queue(), ^{
            isWebRTCAvailable = status;
            if (status) {
                self.statusIcon.backgroundColor = [UIColor greenColor];
            }else {
                self.statusIcon.backgroundColor = [UIColor redColor];
            }
        });
    }
}
#pragma mark -
#pragma mark - ***** DELEGATE METHODS *****
#pragma mark -
#pragma mark - UIPickerViewDataSource
-(NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1;
}

-(NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    if ([pickerView isEqual:authCodePV]) {
        return [authCodes count];
    }else if ([pickerView isEqual:msisdnPV]){
        return [msisdnList count];
    }else {
        return [msisdnList count];
    }
}

-(CGFloat)pickerView:(UIPickerView *)pickerView widthForComponent:(NSInteger)component {
    return self.view.frame.size.width*(4.0f/5.0f);
}

#pragma mark - UIPickerViewDelegate
-(NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    NSString *title;
    if ([pickerView isEqual:authCodePV]) {
        title = [authCodes objectAtIndex:row];
    }else if ([pickerView isEqual:msisdnPV]) {
        title = [msisdnList objectAtIndex:row];
    }else {
        title = [msisdnList objectAtIndex:row];
    }
    return title;
}

-(void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    if ([pickerView isEqual:authCodePV]) {
        _authCode = [authCodes objectAtIndex:row];
        self.authCodeTF.text = _authCode;
    }else if ([pickerView isEqual:msisdnPV]) {
        _msisdn = [msisdnList objectAtIndex:row];
        self.msisdnTF.text = _msisdn;
    }else if ([pickerView isEqual:targetMsisdnPV]){
        _targetMsisdn = [msisdnList objectAtIndex:row];
        self.targetMsisdnTF.text = _targetMsisdn;
    }else if ([pickerView isEqual:secondTargetMsisdnPV]){
        _secondTargetMsisdn = [msisdnList objectAtIndex:row];
        self.secondTargetMsisdnTF.text = _secondTargetMsisdn;
    }
}

#pragma mark - CallerDelegate
-(void)callDeclined {
    WebRTCCall *webrtcCall = [self getActiveWebRTCCall];
    if (!webrtcCall) {
        webrtcCall = [self getFirstWebRTCCall];
    }

    if (webrtcCall) {
        std::string callId = [webrtcCall.callId cStringWebRTC];
        webrtcCall.state = WebRTCCallStateEndPending;
        WebRTC::mavInstance().mavCallEnd(callId);
        [self addLog:[NSString stringWithFormat:@"WebRTC::mavInstance().mavCallEnd(%@)", webrtcCall.callId]];
    }
}

#pragma mark - CallieDelegate
-(void)callieCallAccepted {
    // No need to implement. There is no such an case in phase 1, getting incaming call from webrtc.
    WebRTCCall *webrtcCall_pending = [self getWebRTCCallWithState:WebRTCCallStatePending isOutgoing:false];
    if (webrtcCall_pending) {
        std::string callId = [webrtcCall_pending.callId cStringWebRTC];
        WebRTC::mavInstance().mavCallAccept(callId, false, WEBRTC_AUDIO_EAR_PIECE);
        webrtcCall_pending.state = WebRTCCallStateActive;
    }
}

-(void)callieCallDeclined {
    // No need to implement. There is no such an case in phase 1, getting incaming call from webrtc.
    WebRTCCall *webrtcCall_pending = [self getWebRTCCallWithState:WebRTCCallStatePending isOutgoing:false];
    if (webrtcCall_pending) {
        std::string callId = [webrtcCall_pending.callId cStringWebRTC];
        WebRTC::mavInstance().mavCallReject(callId);
        [self removeWebRTCCall:webrtcCall_pending];
    }
    
    Call *call = [[CallManager sharedManager] callWithUUID:webrtcCall_pending.callUUID];
    if (call) {
        [[CallManager sharedManager] endCall:call];
    }
}
#pragma mark - Actions
- (IBAction)reconnect_Action:(UIButton *)sender {
    // Initial state registration operation
    [self registerWebRTC];
}

- (IBAction)clearLog_Action:(id)sender {
    [self clearLog];
}

- (IBAction)call_Action:(id)sender {
    if (isWebRTCAvailable) {
        std::string callie    = [_targetMsisdn cStringWebRTC];
        std::string caller    = [_msisdn cStringWebRTC];
        std::string callId    = [@"" cStringWebRTC];
        
        WebRTC::mavInstance().mavCallStart(callie, callId, false, WEBRTC_AUDIO_EAR_PIECE, caller);
        NSString *ns_callId = [NSString stringWithCharList:callId.c_str()];
        WebRTCCall *webrtcCall = [[WebRTCCall alloc] initWith:ns_callId msisdn:_msisdn callee:_targetMsisdn outgoing:true];
        [self addWebRTCCall:webrtcCall];
        
        [[CallManager sharedManager] startCall:_targetMsisdn videoEnabled:false webrtcCall:webrtcCall];
        [self addLog:[NSString stringWithFormat:@"WebRTC::mavInstance().mavCallStart; callId:%@ callUUID: %@", webrtcCall.callId, [webrtcCall.callUUID UUIDString]]];

        [self navigateToCallerVC];
    }else {
        [self showAlertWithMessage:@"WebRTC is not available!"];
    }
}

- (void)doneButtonTaped_Action {
    [self.authCodeTF resignFirstResponder];
    [self.msisdnTF resignFirstResponder];
    [self.targetMsisdnTF resignFirstResponder];
    [self.secondTargetMsisdnTF resignFirstResponder];
}

- (IBAction)unregister_Action:(id)sender {
    WebRTC::mavInstance().mavUnRegister(true);
    _sessionInfo = nil;
    [self setUserDefaultsWithKey:@"sessionInfo" value:nil];
}

#pragma mark - Helpers
-(void)addLog:(NSString *)str {
    dispatch_async(dispatch_get_main_queue(), ^{
        LogModel *model = [[LogModel alloc] init];
        model.log       = str;
        model.date      = [NSDate date];
        [logs addObject:model];
        [self.logTV reloadData];
        [self.logTV scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:logs.count-1 inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:true];
    });
}

- (void)clearLog {
    [logs removeAllObjects];
    [self.logTV reloadData];
}

- (void)setUserDefaultsWithKey:(NSString *)key value:(NSString *)value {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:value forKey:key];
    [defaults synchronize];
}

- (NSString *)getUserDefaultsWithKey:(NSString *)key {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    return (NSString *)[defaults objectForKey:key];
}

- (WebRTCCall *)getActiveWebRTCCall {
    for (WebRTCCall *webRTCCall in self.calls) {
        if (webRTCCall.state == WebRTCCallStateActive) {
            return webRTCCall;
        }
    }
    return nil;
}

- (WebRTCCall *)getWebRTCCallWithState:(WebRTCCallState)state isOutgoing:(BOOL)isOutgoing{
    for (WebRTCCall *call in self.calls) {
        if (call.state == state && call.isOutgoing == isOutgoing) {
            return call;
        }
    }
    
    return nil;
}

- (WebRTCCall *)getWebRTCCallWithCallId:(NSString *)callId{
    for (WebRTCCall *call in self.calls) {
        if ([call.callId isEqualToString:callId]) {
            return call;
        }
    }
    
    return nil;
}

- (WebRTCCall *)getWebRTCCallWithCallUUID:(NSString *)callUUID {
    for (WebRTCCall *call in self.calls) {
        if ([[call.callUUID UUIDString] isEqualToString:callUUID]) {
            return call;
        }
    }
    
    return nil;
}

- (WebRTCCall *)getFirstWebRTCCall {
    return [self.calls firstObject];
}

- (void)addWebRTCCall:(WebRTCCall *)call {
    NSLog(@"************************* WebRTCVC::addWebRTCCall: CallId:%@", call.callId);
    [self.calls addObject:call];
}

- (void)removeWebRTCCall:(WebRTCCall *)call {
    NSLog(@"************************* WebRTCVC::removeWebRTCCall: CallId:%@", call.callId);
    [self.calls removeObject:call];
}

- (void)removeAllWebRTCCalls {
    NSLog(@"************************* WebRTCVC::removeAllWebRTCCalls");
    [self.calls removeAllObjects];
    [[CallManager sharedManager] endAllCalls];
}

#pragma mark - Application States
- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    if ([_sessionInfo cStringWebRTC]) {
        std::string sessionInfo  = [_sessionInfo cStringWebRTC];
        std::string nativeline = [_msisdn cStringWebRTC];
        WebRTCCall *webrtcCall = [self getActiveWebRTCCall];
        if (!webrtcCall) {
            if ([[CallManager sharedManager] calls].count <= 0) {
                WEBRTC_STATUS_CODE statusCode = WebRTC::mavInstance().mavRegisterAgain(sessionInfo);
            }
        }
    }
}

- (void)applicationDidBecomeActive:(NSNotification *)notification {
    WebRTCCall *webrtcCall = [self getActiveWebRTCCall];
    if (webrtcCall) {
//        [[AudioService sharedManager] configureAudioSession];
//        [[AudioService sharedManager] startAudio];
    }
}

#pragma mark -
#pragma mark - WebRTCiOSDelegate
#pragma mark Register Operations
- (void)mavOnReceivedRegisterSuccess:(std::string)did fid:(std::string)fid sessionid:(std::string)sessionid clientid:(std::string)clientid {
    _sessionId = [NSString stringWithCharList:sessionid.c_str()];
    _clientId  = [NSString stringWithCharList:clientid.c_str()];
    
//    [self setUserDefaultsWithKey:@"sessionId" value:_sessionId];
    [self addLog:@"WebRTC mavOnReceivedRegisterSuccess!"];
}

-(void)mavOnReceivedReRegisterSuccess:(std::string)did fid:(std::string)fid sessionid:(std::string)sessionid clientid:(std::string)clientid {
    _sessionId = [NSString stringWithCharList:sessionid.c_str()];
    _clientId  = [NSString stringWithCharList:clientid.c_str()];
    
    [self addLog:@"WebRTC mavOnReceivedReRegisterSuccess!"];
}

-(void)mavOnReceivedUnRegisterSuccess {
    [self setWebRTCStatus:false];
    [self addLog:@"WebRTC mavOnReceivedUnRegisterSuccess!"];
}

-(void)mavOnReceivedSessionInfo:(std::string)session_info {
    [self setUserDefaultsWithKey:@"sessionInfo" value:[NSString stringWithCharList:session_info.c_str()]];
    _sessionInfo = [NSString stringWithCharList:session_info.c_str()];
    [self setWebRTCStatus:true];
    [self addLog:@"WebRTC mavOnReceivedSessionInfo!"];
}

-(void)mavOnReceivedSessionExpired {
    [self setWebRTCStatus:false];
    [self addLog:@"WebRTC mavOnReceivedSessionExpired!"];
    
    if (self.presentedViewController) {
        [self.presentedViewController dismissViewControllerAnimated:true completion:nil];
    }
    std::string sessionId  = [_sessionId cStringWebRTC];
    std::string nativeline = [_msisdn cStringWebRTC];
    
    WEBRTC_STATUS_CODE statusCode = WebRTC::mavInstance().mavReRegister(sessionId, nativeline);
    [self removeAllWebRTCCalls];
}

-(void)mavOnReceivedRegisterError:(int)responsecode errorcode:(int)errorcode {
    [self setWebRTCStatus:false];
    [self addLog:[NSString stringWithFormat:@"WebRTC mavOnReceivedRegisterError responseCode: %d errorCode: %d!", responsecode, errorcode]];
    
    if (self.presentedViewController) {
        [self.presentedViewController dismissViewControllerAnimated:true completion:nil];
    }
    [self removeAllWebRTCCalls];
}

-(void)mavOnReceivedTransportError:(std::string)transport_error {
    [self setWebRTCStatus:false];
    [self addLog:[NSString stringWithFormat:@"WebRTC mavOnReceivedTransportError transport_error: %@", [NSString stringWithCharList:transport_error.c_str()]]];
    
    if (self.presentedViewController) {
        [self.presentedViewController dismissViewControllerAnimated:true completion:nil];
    }
    [self removeAllWebRTCCalls];;
}

#pragma mark Call Operations
- (void)mavOnReceivedNewCall:(std::string)uri callid:(std::string)callid LineInfo:(std::string)LineInfo {
    [self addLog: [NSString stringWithFormat:@"WebRTC mavOnReceivedNewCall! uri: %@ callid: %@ LineInfo: %@",
                    [NSString stringWithCharList:uri.c_str()],
                    [NSString stringWithCharList:callid.c_str()],
                    [NSString stringWithCharList:LineInfo.c_str()] ]];
    
    NSString *callId = [NSString stringWithCharList:callid.c_str()];
    NSString *callee = [NSString stringWithCharList:LineInfo.c_str()];
    NSString *msisdn = [NSString stringWithCharList:uri.c_str()];
    
    WebRTCCall *webrtcCall = [[WebRTCCall alloc] initWith:callId msisdn:msisdn callee:callee outgoing:false];
    [self addWebRTCCall:webrtcCall];
    
    NSLog(@"************************* mavOnReceivedNewCall");
//    [self navigateToCallieVC];
}

-(void)mavOnReceivedCallActive:(std::string)callid {

    NSString *callId = [NSString stringWithCharList:callid.c_str()];
    WebRTCCall *webrtcCall = [self getWebRTCCallWithCallId:callId];
    if (webrtcCall) {
        webrtcCall.state = WebRTCCallStateActive;
    }
    Call *call = [[CallManager sharedManager] callWithUUID:webrtcCall.callUUID];
    if (call) {
        [call answer];
    }
    
    NSLog(@"-(void)mavOnReceivedCallActive:(std::string)callid: %@  callUUID: %@ ", [NSString stringWithCharList:callid.c_str()], [call.uuid UUIDString]);
    [self addLog: [NSString stringWithFormat:@"WebRTC mavOnReceivedCallActive! callid: %@  callUUID: %@", [NSString stringWithCharList:callid.c_str()], [call.uuid UUIDString]]];
    
//    [[AudioService sharedManager] startAudio];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"CallActive" object:nil userInfo:@{@"data": webrtcCall}];
    NSLog(@"************************* mavOnReceivedCallActive");
}

// Called for all call flow response
-(void)mavOnReceivedCallStatus:(std::string)callid statuscode:(int)statuscode {
    NSString *theCallId = [NSString stringWithUTF8String:callid.c_str()];
    WebRTCCall *webrtcCall = [self getWebRTCCallWithCallId:theCallId];

    // Ringing
    if (statuscode == 183) {
        Call *call = [[CallManager sharedManager] callWithUUID:webrtcCall.callUUID];
        if (call) {
            call.connectionState = ConnectedStatePending;
            call.connectedStateChanged();
        }
        NSLog(@"************************* StatusCode = 183");
    }
    
    // Ringing
    else if (statuscode == 180) {
        Call *call = [[CallManager sharedManager] callWithUUID:webrtcCall.callUUID];
        if (call) {
            call.connectionState = ConnectedStatePending;
            call.connectedStateChanged();
        }
        NSLog(@"************************* StatusCode = 180");
    }
    
    // Call accepted.
    else if (statuscode == 200) {
        webrtcCall.state = WebRTCCallStateActive;
        
        Call *call = [[CallManager sharedManager] getCallWithCallId:theCallId];
        if (call) {
            call.connectionState = ConnectedStateComplete;
            call.connectedStateChanged();
        }
        NSLog(@"************************* StatusCode = 200");
    }

    // Call ended.
    else if (statuscode == 204) {
        NSString *theCallId = [NSString stringWithCharList:callid.c_str()];
        WebRTCCall *webrtcCall = [self getWebRTCCallWithCallId:theCallId];
        if (webrtcCall && webrtcCall.state == WebRTCCallStateEndPending) {
            [self removeWebRTCCall:webrtcCall];
            Call *call = [[CallManager sharedManager] callWithUUID:webrtcCall.callUUID];
            if (call) {
                NSLog(@"mavOnReceivedCallEnd: Call class to be ended. callId: %@ callUUID: %@", call.callId, [call.uuid UUIDString]);
                [[CallManager sharedManager] endCall:call];
            }
            
            [self addLog: [NSString stringWithFormat:@"WebRTC mavOnReceivedCallEnd! callid: %@", [NSString stringWithCharList:callid.c_str()] ]];
            for (WebRTCCall *theCall in self.calls) {
                NSLog(@"mavOnReceivedCallEnd: After an call is ended from other side. CallId: %@  callUUID: %@ CallStatus: %lu", theCall.callId, [call.uuid UUIDString], (unsigned long)theCall.state);
                // If there is an holded call session, unhold it.
                if (theCall.state == WebRTCCallStateHold) {
                    WebRTC::mavInstance().mavCallUnhold([theCall.callId cStringWebRTC]);
                }
            }
            [[NSNotificationCenter defaultCenter] postNotificationName:@"CallEnd" object:nil userInfo:@{@"data": webrtcCall}];
        }else {
            NSLog(@"mavOnReceivedCallStatus::status callId: %@ will be ended in 'mavOnReceivedCallEnd' method", webrtcCall.callId);
        }

        NSLog(@"************************* StatusCode = 204");
        [self addLog: [NSString stringWithFormat:@"Call ended with StatusCode = 204 callId: %@  callee: %@", webrtcCall.callId, webrtcCall.callee]];
    }
    
    // Unknown
    else if (statuscode == 405) {
        if (self.presentedViewController) {
            [self.presentedViewController dismissViewControllerAnimated:true completion:nil];
        }
        NSLog(@"************************* StatusCode = 405");
    }
    
    // Unknown
    else if (statuscode == 500) {
        if (self.presentedViewController) {
            [self.presentedViewController dismissViewControllerAnimated:true completion:nil];
        }
        NSLog(@"************************* StatusCode = 500");
    }
    
    // Sure it is error
    if (statuscode >= 300) {
        NSString *theCallId = [NSString stringWithCharList:callid.c_str()];
        WebRTCCall *webrtcCall = [self getWebRTCCallWithCallId:theCallId];
        if (webrtcCall && webrtcCall.state == WebRTCCallStatePending) {
            [self removeWebRTCCall:webrtcCall];
            Call *call = [[CallManager sharedManager] callWithUUID:webrtcCall.callUUID];
            if (call) {
                NSLog(@"mavOnReceivedCallEnd: Call class to be ended. callId: %@ callUUID: %@", call.callId, [call.uuid UUIDString]);
                [[CallManager sharedManager] endCall:call];
            }
            
            [self addLog: [NSString stringWithFormat:@"WebRTC mavOnReceivedCallEnd! callid: %@", [NSString stringWithCharList:callid.c_str()] ]];
            for (WebRTCCall *theCall in self.calls) {
                NSLog(@"mavOnReceivedCallEnd: After an call is ended from other side. CallId: %@  callUUID: %@ CallStatus: %lu", theCall.callId, [call.uuid UUIDString], (unsigned long)theCall.state);
                // If there is an holded call session, unhold it.
                if (theCall.state == WebRTCCallStateHold) {
                    WebRTC::mavInstance().mavCallUnhold([theCall.callId cStringWebRTC]);
                }
            }
            [[NSNotificationCenter defaultCenter] postNotificationName:@"CallEnd" object:nil userInfo:@{@"data": webrtcCall}];
        }else {
            NSLog(@"mavOnReceivedCallStatus::status callId: %@ will be ended in 'mavOnReceivedCallEnd' method", webrtcCall.callId);
        }
        
        if (self.presentedViewController) {
            [self.presentedViewController dismissViewControllerAnimated:true completion:nil];
            NSLog(@"************************* StatusCode >= 300 - General Error.");
        }
    }
    
    Call *call = [[CallManager sharedManager] callWithUUID:webrtcCall.callUUID];
    if (call) {
        call.connectionState = ConnectedStatePending;
        call.connectedStateChanged();
        [self addLog: [NSString stringWithFormat:@"WebRTC mavOnReceivedCallStatus! callid: %@ callUUID: %@ statusCode: %d", [NSString stringWithCharList:callid.c_str()],[call.uuid UUIDString], statuscode]];
    }else {
        [self addLog: [NSString stringWithFormat:@"WebRTC mavOnReceivedCallStatus! callid: %@ statusCode: %d", [NSString stringWithCharList:callid.c_str()], statuscode]];
    }
    
}

// Benim yaptığım hold sonucunda çağırılıyor
-(void)mavOnCallHoldStatus:(std::string)callid status:(std::string)status {
    NSString *callId = [NSString stringWithCharList:callid.c_str()];
    WebRTCCall *webrtcCall = [self getWebRTCCallWithCallId:callId];

    Call *call = [[CallManager sharedManager] callWithUUID:webrtcCall.callUUID];
    NSLog(@"************************* mavOnCallHoldStatus callId: %@  callUUID:%@ StatusCode = %@", callId, [call.uuid UUIDString], [NSString stringWithCharList:status.c_str()]);
    
    if (call) {
        call.state = CallStateHeld;
            [[CallManager sharedManager] setHeld:call onHold:true];
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"CallHold" object:nil userInfo:@{@"data": webrtcCall}];
}

// Benim yaptığım hold sonucunda çağırılıyor
-(void)mavOnCallUnHoldStatus:(std::string)callid status:(std::string)status {
    NSLog(@"************************* mavOnCallUnHoldStatus StatusCode = %@", [NSString stringWithCharList:status.c_str()]);
    
    NSString *callId = [NSString stringWithCharList:callid.c_str()];
    WebRTCCall *webrtcCall = [self getWebRTCCallWithCallId:callId];

    Call *call = [[CallManager sharedManager] callWithUUID:webrtcCall.callUUID];
    NSLog(@"************************* mavOnCallUnHoldStatus callId: %@  callUUID:%@ StatusCode = %@", callId, [call.uuid UUIDString], [NSString stringWithCharList:status.c_str()]);
    
    if (call) {
        call.state = CallStateActive;
        [[CallManager sharedManager] setHeld:call onHold:false];
    }

    [[NSNotificationCenter defaultCenter] postNotificationName:@"CallUnHold" object:nil userInfo:@{@"data": webrtcCall}];
}

// Kendim end yaparsam çağırılıyor
-(void)mavOnReceivedCallEnd:(std::string)callid {
    NSLog(@"************************* mavOnReceivedCallEnd");
    NSString *theCallId = [NSString stringWithCharList:callid.c_str()];
    WebRTCCall *webrtcCall = [self getWebRTCCallWithCallId:theCallId];
    if (webrtcCall) {
        [self removeWebRTCCall:webrtcCall];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"CallEnd" object:nil userInfo:@{@"data": webrtcCall}];
    }
    
    Call *call = [[CallManager sharedManager] callWithUUID:webrtcCall.callUUID];
    if (call) {
        NSLog(@"mavOnReceivedCallEnd: Call class to be ended. callId: %@ callUUID: %@", call.callId, [call.uuid UUIDString]);
        [[CallManager sharedManager] endCall:call];
    }
    
    [self addLog: [NSString stringWithFormat:@"WebRTC mavOnReceivedCallEnd! callid: %@", [NSString stringWithCharList:callid.c_str()] ]];
    for (WebRTCCall *theCall in self.calls) {
        NSLog(@"mavOnReceivedCallEnd: After an call is ended from other side. CallId: %@  callUUID: %@ CallStatus: %lu", theCall.callId, [call.uuid UUIDString], (unsigned long)theCall.state);
        if (theCall.state == WebRTCCallStateHold) {
            WebRTC::mavInstance().mavCallUnhold([theCall.callId cStringWebRTC]);
        }
    }

    if (self.calls.count <= 0) {
        if (self.presentedViewController) {
            [self.presentedViewController dismissViewControllerAnimated:true completion:nil];
        }
    }
}

-(void)mavOnReceivedCallRejected:(std::string)callid {
    NSLog(@"************************* mavOnReceivedCallRejected");
    [self addLog: [NSString stringWithFormat:@"WebRTC mavOnReceivedCallRejected! callid: %@", [NSString stringWithCharList:callid.c_str()] ]];
    
    NSString *callId = [NSString stringWithCharList:callid.c_str()];
    WebRTCCall *webrtcCall = [self getWebRTCCallWithCallId:callId];
    if (webrtcCall) {
        [self removeWebRTCCall:webrtcCall];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"CellRejected" object:nil userInfo:@{@"data": webrtcCall}];
    }
    

    Call *call = [[CallManager sharedManager] callWithUUID:webrtcCall.callUUID];
    if (call) {
        NSLog(@"mavOnReceivedCallRejected: Call class to be rejected. callId: %@ calUUID: %@", call.callId, [call.uuid UUIDString]);
        [[CallManager sharedManager] endCall:call];
    }
    
    if (self.presentedViewController) {
        [self.presentedViewController dismissViewControllerAnimated:true completion:nil];
    }
}

// Birisi beni hold a aldığında cagırılıyor
-(void)mavOnReceivedCallHold:(std::string)callid {
    [self addLog: [NSString stringWithFormat:@"WebRTC mavOnReceivedCallHold! callId: %@", [NSString stringWithCharList:callid.c_str()] ]];
    
    NSString *callId = [NSString stringWithCharList:callid.c_str()];
    WebRTCCall *webrtcCall = [self getWebRTCCallWithCallId:callId];
    if (webrtcCall) {
        webrtcCall.state = WebRTCCallStateHold;
        [[NSNotificationCenter defaultCenter] postNotificationName:@"CallHold" object:nil userInfo:@{@"data": webrtcCall}];
    }
    
    Call *call = [[CallManager sharedManager] callWithUUID:webrtcCall.callUUID];
    if (call) {
        NSLog(@"mavOnReceivedCallHold: Call class to be holded. callId: %@ calUUID: %@", call.callId, [call.uuid UUIDString]);
    }
    NSLog(@"************************* mavOnReceivedCallHold");
}

// Birisi beni unhold a aldığında cagırılıyor
-(void)mavOnReceivedCallUnhold:(std::string)callid {
    [self addLog: [NSString stringWithFormat:@"WebRTC mavOnReceivedCallUnhold! callid: %@", [NSString stringWithCharList:callid.c_str()] ]];
    
    NSString *callId = [NSString stringWithCharList:callid.c_str()];
    WebRTCCall *webrtcCall = [self getWebRTCCallWithCallId:callId];
    if (webrtcCall) {
        webrtcCall.state = WebRTCCallStateActive;
        [[NSNotificationCenter defaultCenter] postNotificationName:@"CallUnhold" object:nil userInfo:@{@"data": webrtcCall}];
    }
    
    Call *call = [[CallManager sharedManager] callWithUUID:webrtcCall.callUUID];
    if (call) {
        NSLog(@"mavOnReceivedCallUnhold: Call class to be unholded. callId: %@ calUUID: %@", call.callId, [call.uuid UUIDString]);
    }
    NSLog(@"************************* mavOnReceivedCallUnhold");
}

-(void)mavOnAdHocConfStatus:(std::string)callid status:(std::string)status {
    [self addLog: [NSString stringWithFormat:@"WebRTC mavOnAdHocConfStatus! callid: %@  status: %@", [NSString stringWithCharList:callid.c_str()], [NSString stringWithCharList:status.c_str()] ]];
    
    
    NSArray *calls = [[CallManager sharedManager] calls];
    Call *firstCall = calls.firstObject;
    Call *secondCall = calls[1];
    
//    for (WebRTCCall *webrtcCall in self.calls) {
//        NSLog(@"\n\n\n\n -- AD_HOC_CONF Operation is started -- \n");
//        Call *call = [[CallManager sharedManager] callWithUUID:webrtcCall.callUUID];
//        if (call) {
//            NSLog(@"************************* mavOnAdHocConfStatus:: Call ended with callUUID: %@", [call.uuid UUIDString]);
//        }
//        NSLog(@"************************* mavOnAdHocConfStatus:: mavCallEnd callId: %@", webrtcCall.callId);
//        webrtcCall.state = WebRTCCallStateEndPending;
//        WebRTC::mavInstance().mavCallEnd([webrtcCall.callId cStringWebRTC]);
//    }

    
    [[CallManager sharedManager] setGroup:firstCall mergeCall:secondCall];
    NSString *ns_callId = [NSString stringWithCharList:callid.c_str()];
    WebRTCCall *webrtcCall = [[WebRTCCall alloc] initWith:ns_callId msisdn:_msisdn callee:_targetMsisdn outgoing:true];
    [[CallManager sharedManager] startCall:_targetMsisdn videoEnabled:false webrtcCall:webrtcCall];
    [self addWebRTCCall:webrtcCall];
    if (webrtcCall) {
        webrtcCall.state = WebRTCCallStateActive;
        [[NSNotificationCenter defaultCenter] postNotificationName:@"AdHocConf" object:nil userInfo:@{@"data": webrtcCall}];
    }
    [self addLog:[NSString stringWithFormat:@"mavOnAdHocConfStatus::WebRTC::mavInstance().mavCallStart; callId:%@ callUUID: %@", webrtcCall.callId, [webrtcCall.callUUID UUIDString]]];
    
    // TODO: Baris -
    NSLog(@"************************* mavOnAdHocConfStatus");
    NSLog(@"*********************************\n\n");
    NSLog(@"AdHocConf CallId: %@", ns_callId);
}
-(void)OnMavUnRegisterStatus:(bool)status {
    NSLog(@"OnMavUnRegisterStatus status: %d", status);
    [self setWebRTCStatus:false];
    [self addLog:@"WebRTC OnMavUnRegisterStatus!"];

    [self removeAllWebRTCCalls];
}

@end
