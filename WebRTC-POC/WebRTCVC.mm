//
//  WebRTCVC.m
//  WebRTC-POC
//
//  Created by BARIS YILMAZ on 02/11/2017.
//  Copyright © 2017 BARIS YILMAZ. All rights reserved.
//

#import "WebRTCVC.h"

#define NSSTRING_CONVERT(str) [NSString stringWithUTF8String:str.c_str()]
#define NSSTRING_APPEND(str1, str2) [str1 stringByAppendingString:str2];

@interface WebRTCVC () <WebRTCiOSDelegate>
{
    WebRTC *webRTC;
    __weak IBOutlet UITextView *logTextView;
    __weak IBOutlet UIButton *reconnectBtn;
    NSMutableString *_log;
}
@end

@implementation WebRTCVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"WebRTC";
    [self clearLog];
    [self initializeWebRTS];
    logTextView.text                 = _log;
    logTextView.layer.cornerRadius   = 6.0f;
    logTextView.layer.borderColor    = [[UIColor blackColor] CGColor];
    logTextView.layer.borderWidth    = 2.0f;
    reconnectBtn.layer.cornerRadius  = reconnectBtn.frame.size.width/2;
    reconnectBtn.layer.masksToBounds = true;
}

- (void)initializeWebRTS {
    WebRTCConfig config;
    WEBRTC_STATUS_CODE status = WebRTC::mavInstance().mavInitialize(config);
    WebRTCiOS *ios            = [WebRTCiOS mavGetInstance];
    ios.delegate              = self;
    switch (status) {
        case WEBRTC_STATUS_OK:
            [self addLog:@"[WebRTCVC::mavInitialize] WebRTC initialization is success."];
            [self registerWebRTC];
            break;
            
        case WEBRTC_STATUS_FAILED:
            [self addLog:@"[WebRTCVC::mavInitialize] WebRTC initialization is failed."];
            break;
            
        default:
            break;
    }
}

