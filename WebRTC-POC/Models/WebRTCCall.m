//
//  WebRTCCall.m
//  WebRTC-POC
//
//  Created by BARIS YILMAZ on 08/02/2018.
//  Copyright © 2018 BARIS YILMAZ. All rights reserved.
//

#import "WebRTCCall.h"

@implementation WebRTCCall

-(instancetype)initWith:(NSString *)callId msisdn:(NSString *)msisdn callee:(NSString *)callee outgoing:(BOOL)outgoing{
    if (self = [super init]) {
        _callId = callId;
        _msisdn = msisdn;
        _callee = callee;
        _state  = WebRTCCallStatePending;
        _isOutgoing = outgoing;
    }
    return self;
}

@end
