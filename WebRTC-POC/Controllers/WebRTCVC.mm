//
//  WebRTCVC.m
//  WebRTC-POC
//
//  Created by BARIS YILMAZ on 02/11/2017.
//  Copyright © 2017 BARIS YILMAZ. All rights reserved.
//

#import <Reachability/Reachability.h>

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
    NSString *_fid;
    NSString *_did;
    NSString *_sessionId;
    NSString *_clientId;
    NSString *_callId;
    NSString *_secondCallId;
    
    NSArray<NSString *> *authCodes;
    NSArray<NSString *> *msisdnList;
    NSMutableArray<LogModel *> *logs;
    NSTimer *timer;
    
    bool onCall;
    bool isWebRTCAvailable;
    bool needReRegister;
    int activeConnectionCount;
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
//    WebRTC::mavInstance().mavUnRegister(true);
    
    [self addNotifications];
    
    _sessionId = [self getUserDefaultsWithKey:@"sessionId"];
    WEBRTC_STATUS_CODE status;
    if (_sessionId) {
        status = WebRTC::mavInstance().mavRegisterAgain([_sessionId cStringWebRTC]);
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
    activeConnectionCount = 0;
    
    logs       = [[NSMutableArray<LogModel *> alloc] init];
    authCodes  = [[NSArray<NSString *> alloc] initWithObjects:@"48", @"49", @"50", @"56", @"57", nil];
    msisdnList = [[NSArray<NSString *> alloc] initWithObjects:
                  @"908502284041@superims.com", @"908502284042@superims.com",
                  @"908502284044@superims.com", @"905390000098@ims.mnc001.mcc286.3gppnetwork.org",
                  @"905390000530@ims.mnc001.mcc286.3gppnetwork.org", @"905390000058@ims.mnc001.mcc286.3gppnetwork.org",
                  @"05390000075@ims.mnc001.mcc286.3gppnetwork.org", @"05390001903@ims.mnc001.mcc286.3gppnetwork.org",
                  @"905322106528@ims.mnc001.mcc286.3gppnetwork.org", nil];
    
    _authCode           = [authCodes objectAtIndex:4];
    _msisdn             = [msisdnList objectAtIndex:7];
    _targetMsisdn       = [msisdnList objectAtIndex:4];
    _secondTargetMsisdn = [msisdnList objectAtIndex:3];
    
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

    reach.reachableBlock = ^(Reachability *reachability) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self addLog:@"Internet if online."];
            std::string sessionId  = [_sessionId cStringWebRTC];
            WebRTC::mavInstance().mavRegisterAgain(sessionId);
        });
    };

    reach.unreachableBlock = ^(Reachability *reachability) {
        dispatch_async(dispatch_get_main_queue(), ^{
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
//    config.TurnServerIP       = "stun:stun2.l.google.com:19302";
//    config.TurnServerUDPPort  = 19302;
    WEBRTC_STATUS_CODE status = WebRTC::mavInstance().mavInitialize(config);
    WebRTCiOS *controller     = [WebRTCiOS mavGetInstance];
    controller.delegate       = self;
    switch (status) {
        case WEBRTC_STATUS_OK:
            [self addLog:@"WebRTC initiated."];
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
    std::string baseURL     = "https://92.45.96.182:8082";
    std::string displayName = "Baris Yilmaz";
    std::string deviceName  = "Baris - iPhone 7";
    std::string msisdn      = [_msisdn cStringWebRTC];
    std::string workline    = "WebRTC worline";
    
//    WEBRTC_STATUS_CODE status = WebRTC::mavInstance().mavRegisterAgain([_sessionId cStringWebRTC]);
    
    _sessionId = [self getUserDefaultsWithKey:@"sessionId"];
    WEBRTC_STATUS_CODE status;
//    if (_sessionId) {
//        status = WebRTC::mavInstance().mavRegisterAgain([_sessionId cStringWebRTC]);
//    }else {
//        status = WebRTC::mavInstance().mavRegister(baseURL, // Base URL
//                                                   authCode,    // IAM Auth code
//                                                   displayName,              // Display name of URI
//                                                   deviceName,          // Friendly name used switch device
//                                                   msisdn,      // Phone number of device
//                                                   workline            // ??? Common workline
//                                                   );
//    }
    
    status= WebRTC::mavInstance().mavRegister(baseURL, // Base URL
                                              authCode,    // IAM Auth code
                                              displayName,              // Display name of URI
                                              deviceName,          // Friendly name used switch device
                                              msisdn,      // Phone number of device
                                              workline            // ??? Common workline
                                              );
    
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
    vc.delegate                     = self;
    vc.modalPresentationStyle       = UIModalPresentationOverCurrentContext;
    vc.modalTransitionStyle         = UIModalTransitionStyleCrossDissolve;
    
    vc.caller                       = _msisdn;
    vc.secondtargetMsisdn           = _secondTargetMsisdn;
    vc.sessionId                    = _sessionId;
    
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
    }else if ([pickerView isEqual:msisdnPV]){
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
    if (_callId) {
        std::string callId = [_callId cStringWebRTC];
        WebRTC::mavInstance().mavCallEnd(callId);
        
        Call *call = [[CallManager sharedManager] getActiveCall];
        [[CallManager sharedManager] endCall:call];
    }
}

#pragma mark - CallieDelegate
-(void)callieCallAccepted {
    if (_callId) {
        std::string callId = [_callId cStringWebRTC];
        WebRTC::mavInstance().mavCallAccept(callId, false, WEBRTC_AUDIO_EAR_PIECE);
    }
}

-(void)callieCallDeclined {
    if (_callId) {
        std::string callId = [_callId cStringWebRTC];
        WebRTC::mavInstance().mavCallReject(callId);
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
        std::string dynamicId = [_sessionId cStringWebRTC];
        
        WebRTC::mavInstance().mavCallStart(callie, dynamicId, false, WEBRTC_AUDIO_WIRED_HEADSET, caller);
        [[CallManager sharedManager] startCall:_targetMsisdn videoEnabled:false];

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

#pragma mark - Application States
- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    NSLog(@"");
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    if ([_sessionId cStringWebRTC]) {
        std::string sessionId  = [_sessionId cStringWebRTC];
        std::string nativeline = [_msisdn cStringWebRTC];
        WEBRTC_STATUS_CODE statusCode = WebRTC::mavInstance().mavRegisterAgain(sessionId);
    }
}

- (void)applicationDidBecomeActive:(NSNotification *)notification {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    NSLog(@"");
}

#pragma mark -
#pragma mark - WebRTCiOSDelegate
#pragma mark Register Operations
- (void)mavOnReceivedRegisterSuccess:(std::string)did fid:(std::string)fid sessionid:(std::string)sessionid clientid:(std::string)clientid {
    _did       = [NSString stringWithCharList:did.c_str()];
    _fid       = [NSString stringWithCharList:fid.c_str()];
    _sessionId = [NSString stringWithCharList:sessionid.c_str()];
    _clientId  = [NSString stringWithCharList:clientid.c_str()];
    
    [self setUserDefaultsWithKey:@"sessionId" value:_sessionId];
    [self addLog:@"WebRTC mavOnReceivedRegisterSuccess!"];
}

-(void)mavOnReceivedReRegisterSuccess:(std::string)did fid:(std::string)fid sessionid:(std::string)sessionid clientid:(std::string)clientid {
    _did       = [NSString stringWithCharList:did.c_str()];
    _fid       = [NSString stringWithCharList:fid.c_str()];
    _sessionId = [NSString stringWithCharList:sessionid.c_str()];
    _clientId  = [NSString stringWithCharList:clientid.c_str()];
    
    [self addLog:@"WebRTC mavOnReceivedReRegisterSuccess!"];
}

-(void)mavOnReceivedUnRegisterSuccess {
//    [self setWebRTCStatus:false];
//    if (needReRegister) {
//        needReRegister = false;
//        [self registerWebRTC];
//    }
//    [self addLog:@"WebRTC mavOnReceivedUnRegisterSuccess!"];
}

-(void)mavOnReceivedSessionInfo:(std::string)session_info {
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
}

-(void)mavOnReceivedRegisterError:(int)responsecode errorcode:(int)errorcode {
    [self setWebRTCStatus:false];
    [self addLog:[NSString stringWithFormat:@"WebRTC mavOnReceivedRegisterError responseCode: %d errorCode: %d!", responsecode, errorcode]];
    
    if (self.presentedViewController) {
        [self.presentedViewController dismissViewControllerAnimated:true completion:nil];
    }
}

-(void)mavOnReceivedTransportError:(std::string)transport_error {
    [self setWebRTCStatus:false];
    [self addLog:[NSString stringWithFormat:@"WebRTC mavOnReceivedTransportError transport_error: %@", [NSString stringWithCharList:transport_error.c_str()]]];
    
    if (self.presentedViewController) {
        [self.presentedViewController dismissViewControllerAnimated:true completion:nil];
    }
}

#pragma mark Call Operations
- (void)mavOnReceivedNewCall:(std::string)uri callid:(std::string)callid LineInfo:(std::string)LineInfo {
    [self addLog: [NSString stringWithFormat:@"WebRTC mavOnReceivedNewCall! uri: %@ callid: %@ LineInfo: %@",
                    [NSString stringWithCharList:uri.c_str()],
                    [NSString stringWithCharList:callid.c_str()],
                    [NSString stringWithCharList:LineInfo.c_str()] ]];
    _callId = [NSString stringWithCharList:callid.c_str()];
    
    CXCallUpdate *update = [[CXCallUpdate alloc] init];
    NSString *handle = [NSString stringWithCharList:uri.c_str()];
    update.remoteHandle = [[CXHandle alloc] initWithType:CXHandleTypePhoneNumber value:handle];
    update.hasVideo = false;

    [[ProviderManager sharedManager] reportIncomingCallWithUUID:[NSUUID UUID] handle:handle hasVideo:false completion:^(NSError *error) {
        if(error) {
            NSLog(@"Error: %@", [error description]);
        }
    } answer:^(Call *call) {
        std::string callId = [_callId cStringWebRTC];
        WebRTC::mavInstance().mavCallAccept(callId, false, WEBRTC_AUDIO_EAR_PIECE);
    }];
    
    NSLog(@"************************* mavOnReceivedNewCall");
//    [self navigateToCallieVC];
}

-(void)mavOnReceivedCallActive:(std::string)callid {
    NSLog(@"-(void)mavOnReceivedCallActive:(std::string)callid   =>   %@", [NSString stringWithCharList:callid.c_str()]);
    activeConnectionCount += 1;
    [self addLog: [NSString stringWithFormat:@"WebRTC mavOnReceivedCallActive! callid: %@", [NSString stringWithCharList:callid.c_str()] ]];
    
    [[AudioService sharedManager] startAudio];
    if (activeConnectionCount > 1) {
        _secondCallId = [NSString stringWithCharList:callid.c_str()];
        Call *call = [[CallManager sharedManager] getActiveCall];
        call.state = CallStateActive;
        [call answer];
        
        std::string confcallId = [_secondCallId cStringWebRTC];
        std::string callId = [_callId cStringWebRTC];
        std::string activeUri = [_secondTargetMsisdn cStringWebRTC];
        std::string holdUri = [_targetMsisdn cStringWebRTC];
        std::string lineinfo = [_msisdn cStringWebRTC];
        
        WebRTC::mavInstance().mavStartAdHocConf(confcallId, callId, activeUri, holdUri, WEBRTC_AUDIO_EAR_PIECE, lineinfo);
    }else {
        _callId = [NSString stringWithCharList:callid.c_str()];
        Call *call = [[CallManager sharedManager] getActiveCall];
        call.state = CallStateActive;
        [call answer];
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"CallActive" object:nil userInfo:@{@"data": _callId}];
    NSLog(@"************************* mavOnReceivedCallActive");
}

-(void)mavOnReceivedCallStatus:(std::string)callid statuscode:(int)statuscode {
    [self addLog: [NSString stringWithFormat:@"WebRTC mavOnReceivedCallStatus! callid: %@ statusCode: %d", [NSString stringWithCharList:callid.c_str()], statuscode]];
    
    // Who knows?
    if (statuscode == 183) {
        NSLog(@"************************* StatusCode = 183");
    }
    
    // Incoming Call
    if (statuscode == 180) {
        Call *call = [[CallManager sharedManager] getActiveCall];
        call.connectionState = ConnectedStatePending;
        call.connectedStateChanged();
        NSLog(@"************************* StatusCode = 180");
    }
    
    // Our Call is Accepted
    if (statuscode == 200) {
//        activeConnectionCount += 1;
//        if (activeConnectionCount > 1) {
//            _secondCallId = [NSString stringWithCharList:callid.c_str()];
//        }else {
//            _callId = [NSString stringWithCharList:callid.c_str()];
//        }
        
//        [[NSNotificationCenter defaultCenter] postNotificationName:@"CallStatus" object:nil userInfo:@{@"data": _callId}];
        
        Call *call = [[CallManager sharedManager] getActiveCall];
        call.connectionState = ConnectedStateComplete;
        call.connectedStateChanged();
        NSLog(@"************************* StatusCode = 200");
    }

    // Call ended.
    if (statuscode == 204) {
        Call *call = [[CallManager sharedManager] getActiveCall];
        if (call) {
            [[CallManager sharedManager] endCall:call];
        }
        
        if (self.presentedViewController) {
            [self.presentedViewController dismissViewControllerAnimated:true completion:nil];
        }
        NSLog(@"************************* StatusCode = 204");
    }
    
    // Unknown
    if (statuscode == 405) {
        if (self.presentedViewController) {
            [self.presentedViewController dismissViewControllerAnimated:true completion:nil];
        }
        NSLog(@"************************* StatusCode = 405");
    }
    
    // Unknown
    if (statuscode == 500) {
        if (self.presentedViewController) {
            [self.presentedViewController dismissViewControllerAnimated:true completion:nil];
        }
        NSLog(@"************************* StatusCode = 500");
    }
}

-(void)mavOnCallHoldStatus:(std::string)callid status:(std::string)status {
    NSLog(@"************************* mavOnCallHoldStatus StatusCode = %@", [NSString stringWithCharList:status.c_str()]);
    
    _callId = [NSString stringWithCharList:callid.c_str()];
    Call *call = [[CallManager sharedManager] getActiveCall];
    call.state = CallStateHeld;
    [[CallManager sharedManager] setHeld:call onHold:true];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"CallHold" object:nil userInfo:@{@"data": _callId}];
}

-(void)mavOnCallUnHoldStatus:(std::string)callid status:(std::string)status {
    NSLog(@"************************* mavOnCallUnHoldStatus StatusCode = %@", [NSString stringWithCharList:status.c_str()]);
    
    _callId = [NSString stringWithCharList:callid.c_str()];
    Call *call = [[CallManager sharedManager] getActiveCall];
    call.state = CallStateActive;
    [[CallManager sharedManager] setHeld:call onHold:false];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"CallUnHold" object:nil userInfo:@{@"data": _callId}];
}

-(void)mavOnReceivedCallEnd:(std::string)callid {
    activeConnectionCount -= 1;
    
    [self addLog: [NSString stringWithFormat:@"WebRTC mavOnReceivedCallEnd! callid: %@", [NSString stringWithCharList:callid.c_str()] ]];
    _callId = [NSString stringWithCharList:callid.c_str()];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"CallEnd" object:nil userInfo:@{@"data": _callId}];
    NSLog(@"************************* mavOnReceivedCallEnd");
    
    Call *call = [[CallManager sharedManager] getActiveCall];
    [[CallManager sharedManager] endCall:call];
    
    if (self.presentedViewController) {
        [self.presentedViewController dismissViewControllerAnimated:true completion:nil];
    }
}

-(void)mavOnReceivedCallRejected:(std::string)callid {
    [self addLog: [NSString stringWithFormat:@"WebRTC mavOnReceivedCallRejected! callid: %@", [NSString stringWithCharList:callid.c_str()] ]];
    _callId = [NSString stringWithCharList:callid.c_str()];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"CellRejected" object:nil userInfo:@{@"data": _callId}];
    NSLog(@"************************* mavOnReceivedCallRejected");
    
    Call *call = [[CallManager sharedManager] getActiveCall];
    [[CallManager sharedManager] endCall:call];
    
    if (self.presentedViewController) {
        [self.presentedViewController dismissViewControllerAnimated:true completion:nil];
    }
}

-(void)mavOnReceivedCallHold:(std::string)callid {
    [self addLog: [NSString stringWithFormat:@"WebRTC mavOnReceivedCallHold! callid: %@", [NSString stringWithCharList:callid.c_str()] ]];
    _callId = [NSString stringWithCharList:callid.c_str()];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"CallHold" object:nil userInfo:@{@"data": _callId}];
    NSLog(@"************************* mavOnReceivedCallHold");
}

-(void)mavOnReceivedCallUnhold:(std::string)callid {
    [self addLog: [NSString stringWithFormat:@"WebRTC mavOnReceivedCallUnhold! callid: %@", [NSString stringWithCharList:callid.c_str()] ]];
    _callId = [NSString stringWithCharList:callid.c_str()];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"CallUnhold" object:nil userInfo:@{@"data": _callId}];
    NSLog(@"************************* mavOnReceivedCallUnhold");
}

@end
