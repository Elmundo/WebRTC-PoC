//
//  WebRTCCall.h
//  WebRTC-POC
//
//  Created by BARIS YILMAZ on 08/02/2018.
//  Copyright © 2018 BARIS YILMAZ. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum : NSUInteger {
    WebRTCCallStatePending = 0,
    WebRTCCallStateActive,
    WebRTCCallStateHold,
    WebRTCCallStateEndPending,
    WebRTCCallStateEnded,
} WebRTCCallState;

@interface WebRTCCall : NSObject

@property (copy, nonatomic) NSUUID *callUUID;
@property (copy, nonatomic) NSString *callId;
@property (copy, nonatomic) NSString *msisdn;
@property (copy, nonatomic) NSString *callee;
@property (assign, nonatomic) BOOL isOutgoing;
@property (assign, nonatomic) WebRTCCallState state;

-(instancetype)initWith:(NSString *)callId msisdn:(NSString *)msisdn callee:(NSString *)callee outgoing:(BOOL)outgoing;

@end
