//
//  AudioService.h
//  WebRTC-POC
//
//  Created by BARIS YILMAZ on 08/12/2017.
//  Copyright © 2017 BARIS YILMAZ. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

typedef enum : NSUInteger {
    AudioCallStateSpeaker = 0,
    AudioCallStateEarPierce
} AudioCallState;

@interface AudioService : NSObject

+ (id)sharedManager;

- (void)configureAudioSession;
- (void)startAudio;
- (void)stopAudio;
- (void)switchTo:(AudioCallState)state;

@end
