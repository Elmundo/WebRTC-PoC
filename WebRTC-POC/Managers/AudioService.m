//
//  AudioService.m
//  WebRTC-POC
//
//  Created by BARIS YILMAZ on 08/12/2017.
//  Copyright © 2017 BARIS YILMAZ. All rights reserved.
//

#import "AudioService.h"

@implementation AudioService
{
    AVAudioSession *_audioSession;
    AudioCallState _audioState;
}
+ (id)sharedManager {
    static AudioService *_sharedManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedManager = [[self alloc] init];
    });
    return _sharedManager;
}

- (instancetype)init {
    if (self = [super init]) {
        _audioState = AudioCallStateEarPierce;
    }
    return self;
}

- (void)configureAudioSession {
    NSError *error;
    _audioSession = [AVAudioSession sharedInstance];
    [_audioSession setCategory:AVAudioSessionCategoryPlayAndRecord error:&error];
    [_audioSession setMode:AVAudioSessionModeVoiceChat error:&error];
}

- (void)startAudio {
    NSLog(@"************************* AudioService::startAudio");
    NSError *error;
    [_audioSession setActive:true error:&error];
    if (error) {
        NSLog(@"Error: %@", [error description]);
    }
}

- (void)stopAudio {
    NSLog(@"************************* AudioService::stopAudio");
    NSError *error;
    [_audioSession setActive:false error:&error];
    if (error) {
        NSLog(@"Error: %@", [error description]);
    }
}

- (void)switchTo:(AudioCallState)state {
    NSError *error;
    switch (state) {
        case AudioCallStateEarPierce:
            NSLog(@"************************* AudioService::switchTo:  AudioCallStateEarPierce");
            [_audioSession setCategory:AVAudioSessionCategoryPlayAndRecord
                  withOptions:AVAudioSessionCategoryOptionAllowBluetooth
                                 error:&error];
            if (error) {
                NSLog(@"Error: %@", [error description]);
            }
            break;
            
        case AudioCallStateSpeaker:
            NSLog(@"************************* AudioService::switchTo:  AudioCallStateSpeaker");
            [_audioSession setCategory:AVAudioSessionCategoryPlayAndRecord
                           withOptions:AVAudioSessionCategoryOptionDefaultToSpeaker
                                 error:&error];
            if (error) {
                NSLog(@"Error: %@", [error description]);
            }
            [_audioSession overrideOutputAudioPort:AVAudioSessionPortOverrideNone error:&error];
            if (error) {
                NSLog(@"Error: %@", [error description]);
            }
            break;
    }
}

@end
