

//
//  ProviderManager.m
//  WebRTC-POC
//
//  Created by BARIS YILMAZ on 08/12/2017.
//  Copyright © 2017 BARIS YILMAZ. All rights reserved.
//

#import <mavenir.webrtc/WebRTC.h>
#import <mavenir.webrtc/WebRTCiOS.h>
#import "WebRTCVC.h"
#import "CallManager.h"
#import "NSString+WebRTC.h"
#import "WebRTCCall.h"

#import "ProviderManager.h"

typedef void (^AnswerCallBlock)(Call *call);

@implementation ProviderManager
{
    CXProvider *_prodiver;
    WebRTC *_webRTC;
    AnswerCallBlock _answerCallBlock;
}

+ (id)sharedManager {
    static ProviderManager *_sharedManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedManager = [[self alloc] init];
    });
    return _sharedManager;
}

+ (CXProviderConfiguration *)providerConfig {
    CXProviderConfiguration *config = [[CXProviderConfiguration alloc] initWithLocalizedName:@"WebRTC"];
    config.supportsVideo = true;
    config.maximumCallsPerCallGroup = 1;
    config.supportedHandleTypes = [[NSSet alloc] initWithObjects:@(CXHandleTypePhoneNumber), nil];
    
    return config;
}

- (instancetype)init {
    if (self = [super init]) {
        // Some init operations
        _prodiver = [[CXProvider alloc] initWithConfiguration:[ProviderManager providerConfig]];
        _webRTC = &WebRTC::mavInstance();
        _callManager = [CallManager sharedManager];
        [_prodiver setDelegate:self queue:nil];
    }
    return self;
}

- (void)reportIncomingCallWithUUID:(NSUUID *)uuid handle:(NSString *)handle hasVideo:(bool)hasVideo completion:( void(^)(NSError *error)) completion answer:( void(^)(Call *call)) answer {
    NSLog(@"************************* ProviderManager::reportIncomingCallWithUUID:");
    CXCallUpdate *update = [CXCallUpdate new];
    update.remoteHandle = [[CXHandle alloc] initWithType:CXHandleTypePhoneNumber value:handle];
    update.hasVideo = hasVideo;
    _answerCallBlock = answer;
    
    [_prodiver reportNewIncomingCallWithUUID:uuid update:update completion:^(NSError * _Nullable error) {
        if (error == nil) {
            Call *call = [[Call alloc] initWithUUID:uuid outgoing:false handle:handle];
            
            [_callManager add:call];
        }else {
            NSLog(@"error: %@", [error description]);
        }
    }];
}

#pragma mark - CXProviderDelegate
#pragma mark Call Actions
-(void)provider:(CXProvider *)provider performStartCallAction:(CXStartCallAction *)action {
    NSLog(@"************************* provider:(CXProvider *)provider performStartCallAction:(CXStartCallAction *)action => action.callUUID: %@", [action.callUUID UUIDString]);
    Call *call = [[Call alloc] initWithUUID:action.callUUID outgoing:true handle:action.handle.value];
    call.state = CallStateConnection;

    __weak Call *weakCall = call;
    call.connectedStateChanged = ^{
        if (call.connectionState == ConnectedStatePending) {
            [_prodiver reportOutgoingCallWithUUID:weakCall.uuid startedConnectingAtDate:nil];
        }else if (call.connectionState == ConnectedStateComplete) {
            [_prodiver reportOutgoingCallWithUUID:weakCall.uuid connectedAtDate:nil];
        }
    };
    
    WebRTCCall *webrtcCall = [_webrtcController getWebRTCCallWithState:WebRTCCallStatePending isOutgoing:true];
    if (webrtcCall) {
        NSLog(@"************************* provider:(CXProvider *)provider performStartCallAction:(CXStartCallAction *)action => CallId: %@  webrtcCall.callUUID = %@", webrtcCall.callId, [call.uuid UUIDString]);
        webrtcCall.callUUID = call.uuid;
        call.callId = webrtcCall.callId;
    }
    
    [call startWithBlock:^(bool success) {
        if (success) {
            [action fulfill];
            [_callManager add:call];
            call.connectedStateChanged();
        }else {
            [action fail];
        }
    }];
}

