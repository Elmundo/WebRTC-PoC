//
//  CallManager.h
//  WebRTC-POC
//
//  Created by BARIS YILMAZ on 08/12/2017.
//  Copyright © 2017 BARIS YILMAZ. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CallKit/CallKit.h>
#import "Call.h"

typedef void(^CallsChangedHandler)(void);

@interface CallManager : NSObject

@property (nonatomic, copy) CallsChangedHandler callsChangedHandler;
@property (nonatomic, strong) NSMutableArray<Call*> *calls;

+ (id)sharedManager;

- (void)add:(Call *)call;

- (void)remove:(Call *)call;

- (void)removeAllCalls;

- (void)startCall:(NSString *)handle videoEnabled:(bool)videoEnabled;

- (void)endCall:(Call *)call;

- (void)setHeld:(Call *)call onHold:(bool)onHold;

- (Call *)callWithUUID:(NSUUID *)uuid;

- (Call *)getActiveCall;

@end
