//
//  WebRTCVC.m
//  WebRTC-POC
//
//  Created by BARIS YILMAZ on 02/11/2017.
//  Copyright © 2017 BARIS YILMAZ. All rights reserved.
//

#import "WebRTCVC.h"

#define NSSTRING_TO_STRING(str) [NSString stringWithUTF8String:str.c_str()]
#define NSSTRING_APPEND(str1, str2) [str1 stringByAppendingString:str2]
#define STRING_TO_NSSTRING(str) [NSString stringWithCString:str.c_str() encoding:[NSString defaultCStringEncoding]]

@interface WebRTCVC () <WebRTCiOSDelegate>
{
    WebRTC *webRTC;
    __weak IBOutlet UITextView *logTextView;
    __weak IBOutlet UIButton *reconnectBtn;
    NSMutableString *_log;
    
    std::string _fid;
    std::string _did;
    std::string _sessionId;
    std::string _clientId;
    
    NSString *caller;
    NSString *callie;
    
    bool onCall;
}
@end

@implementation WebRTCVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    onCall = false;
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

/*
 Auth Code,Number
 48 908502284041,908502284041
 49 908502284042,908502284042
 50 908502284044,908502284044
 */

/*
 908502284041 Pass:123456   Domain:superims.com
 908502284042 Pass:123456   Domain:superims.com
 */
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
            NSLog(@"WEBRTC_STATUS_OK");
            break;
            
        case WEBRTC_STATUS_NOTACTIVATED:
            NSLog(@"WEBRTC_STATUS_NOTACTIVATED");
            break;
            
        case WEBRTC_STATUS_OPERATIONFAILED:
            NSLog(@"WEBRTC_STATUS_OPERATIONFAILED");
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
    
    _did        = did;
    _fid        = fid;
    _sessionId  = sessionid;
    _clientId   = clientid;
    
    NSLog(@"mavOnReceivedRegisterSuccess.. did:%@ fid:%@ sessionId:%@ clientId:%@", NSSTRING_TO_STRING(did) , NSSTRING_TO_STRING(fid), NSSTRING_TO_STRING(sessionid), NSSTRING_TO_STRING(clientid));
    NSString *str = @"mavOnReceivedRegisterSuccess";//NSSTRING_APPEND(@"mavOnReceivedRegisterSuccess.. ", STRING_CONVERT(sessionId));
    [self addLog:str];
}

-(void)mavOnReceivedReRegisterSuccess:(std::string)did fid:(std::string)fid sessionid:(std::string)sessionid clientid:(std::string)clientid {
    //    NSLog(@"mavOnReceivedReRegisterSuccess.. did:%@ fid:%@ sessionId:%@ clientId:%@", NSSTRING_CONVERT(did), NSSTRING_CONVERT(fid), NSSTRING_CONVERT(sessionid), NSSTRING_CONVERT(clientid));
    NSString *str = @"mavOnReceivedReRegisterSuccess.. ";
    [self addLog:str];
}

-(void)mavOnReceivedWRGToken:(std::string)wrgtoken {
    NSLog(@"mavOnReceivedWRGToken.. wrgtoken:%@", NSSTRING_TO_STRING(wrgtoken));
    NSString *str = NSSTRING_APPEND(@"mavOnReceivedWRGToken.. ", NSSTRING_TO_STRING(wrgtoken));
    [self addLog:str];
}

-(void)mavOnReceivedAccessToken:(std::string)access_token refresh_token:(std::string)refresh_token ttl:(std::string)ttl status:(std::string)status {
    NSLog(@"mavOnReceivedAccessToken.. access_token:%@ refresh_token:%@ ttl:%@ status:%@", NSSTRING_TO_STRING(access_token),
          NSSTRING_TO_STRING(refresh_token),
          NSSTRING_TO_STRING(ttl),
          NSSTRING_TO_STRING(status));
    NSString *str = NSSTRING_APPEND(@"mavOnReceivedAccessToken.. ", NSSTRING_TO_STRING(access_token));
    [self addLog:str];
}

-(void)mavOnReceivedRegisterError:(int)responsecode errorcode:(int)errorcode {
    NSLog(@"mavOnReceivedRegisterError.. responsecode:%d errorCode:%d", responsecode, errorcode);
    NSString *str = [NSString stringWithFormat:@"responsecode: %d errorcode: %d", responsecode, errorcode];
    [self addLog:str];
}

-(void)mavOnReceivedUnRegisterSuccess {
    NSLog(@"mavOnReceivedUnRegisterSuccess..");
}

-(void)mavOnReceivedSessionInfo:(std::string)session_info {
    NSLog(@"mavOnReceivedSessionInfo.. session_info:%@", NSSTRING_TO_STRING(session_info));
    [self addLog:NSSTRING_TO_STRING(session_info)];
    
    // TODO: Make a new call
    std::string lineInfo = "908502284041@superims.com"; // Arayan
    std::string uri = "908502284044@superims.com"; // Aranan
    if (onCall == false) {
        WebRTC::mavInstance().mavCallStart(uri, _clientId, false, WEBRTC_AUDIO_WIRED_HEADSET, lineInfo);
    }
    
}

-(void)mavOnReceivedSessionExpired {
    NSLog(@"mavOnReceivedSessionExpired..");
    NSString *str = @"\n\nmavOnReceivedSessionExpired";
    [self addLog:str];
}

#pragma mark Call Operations
- (void)mavOnReceivedNewCall:(std::string)uri callid:(std::string)callid LineInfo:(std::string)LineInfo {
    NSLog(@"mavOnReceivedNewCall.. uri:%@ callid:%@ LineInfo:%@", NSSTRING_TO_STRING(uri), NSSTRING_TO_STRING(callid), NSSTRING_TO_STRING(LineInfo));
    WebRTC::mavInstance().mavCallAccept(callid, false, WEBRTC_AUDIO_EAR_PIECE);
}

-(void)mavOnReceivedCallActive:(std::string)callid {
    NSLog(@"mavOnReceivedCallActive.. callid:%@", NSSTRING_TO_STRING(callid));
    onCall = true;
}

-(void)mavOnReceivedCallStatus:(std::string)callid statuscode:(int)statuscode {
    NSLog(@"mavOnReceivedCallStatus.. callid:%@ statuscode:%di", NSSTRING_TO_STRING(callid), statuscode);
}

-(void)mavOnReceivedCallEnd:(std::string)callid {
    NSLog(@"mavOnReceivedCallEnd.. callid:%@", NSSTRING_TO_STRING(callid));
    onCall = false;
}

-(void)mavOnReceivedCallRejected:(std::string)callid {
    NSLog(@"mavOnReceivedCallRejected.. callid:%@", NSSTRING_TO_STRING(callid));
    onCall = false;
}

-(void)mavOnReceivedCallHold:(std::string)callid {
    NSLog(@"mavOnReceivedCallHold.. callid:%@", NSSTRING_TO_STRING(callid));
}

-(void)mavOnReceivedCallUnhold:(std::string)callid {
    NSLog(@"mavOnReceivedCallUnhold.. callid:%@", NSSTRING_TO_STRING(callid));
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
        _log = [[NSMutableString alloc] initWithString:@"Logs..\n"];
        logTextView.text = _log;
    }else {
        dispatch_sync(dispatch_get_main_queue(), ^{
            _log = [[NSMutableString alloc] initWithString:@"Logs..\n"];
            logTextView.text = _log;
        });
    }
}

@end