-(void)provider:(CXProvider *)provider performAnswerCallAction:(CXAnswerCallAction *)action {
    NSLog(@"************************* provider:(CXProvider *)provider performAnswerCallAction:(CXAnswerCallAction *)action => action.callUUID: %@", [action.callUUID UUIDString]);
    Call *call = [_callManager callWithUUID:action.callUUID];
    call.state = CallStateActive;
    if (call == nil) {
        [action fail];
        return;
    }
    
    [[AudioService sharedManager] configureAudioSession];
    [call answer];
    _answerCallBlock(call);
    [action fulfill];
}

-(void)provider:(CXProvider *)provider performEndCallAction:(CXEndCallAction *)action {
    NSLog(@"************************* provider:(CXProvider *)provider performEndCallAction:(CXEndCallAction *)action = > action.callUUID: %@", [action.callUUID UUIDString]);
    WebRTCCall *webrtcCall = [_webrtcController getWebRTCCallWithCallUUID:[action.callUUID UUIDString] ];
    if (webrtcCall) {
        NSLog(@"************************* provider:(CXProvider *)provider performEndCallAction:(CXEndCallAction *)action = > _webRTC->mavCallEnd(%@)  webrtcCall.UUID: %@", webrtcCall.callId, [webrtcCall.callUUID UUIDString]);
        if ([[webrtcCall.callUUID UUIDString] isEqualToString:[action.callUUID UUIDString]]) {
            _webRTC->mavCallEnd([webrtcCall.callId cStringWebRTC]);
        }
    }
    
    Call *call = [_callManager callWithUUID:webrtcCall.callUUID];
    if (call) {
        [_callManager endCall:call];
    }
    
//    [[AudioService sharedManager] stopAudio];
    [action fulfill];
}

-(void)provider:(CXProvider *)provider performSetHeldCallAction:(CXSetHeldCallAction *)action {
    NSLog(@"************************* provider performSetHeldCallAction:(CXSetHeldCallAction *)action = > action.callUUID: %@", [action.callUUID UUIDString]);
    Call *call = [_callManager callWithUUID:action.callUUID];
    if (call == nil) {
        [action fail];
        return;
    }
    NSLog(@"************************* provider performSetHeldCallAction:(CXSetHeldCallAction *)action => action.isOnHold = %d", action.isOnHold);
    call.state = (action.isOnHold) ? CallStateHeld : CallStateActive;
    
//    if (call.state == CallStateHeld) {
//        WebRTCCall *webrtcCall = [_webrtcController getWebRTCCallWithState:WebRTCCallStateActive isOutgoing:true];
//        if (webrtcCall) {
//            NSLog(@"************************* provider:(CXProvider *)provider performSetHeldCallAction:(CXSetHeldCallAction *)action = > _webRTC->mavCallHold(%@)  webrtcCall.UUID: %@", webrtcCall.callId, [webrtcCall.callUUID UUIDString]);
//            if ([[webrtcCall.callUUID UUIDString] isEqualToString:[action.callUUID UUIDString]]) {
//                _webRTC->mavCallHold([webrtcCall.callId cStringWebRTC], false);
//            }
//        }
//
////        [[AudioService sharedManager] stopAudio];
//    }else {
//        WebRTCCall *webrtcCall = [_webrtcController getWebRTCCallWithState:WebRTCCallStateHold isOutgoing:true];
//        if (webrtcCall) {
//            NSLog(@"************************* provider:(CXProvider *)provider performSetHeldCallAction:(CXSetHeldCallAction *)action = > _webRTC->mavCallUnHold(%@)  webrtcCall.callUUID = %@", webrtcCall.callId, [webrtcCall.callUUID UUIDString]);
//            if ([[webrtcCall.callUUID UUIDString] isEqualToString:[action.callUUID UUIDString]]) {
//                _webRTC->mavCallUnhold([webrtcCall.callId cStringWebRTC]);
//            }
//        }
//
////        [[AudioService sharedManager] startAudio];
//    }
    [action fulfill];
}

