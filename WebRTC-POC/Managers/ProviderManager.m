//
//  ProviderManager.m
//  WebRTC-POC
//
//  Created by BARIS YILMAZ on 08/12/2017.
//  Copyright © 2017 BARIS YILMAZ. All rights reserved.
//

#import "ProviderManager.h"

typedef void (^AnswerCallBlock)(Call *call);

@implementation ProviderManager
{
    CXProvider *_prodiver;
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
    NSLog(@"************************* provider:(CXProvider *)provider performStartCallAction:(CXStartCallAction *)action");
    Call *call = [[Call alloc] initWithUUID:action.callUUID outgoing:true handle:action.handle.value];
    call.state = CallStateConnection;
    [[AudioService sharedManager] configureAudioSession];
    
    call.connectedStateChanged = ^{
        if (call.connectionState == ConnectedStatePending) {
            [_prodiver reportOutgoingCallWithUUID:call.uuid startedConnectingAtDate:nil];
        }else if (call.connectionState == ConnectedStateComplete) {
            [_prodiver reportOutgoingCallWithUUID:call.uuid connectedAtDate:nil];
        }
    };
    
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
    NSLog(@"************************* provider:(CXProvider *)provider performAnswerCallAction:(CXAnswerCallAction *)action");
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
    NSLog(@"************************* provider:(CXProvider *)provider performEndCallAction:(CXEndCallAction *)action");
    Call *call = [_callManager callWithUUID:action.callUUID];
    call.state = CallStateEnded;
    if (call == nil) {
        [action fail];
        return;
    }
    
    [[AudioService sharedManager] stopAudio];
    // TODO: End WebRTC call here.
    [call end];
    [action fulfill];
    [_callManager remove:call];
}

-(void)provider:(CXProvider *)provider performSetHeldCallAction:(CXSetHeldCallAction *)action {
    NSLog(@"************************* provider performSetHeldCallAction:(CXSetHeldCallAction *)action");
    Call *call = [_callManager callWithUUID:action.callUUID];
    call.state = CallStateHeld;
    if (call == nil) {
        [action fail];
        return;
    }
    
    call.state = (action.isOnHold) ? CallStateHeld : CallStateActive;
    
    if (call.state == CallStateHeld) {
        [[AudioService sharedManager] stopAudio];
    }else {
        [[AudioService sharedManager] startAudio];
    }
    
    [action fulfill];
}

-(void)provider:(CXProvider *)provider performSetMutedCallAction:(CXSetMutedCallAction *)action {
    NSLog(@"************************* provider performSetMutedCallAction:(CXSetMutedCallAction *)action");
    Call *call = [_callManager callWithUUID:action.callUUID];
    if (call == nil) {
        [action fail];
        return;
    }
    
    [action fulfill];
}

-(void)provider:(CXProvider *)provider performSetGroupCallAction:(CXSetGroupCallAction *)action {
    NSLog(@"************************* provider performSetGroupCallAction:(CXSetGroupCallAction *)action");
    Call *call = [_callManager callWithUUID:action.callUUID];
    if (call == nil) {
        [action fail];
        return;
    }
    
    [action fulfill];
}

-(void)provider:(CXProvider *)provider performPlayDTMFCallAction:(CXPlayDTMFCallAction *)action {
    NSLog(@"************************* provider performPlayDTMFCallAction:(CXPlayDTMFCallAction *)action");
    Call *call = [_callManager callWithUUID:action.callUUID];
    if (call == nil) {
        [action fail];
        return;
    }
    
    [action fulfill];
}

-(void)providerDidReset:(CXProvider *)provider {
    NSLog(@"************************* providerDidReset:(CXProvider *)provider");
    [[AudioService sharedManager] stopAudio];
    
    for (Call *call in _callManager.calls) {
        [call end];
    }
    
    [_callManager removeAllCalls];
}

#pragma mark Activation Audio Session
-(void)provider:(CXProvider *)provider didActivateAudioSession:(AVAudioSession *)audioSession {
    NSLog(@"************************* provider:(CXProvider *)provider didActivateAudioSession:(AVAudioSession *)audioSession");
    [[AudioService sharedManager] startAudio];
}

-(void)provider:(CXProvider *)provider didDeactivateAudioSession:(AVAudioSession *)audioSession {
    NSLog(@"************************* provider:(CXProvider *)provider didDeactivateAudioSession:(AVAudioSession *)audioSession");
    [[AudioService sharedManager] stopAudio];
}

@end
