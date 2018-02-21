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
    bool _isAudioActive;
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
        _isAudioActive = false;
        [self configureAudioSession];
    }
    return self;
}

- (void)configureAudioSession {
    NSError *error;
    _audioSession = [AVAudioSession sharedInstance];
    [_audioSession setCategory:AVAudioSessionCategoryPlayAndRecord error:&error];
    if (error) {
        NSLog(@"setCategory: error: %@", [error description]);
    }
    
    [_audioSession setMode:AVAudioSessionModeVoiceChat error:&error];
    if (error) {
        NSLog(@"setCategory: error: %@", [error description]);
    }
}

- (void)startAudio {
    if (_isAudioActive == true) {
        NSLog(@"************************* AudioService::startAudio NO NEED TO START AUDIO AGAIN");
        return;
    }
    _isAudioActive = true;
    NSLog(@"************************* AudioService::startAudio");
    NSError *error;
    [_audioSession setActive:true error:&error];
    if (error) {
        NSLog(@"Error: %@", [error description]);
    }
}

- (void)stopAudio {
    if (_isAudioActive == false) {
        NSLog(@"************************* AudioService::stopAudio NO NEED TO STOP AUDIO AGAIN");
        return;
    }
    _isAudioActive = false;
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