- (void) registerWebRTC {;
    WEBRTC_STATUS_CODE status= WebRTC::mavInstance().mavRegister("https://92.45.96.182:8082",     // Base URL
                                                                 "48",                    // IAM Auth code
                                                                 "Baris Yilmaz",          // Display name of URI
                                                                 "Baris - iPhone 7",      // Fhriendly name used switch device
                                                                 "908502284041",          // Phone number of device
                                                                 "WebRTC workline"        // ??? Common workline
                                                                 );
    
    switch (status) {
        case WEBRTC_STATUS_OK:
            [self addLog:@"[WebRTCVC::mavRegister] WebRTC registeration is success."];
            break;
            
        case WEBRTC_STATUS_NOTACTIVATED:
            [self addLog:@"[WebRTCVC::mavRegister] WebRTC register is not activated."];
            break;
            
        case WEBRTC_STATUS_OPERATIONFAILED:
            [self addLog:@"[WebRTCVC::mavRegister] WebRTC register operation is failed."];
            break;
            
        default:
            break;
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - WebRTCiOSDelegate
#pragma mark Register Operations
- (void)mavOnReceivedRegisterSuccess:(std::string)did fid:(std::string)fid sessionid:(std::string)sessionid clientid:(std::string)clientid {
    
    NSString *log = [NSString stringWithFormat:@"[WebRTCVC::mavOnReceivedRegisterSuccess] did:%@ fid:%@ sessionId:%@ clientId:%@",
                     NSSTRING_CONVERT(did) , NSSTRING_CONVERT(fid), NSSTRING_CONVERT(sessionid), NSSTRING_CONVERT(clientid)];
    [self addLog:log];
    [self sendRegisterInfo];
}

-(void)mavOnReceivedReRegisterSuccess:(std::string)did fid:(std::string)fid sessionid:(std::string)sessionid clientid:(std::string)clientid {
    NSString *log = [NSString stringWithFormat:@"[WebRTCVC::mavOnReceivedReRegisterSuccess] did:%@ fid:%@ sessionId:%@ clientId:%@",
                     NSSTRING_CONVERT(did) , NSSTRING_CONVERT(fid), NSSTRING_CONVERT(sessionid), NSSTRING_CONVERT(clientid)];
    [self addLog:log];
}

-(void)mavOnReceivedWRGToken:(std::string)wrgtoken {
    NSString *log = [NSString stringWithFormat:@"[WebRTCVC::mavOnReceivedWRGToken] wrgtoken:%@",
                     NSSTRING_CONVERT(wrgtoken) ];
    [self addLog:log];
}

-(void)mavOnReceivedAccessToken:(std::string)access_token refresh_token:(std::string)refresh_token ttl:(std::string)ttl status:(std::string)status {
    NSString *log = [NSString stringWithFormat:@"[WebRTCVC::mavOnReceivedAccessToken] access_token:%@ refresh_token:%@ refresh_token:%@ ttl:%@ status:%@",
                 NSSTRING_CONVERT(access_token) , NSSTRING_CONVERT(refresh_token), NSSTRING_CONVERT(refresh_token),
                 NSSTRING_CONVERT(ttl), NSSTRING_CONVERT(status)];
    [self addLog:log];
}

-(void)mavOnReceivedRegisterError:(int)responsecode errorcode:(int)errorcode {
    NSString *log = [NSString stringWithFormat:@"[WebRTCVC::mavOnReceivedRegisterError] responsecode:%d errorcode:%d",
                     responsecode , errorcode];
    [self addLog:log];
    
}

-(void)mavOnReceivedUnRegisterSuccess {
    NSString *log = [NSString stringWithFormat:@"[WebRTCVC::mavOnReceivedUnRegisterSuccess] Unregister is success."];
    [self addLog:log];
}

-(void)mavOnReceivedSessionInfo:(std::string)session_info {
    NSString *log = [NSString stringWithFormat:@"[WebRTCVC::mavOnReceivedSessionInfo] session_info:%@", NSSTRING_CONVERT(session_info)];
    [self addLog:log];
}

-(void)mavOnReceivedSessionExpired {
    NSString *log = [NSString stringWithFormat:@"[WebRTCVC::mavOnReceivedSessionExpired] Session expired."];
    [self addLog:log];
}

#pragma mark Call Operations
- (void)mavOnReceivedNewCall:(std::string)uri callid:(std::string)callid LineInfo:(std::string)LineInfo {
    NSLog(@"mavOnReceivedNewCall.. uri:%@ callid:%@ LineInfo:%@", NSSTRING_CONVERT(uri), NSSTRING_CONVERT(callid), NSSTRING_CONVERT(LineInfo));
}

-(void)mavOnReceivedCallActive:(std::string)callid {
    NSLog(@"mavOnReceivedCallActive.. callid:%@", NSSTRING_CONVERT(callid));
}

-(void)mavOnReceivedCallStatus:(std::string)callid statuscode:(int)statuscode {
    NSLog(@"mavOnReceivedCallStatus.. callid:%@ statuscode:%di", NSSTRING_CONVERT(callid), statuscode);
}

-(void)mavOnReceivedCallEnd:(std::string)callid {
    NSLog(@"mavOnReceivedCallEnd.. callid:%@", NSSTRING_CONVERT(callid));
}

-(void)mavOnReceivedCallRejected:(std::string)callid {
    NSLog(@"mavOnReceivedCallRejected.. callid:%@", NSSTRING_CONVERT(callid));
}

-(void)mavOnReceivedCallHold:(std::string)callid {
    NSLog(@"mavOnReceivedCallHold.. callid:%@", NSSTRING_CONVERT(callid));
}

-(void)mavOnReceivedCallUnhold:(std::string)callid {
    NSLog(@"mavOnReceivedCallUnhold.. callid:%@", NSSTRING_CONVERT(callid));
}

#pragma mark Actions
- (IBAction)reconnect_Action:(id)sender {
    [self clearLog];
    logTextView.text = _log;
    [self initializeWebRTS];
}

#pragma mark Helpers
-(void)addLog:(NSString *)str {
    if ([NSThread isMainThread]) {
        NSString *l = [@"\n" stringByAppendingString:str];
        [_log appendString:l];
        logTextView.text = _log;
    }else {
        dispatch_sync(dispatch_get_main_queue(), ^{
            NSString *l = [@"\n" stringByAppendingString:str];
            [_log appendString:l];
            logTextView.text = _log;
        });
    }
}

- (void)clearLog {
    if ([NSThread isMainThread]) {
        _log = [[NSMutableString alloc] initWithString:@"Logs..\n\n"];
        logTextView.text = _log;
    }else {
        dispatch_sync(dispatch_get_main_queue(), ^{
            _log = [[NSMutableString alloc] initWithString:@"Logs..\n\n"];
            logTextView.text = _log;
        });
    }
}

- (void)sendRegisterInfo {
    NSString *msisdn = @"908502284041";
    NSString *lineId = [msisdn copy];
    
    std::string str_msisdn    = std::string([msisdn UTF8String], [msisdn lengthOfBytesUsingEncoding:NSUTF8StringEncoding]);
    std::string str_lineId    = std::string([lineId UTF8String], [lineId lengthOfBytesUsingEncoding:NSUTF8StringEncoding]);
    std::string str_empty     = std::string([@"" UTF8String], [@"" lengthOfBytesUsingEncoding:NSUTF8StringEncoding]);
    WEBRTC_STATUS_CODE status = WebRTC::mavInstance().mavSendRegistrationInfo(str_msisdn, str_empty, str_lineId, str_empty);
    
    switch (status) {
        case WEBRTC_STATUS_OK:
            [self addLog:@"[WebRTCVC::mavSendRegistrationInfo] Sending registration info is success."];
            break;
            
        case WEBRTC_STATUS_NOTACTIVATED:
            [self addLog:@"[WebRTCVC::mavSendRegistrationInfo]. Not Activated"];
            break;
            
        case WEBRTC_STATUS_OPERATIONFAILED:
            [self addLog:@"[WebRTCVC::mavSendRegistrationInfo] Operation failed."];
            break;
            
        default:
            break;
    }
}

@end