-(void)provider:(CXProvider *)provider performSetMutedCallAction:(CXSetMutedCallAction *)action {
    NSLog(@"************************* provider performSetMutedCallAction:(CXSetMutedCallAction *)action = > action.callUUID: %@", [action.callUUID UUIDString]);
    Call *call = [_callManager callWithUUID:action.callUUID];
    if (call == nil) {
        [action fail];
        return;
    }
    
//    WebRTCCall *webrtcCall = [_webrtcController getActiveWebRTCCall];
//    if (webrtcCall) {
//        NSLog(@"************************* provider:(CXProvider *)provider performSetMutedCallAction:(CXSetMutedCallAction *)action = > _webRTC->mavCallMute(%@)  webrtcCall.callUUID = %@", webrtcCall.callId, [webrtcCall.callUUID UUIDString]);
//        if ([[webrtcCall.callUUID UUIDString] isEqualToString:[action.callUUID UUIDString]]) {
//            _webRTC->mavCallMute([webrtcCall.callId cStringWebRTC]);
//        }
//    }
    [action fulfill];
}

-(void)provider:(CXProvider *)provider performSetGroupCallAction:(CXSetGroupCallAction *)action {
    NSLog(@"************************* provider performSetGroupCallAction:(CXSetGroupCallAction *)action = > action.callUUID: %@", [action.callUUID UUIDString]);
    Call *call = [_callManager callWithUUID:action.callUUID];
    if (call == nil) {
        [action fail];
        return;
    }
    
    WebRTCCall *webrtcCall = [_webrtcController getActiveWebRTCCall];
    if (webrtcCall) {
        NSLog(@"************************* provider:(CXProvider *)provider performSetGroupCallAction:(CXSetGroupCallAction *)action = > _webRTC->mavCallUnMute(%@)  webrtcCall.callUUID = %@", webrtcCall.callId, [webrtcCall.callUUID UUIDString]);
        if ([[webrtcCall.callUUID UUIDString] isEqualToString:[action.callUUID UUIDString]]) {
            _webRTC->mavCallUnMute([webrtcCall.callId cStringWebRTC]);
        }
    }
    [action fulfill];
}

-(void)provider:(CXProvider *)provider performPlayDTMFCallAction:(CXPlayDTMFCallAction *)action {
    NSLog(@"************************* provider performPlayDTMFCallAction:(CXPlayDTMFCallAction *)action = > action.callUUID: %@", [action.callUUID UUIDString]);
    Call *call = [_callManager callWithUUID:action.callUUID];
    if (call == nil) {
        [action fail];
        return;
    }
    [action fulfill];
}

-(void)providerDidReset:(CXProvider *)provider {
    NSLog(@"************************* providerDidReset:(CXProvider *)provider");
    // Clean up any ongoing calls
//    [[AudioService sharedManager] stopAudio];
    for (Call *call in _callManager.calls) {
        [call end];
    }
    [_callManager removeAllCalls];
}

#pragma mark Activation Audio Session
-(void)provider:(CXProvider *)provider didActivateAudioSession:(AVAudioSession *)audioSession {
    NSLog(@"************************* provider:(CXProvider *)provider didActivateAudioSession:(AVAudioSession *)audioSession");
    WebRTC::mavInstance().mavActivatedaudio(audioSession);
}

-(void)provider:(CXProvider *)provider didDeactivateAudioSession:(AVAudioSession *)audioSession {
    NSLog(@"************************* provider:(CXProvider *)provider didDeactivateAudioSession:(AVAudioSession *)audioSession");
    WebRTC::mavInstance().mavDeactivatedaudio();
}

@end
