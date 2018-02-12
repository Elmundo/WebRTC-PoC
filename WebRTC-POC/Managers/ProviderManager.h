//
//  ProviderManager.h
//  WebRTC-POC
//
//  Created by BARIS YILMAZ on 08/12/2017.
//  Copyright © 2017 BARIS YILMAZ. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CallKit/CallKit.h>
#import "CallManager.h"
#import "AudioService.h"
#import "Call.h"

@interface ProviderManager : NSObject<CXProviderDelegate>

+ (id)sharedManager;

@property(nonatomic, weak) CallManager *callManager;
@property(nonatomic, weak) id webrtcController;

- (void)reportIncomingCallWithUUID:(NSUUID *)uuid handle:(NSString *)handle hasVideo:(bool)hasVideo completion:( void(^)(NSError *error)) completion answer:( void(^)(Call *call)) answer;

@end
