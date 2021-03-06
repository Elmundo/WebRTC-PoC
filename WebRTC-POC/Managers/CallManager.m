//
//  CallManager.m
//  WebRTC-POC
//
//  Created by BARIS YILMAZ on 08/12/2017.
//  Copyright © 2017 BARIS YILMAZ. All rights reserved.
//

#import "CallManager.h"


@implementation CallManager
{
    CXCallController *_callController;
}

+ (id)sharedManager {
    static CallManager *_sharedManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedManager = [[self alloc] init];
    });
    return _sharedManager;
}

- (instancetype)init {
    if (self = [super init]) {
        _callController = [CXCallController new];
        self.calls = [NSMutableArray array];
    }
    return self;
}

- (void)add:(Call *)call {
    [self.calls addObject:call];
    if (self.callsChangedHandler) {
        self.callsChangedHandler();
    }
}

- (void)remove:(Call *)call {
    [self.calls removeObject:call];
    if (self.callsChangedHandler) {
        self.callsChangedHandler();
    }
}

- (void)removeAllCalls {
    [self.calls removeAllObjects];
    if (self.callsChangedHandler) {
        self.callsChangedHandler();
    }
}

#pragma mark - Actions

-(void)startCall:(NSString *)handle videoEnabled:(bool)videoEnabled webrtcCall:(WebRTCCall *)webrtcCall {
    CXHandle *cxHandle = [[CXHandle alloc] initWithType:CXHandleTypePhoneNumber value:handle];
    CXStartCallAction *startCallAction = [[CXStartCallAction alloc] initWithCallUUID:[NSUUID UUID] handle:cxHandle];
    [startCallAction setVideo:videoEnabled];
    CXTransaction *transaction = [[CXTransaction alloc] initWithAction:startCallAction];
    if (webrtcCall) {
        webrtcCall.callUUID = startCallAction.callUUID;
    }
    
    NSLog(@"************************* CallManager::startCall callId: %@ callUUID: %@", webrtcCall.callId, [startCallAction.callUUID UUIDString]);
    [self requestTransaction:transaction];
}

-(void)endCall:(Call *)call {
    NSLog(@"************************* CallManager::endCall callUUID: %@", [call.uuid UUIDString]);
    [self.calls removeObject:call];
    if (call.uuid) {
        CXEndCallAction *endCallAction = [[CXEndCallAction alloc] initWithCallUUID:call.uuid];
        CXTransaction *transaction = [[CXTransaction alloc] initWithAction:endCallAction];

        [self requestTransaction:transaction];
    }
}

-(void)setHeld:(Call *)call onHold:(bool)onHold {
    NSLog(@"************************* CallManager::setHeld");
    CXSetHeldCallAction *heldCallAction = [[CXSetHeldCallAction alloc] initWithCallUUID:call.uuid onHold:onHold];
    CXTransaction *transaction = [[CXTransaction alloc] initWithAction:heldCallAction];
    
    [self requestTransaction:transaction];
}

- (void)setMute:(Call *)call isMuted:(bool)isMuted {
    NSLog(@"************************* CallManager::setMute");
    CXSetMutedCallAction *muteCallAction = [[CXSetMutedCallAction alloc] initWithCallUUID:call.uuid muted:isMuted];
    CXTransaction *transaction = [[CXTransaction alloc] initWithAction:muteCallAction];
    
    [self requestTransaction:transaction];
}

- (void)setGroup:(Call *)call mergeCall:(Call *)mergeCall{
    NSLog(@"************************* CallManager::setGroup");
    CXSetGroupCallAction *groupCallAction = [[CXSetGroupCallAction alloc] initWithCallUUID:call.uuid callUUIDToGroupWith:mergeCall.uuid];
    CXTransaction *transaction = [[CXTransaction alloc] initWithAction:groupCallAction];
    
    [self requestTransaction:transaction];
}

- (void)setPlayDTMF:(Call *)call digits:(NSString *)digits {
    NSLog(@"************************* CallManager::setPlayDTMF");
    CXPlayDTMFCallAction *dtmfCallAction = [[CXPlayDTMFCallAction alloc] initWithCallUUID:call.uuid digits:digits type:CXPlayDTMFCallActionTypeSingleTone];
    CXTransaction *transaction = [[CXTransaction alloc] initWithAction:dtmfCallAction];
    
    [self requestTransaction:transaction];
}

-(void)requestTransaction:(CXTransaction *)transaction {
    [_callController requestTransaction:transaction completion:^(NSError * _Nullable error) {
        if (error) {
//            NSLog(@"Error");
        }else {
//            NSLog(@"Success");
        }
    }];
}

#pragma mark - Helper
- (Call *)callWithUUID:(NSUUID *)uuid {
    for (Call *c in self.calls) {
        if ([c.uuid.UUIDString isEqualToString:uuid.UUIDString]) {
            return c;
        }
    }
    
    return nil;
}

- (Call *)getCallWithCallId:(NSString *)callId {
    for (Call *c  in self.calls) {
        if ([callId isEqualToString:c.callId]) {
            return c;
        }
    }
    return nil;
}

- (NSArray<Call *> *)getCalls {
    return self.calls;
}

- (void)endAllCalls {
    for (Call *c  in self.calls) {
        [self endCall:c];
    }
    [self.calls removeAllObjects];
}

@end



