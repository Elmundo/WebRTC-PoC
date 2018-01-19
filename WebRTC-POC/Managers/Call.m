//
//  Call.m
//  WebRTC-POC
//
//  Created by BARIS YILMAZ on 08/12/2017.
//  Copyright © 2017 BARIS YILMAZ. All rights reserved.
//

#import "Call.h"

@implementation Call

- (instancetype)init
{
    self = [super init];
    if (self) {
        //
    }
    return self;
}

-(Call *)initWithUUID:(NSUUID *)uuid outgoing:(bool)outgoing handle:(NSString *)handle {
    self = [self init];
    if (self) {
        self.uuid = uuid;
        self.isOutgoing = outgoing;
        self.handle = handle;
        self.state = CallStateEnded;
        self.connectionState = ConnectedStateStarted;
    }
    return self;
}

-(void)startWithBlock:( void (^__nullable)(bool success))completion {
    completion(true);
}

- (void)answer {
    self.state = CallStateActive;
}

- (void)end {
    self.state = CallStateEnded;
}

@end
