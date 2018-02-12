//
//  Call.h
//  WebRTC-POC
//
//  Created by BARIS YILMAZ on 08/12/2017.
//  Copyright © 2017 BARIS YILMAZ. All rights reserved.
//

#import <Foundation/Foundation.h>

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wnullability-completeness"

typedef enum : NSUInteger {
    CallStateConnection = 0,
    CallStateActive,
    CallStateHeld,
    CallStateEnded,
} CallState;

typedef enum : NSUInteger {
    ConnectedStateStarted = 0,
    ConnectedStatePending,
    ConnectedStateComplete,
} ConnectedState;

@interface Call : NSObject

// WebRTC properties
@property (nullable, nonatomic, strong) NSString *callId;
@property (nullable, nonatomic, strong) NSString *msisdn;
@property (nullable, nonatomic, strong) NSString *callee;
// CallKit properties
@property (nonatomic, strong) NSUUID *uuid;
@property (nonatomic, copy) NSString *handle;
@property (nonatomic, assign) bool isOutgoing;
@property (nonatomic, assign) CallState state;
@property (nonatomic, assign) ConnectedState connectionState;

@property (nonatomic, copy) void(^stateChanged)(void);
@property (nonatomic, copy) void(^connectedStateChanged)(void);

- (Call *)initWithUUID:(NSUUID *)uuid outgoing:(bool)outgoing handle:(NSString *)handle;
- (void)startWithBlock:( void (^__nullable)(bool success))completion;
- (void)answer;
- (void)end;

@end

#pragma clang diagnostic pop
