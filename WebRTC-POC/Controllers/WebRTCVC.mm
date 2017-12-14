//
//  WebRTCVC.m
//  WebRTC-POC
//
//  Created by BARIS YILMAZ on 02/11/2017.
//  Copyright © 2017 BARIS YILMAZ. All rights reserved.
//

#import "WebRTCVC.h"
#import "Call/CallerVC.h"
#import "Call/CallieVC.h"
#import "LogModel.h"
#import "LogTVC.h"
#import "ProviderManager.h"
#import "CallManager.h"

#define NSSTRING_TO_STRING(str) [NSString stringWithUTF8String:str.c_str()]
#define NSSTRING_APPEND(str1, str2) [str1 stringByAppendingString:str2]
#define STRING_TO_NSSTRING(str) [NSString stringWithCString:str.c_str() encoding:[NSString defaultCStringEncoding]]

#define kScreenWidth [[UIScreen mainScreen] bounds].size.width
#define kScreenHeight [[UIScreen mainScreen] bounds].size.height

@interface WebRTCVC () <WebRTCiOSDelegate, UIPickerViewDelegate, UIPickerViewDataSource, UITableViewDataSource, UITableViewDelegate, CallerDelegate, CallieDelegate>
{
    WebRTC *webRTC;
    
    // Widgets
    UIPickerView *authCodePV;
    UIPickerView *msisdnPV;
    UIPickerView *targetMsisdnPV;
    UIAlertController *alertController;
    
    // Properties
    NSString *_authCode;
    NSString *_msisdn;
    NSString *_targetMsisdn;
    NSString *_fid;
    NSString *_did;
    NSString *_sessionId;
    NSString *_clientId;
    NSString *_callId;
    
    NSArray<NSString *> *authCodes;
    NSArray<NSString *> *msisdnList;
    NSMutableArray<LogModel *> *logs;
    NSTimer *timer;
    
    bool onCall;
    bool isWebRTCAvailable;
    bool needReRegister;
}
@end

@implementation WebRTCVC

#pragma mark - Built-in Methods
- (void)viewDidLoad {
    [super viewDidLoad];
    
    logs       = [[NSMutableArray<LogModel *> alloc] init];
    authCodes  = [[NSArray<NSString *> alloc] initWithObjects:@"48", @"49", @"50", @"56", nil];
    msisdnList = [[NSArray<NSString *> alloc] initWithObjects:
                  @"908502284041@superims.com", @"908502284042@superims.com",
                  @"908502284044@superims.com", @"905390000098@ims.mnc001.mcc286.3gppnetwork.org",
                  @"905390000530@ims.mnc001.mcc286.3gppnetwork.org", @"905390000058@ims.mnc001.mcc286.3gppnetwork.org", nil];
    
    _authCode     = [authCodes objectAtIndex:3];
    _msisdn       = [msisdnList objectAtIndex:3];
    _targetMsisdn = [msisdnList objectAtIndex:4];
    self.authCodeTF.text     = _authCode;
    self.msisdnTF.text       = _msisdn;
    self.targetMsisdnTF.text = _targetMsisdn;
    
    needReRegister    = false;
    isWebRTCAvailable = false;
    onCall            = false;

    self.logTV.tableFooterView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, 1.0f)];
    
    [self initWidgets];
    [self initPickerViews];
    [self initTableView];
    [self initWebRTC];
    WebRTC::mavInstance().mavUnRegister(true);
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(applicationDidBecomeActive:)
                                                 name:UIApplicationDidBecomeActiveNotification object:nil];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
}

#pragma mark - Init Methods
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

- (void)initTableView {
    self.logTV.delegate           = self;
    self.logTV.dataSource         = self;
    self.logTV.layer.cornerRadius = 6.0;
    self.logTV.layer.borderWidth  = 2.0;
    self.logTV.layer.borderColor  = [UIColor darkGrayColor].CGColor;
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
    
    WEBRTC_STATUS_CODE status= WebRTC::mavInstance().mavRegister(baseURL, // Base URL
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
//- (void)startReRegisterSession {
//    timer = [NSTimer timerWithTimeInterval:10.0 repeats:true block:^(NSTimer * _Nonnull timer) {
//        std::string sessionId = [_sessionId cStringWebRTC];
//        std::string msisdn = [_msisdn cStringWebRTC];
//        WebRTC::mavInstance().mavReRegister(sessionId, msisdn);
//    }];
//    [[NSRunLoop mainRunLoop] addTimer:timer forMode:NSDefaultRunLoopMode];
//}

//- (void)endReRegisterSession {
//    [timer invalidate];
//    timer = nil;
//}

- (void)navigateToCallerVC {
    self.definesPresentationContext = true;
    CallerVC *vc                    = [[CallerVC alloc] initWithNibName:nil bundle:nil];
    vc.delegate                     = self;
    vc.modalPresentationStyle       = UIModalPresentationOverCurrentContext;
    vc.modalTransitionStyle         = UIModalTransitionStyleCrossDissolve;
    [self presentViewController:vc animated:true completion:nil];
}

- (void)navigateToCallieVC {
    self.definesPresentationContext = true;
    CallieVC *vc                    = [[CallieVC alloc] initWithNibName:nil bundle:nil];
    vc.delegate                     = self;
    vc.modalPresentationStyle       = UIModalPresentationOverCurrentContext;
    vc.modalTransitionStyle         = UIModalTransitionStyleCrossDissolve;
    [self presentViewController:vc animated:true completion:nil];
}

#pragma mark - UIPickerViewDataSource
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
    }else {
        _targetMsisdn = [msisdnList objectAtIndex:row];
        self.targetMsisdnTF.text = _targetMsisdn;
    }
}

