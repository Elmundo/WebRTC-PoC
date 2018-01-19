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

-(void)startCall:(NSString *)handle videoEnabled:(bool)videoEnabled {
    CXHandle *cxHandle = [[CXHandle alloc] initWithType:CXHandleTypePhoneNumber value:handle];
    CXStartCallAction *startCallAction = [[CXStartCallAction alloc] initWithCallUUID:[NSUUID UUID] handle:cxHandle];
    [startCallAction setVideo:videoEnabled];
    CXTransaction *transaction = [[CXTransaction alloc] initWithAction:startCallAction];
    
    [self requestTransaction:transaction];
}

-(void)endCall:(Call *)call {
    if (call.uuid) {
        CXEndCallAction *endCallAction = [[CXEndCallAction alloc] initWithCallUUID:call.uuid];
        CXTransaction *transaction = [[CXTransaction alloc] initWithAction:endCallAction];
        
        [self requestTransaction:transaction];
    }
}

-(void)setHeld:(Call *)call onHold:(bool)onHold {
    CXSetHeldCallAction *heldCallAction = [[CXSetHeldCallAction alloc] initWithCallUUID:call.uuid onHold:onHold];
    CXTransaction *transaction = [[CXTransaction alloc] initWithAction:heldCallAction];
    
    [self requestTransaction:transaction];
}

- (void)setMute:(Call *)call isMuted:(bool)isMuted {
    CXSetMutedCallAction *muteCallAction = [[CXSetMutedCallAction alloc] initWithCallUUID:call.uuid muted:isMuted];
    CXTransaction *transaction = [[CXTransaction alloc] initWithAction:muteCallAction];
    
    [self requestTransaction:transaction];
}

- (void)setGroup:(Call *)call mergeCall:(Call *)mergeCall{
    CXSetGroupCallAction *groupCallAction = [[CXSetGroupCallAction alloc] initWithCallUUID:call.uuid callUUIDToGroupWith:mergeCall.uuid];
    CXTransaction *transaction = [[CXTransaction alloc] initWithAction:groupCallAction];
    
    [self requestTransaction:transaction];
}

- (void)setPlayDTMF:(Call *)call digits:(NSString *)digits {
    CXPlayDTMFCallAction *dtmfCallAction = [[CXPlayDTMFCallAction alloc] initWithCallUUID:call.uuid digits:digits type:CXPlayDTMFCallActionTypeSingleTone];
    CXTransaction *transaction = [[CXTransaction alloc] initWithAction:dtmfCallAction];
    
    [self requestTransaction:transaction];
}

-(void)requestTransaction:(CXTransaction *)transaction {
    [_callController requestTransaction:transaction completion:^(NSError * _Nullable error) {
        if (error) {
            NSLog(@"Error");
        }else {
            NSLog(@"Success");
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

- (Call *)getActiveCall {
    for (Call *c  in self.calls) {
        return c;
    }
    
    return nil;
}

@end



