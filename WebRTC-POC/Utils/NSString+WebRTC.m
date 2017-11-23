//
//  NSString+WebRTC.m
//  WebRTC-POC
//
//  Created by BARIS YILMAZ on 18/11/2017.
//  Copyright © 2017 BARIS YILMAZ. All rights reserved.
//

#import "NSString+WebRTC.h"

@implementation NSString (WebRTC)

-(const char*)cStringWebRTC {
    return [self cStringUsingEncoding:kCFStringEncodingUTF8];
}

+(NSString *)stringWithCharList:(const char*)cString {
    return [NSString stringWithUTF8String:cString];
}

@end