#pragma mark - UITableViewDataSource
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [logs count];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    LogModel *model       = [logs objectAtIndex:indexPath.row];
    LogTVC *cell          = (LogTVC *)[tableView dequeueReusableCellWithIdentifier:@"LogTVC"];
    cell.logTextView.text = model.log;
    [cell.logTextView setFont:[UIFont systemFontOfSize:12.0f]];

    return cell;
}

#pragma mark - UITableViewDelegate
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [self calculateHeightOfCell:indexPath];
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

- (CGFloat)calculateHeightOfCell:(NSIndexPath *)indexPath {
    LogModel *model = [logs objectAtIndex:indexPath.row];
    NSString *text  = model.log;
    CGRect rect = [text boundingRectWithSize:CGSizeMake(340, 2000)
                       options:NSStringDrawingUsesLineFragmentOrigin
                    attributes:@{NSFontAttributeName: [UIFont systemFontOfSize:14.0f]}
                       context:nil];
    NSInteger height = MAX(rect.size.height + 10, 44);
    return height;
}

- (void)applicationDidBecomeActive:(NSNotification *)notification {
    if ([_sessionId cStringWebRTC]) {
        std::string sessionId  = [_sessionId cStringWebRTC];
        std::string nativeline = [_msisdn cStringWebRTC];
        
        WEBRTC_STATUS_CODE _ = WebRTC::mavInstance().mavReRegister(sessionId, nativeline);
    }
}

#pragma mark -
#pragma mark - WebRTCiOSDelegate
#pragma mark Register Operations
- (void)mavOnReceivedRegisterSuccess:(std::string)did fid:(std::string)fid sessionid:(std::string)sessionid clientid:(std::string)clientid {
    _did       = [NSString stringWithCharList:did.c_str()];
    _fid       = [NSString stringWithCharList:fid.c_str()];
    _sessionId = [NSString stringWithCharList:sessionid.c_str()];
    _clientId  = [NSString stringWithCharList:clientid.c_str()];
    
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
    }];
    
    NSLog(@"************************* mavOnReceivedNewCall");
    // TODO: CXProvider reportNewIncomingCall
    [self navigateToCallieVC];
}

-(void)mavOnReceivedCallActive:(std::string)callid {
    [self addLog: [NSString stringWithFormat:@"WebRTC mavOnReceivedCallActive! callid: %@", [NSString stringWithCharList:callid.c_str()] ]];
    _callId = [NSString stringWithCharList:callid.c_str()];
    
    Call *call = [[CallManager sharedManager] getActiveCall];
    call.state = CallStateActive;
    [call answer];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"CallActive" object:nil userInfo:@{@"data": _callId}];
    NSLog(@"************************* mavOnReceivedCallActive");
}

-(void)mavOnReceivedCallStatus:(std::string)callid statuscode:(int)statuscode {
    [self addLog: [NSString stringWithFormat:@"WebRTC mavOnReceivedCallStatus! callid: %@ statusCode: %d", [NSString stringWithCharList:callid.c_str()], statuscode]];
    _callId = [NSString stringWithCharList:callid.c_str()];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"CallStatus" object:nil userInfo:@{@"data": _callId}];
    
    // Who knows?
    if (statuscode == 183) {
        NSLog(@"************************* StatusCode = 183");
    }
    
    // Incoming Call
    if (statuscode == 180) {
        Call *call = [[CallManager sharedManager] getActiveCall];
        call.connectionState = ConnectedStateComplete;
        NSLog(@"************************* StatusCode = 180");
    }
    
    // Our Call is Accepted
    if (statuscode == 200) {
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
}

-(void)mavOnCallHoldStatus:(std::string)callid status:(std::string)status {
    NSLog(@"************************* mavOnCallHoldStatus StatusCode = %@", [NSString stringWithCharList:status.c_str()]);
}

-(void)mavOnCallUnHoldStatus:(std::string)callid status:(std::string)status {
    NSLog(@"************************* mavOnCallUnHoldStatus StatusCode = %@", [NSString stringWithCharList:status.c_str()]);
}

-(void)mavOnReceivedCallEnd:(std::string)callid {
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
