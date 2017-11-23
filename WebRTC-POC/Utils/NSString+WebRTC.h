//
//  NSString+WebRTC.h
//  WebRTC-POC
//
//  Created by BARIS YILMAZ on 18/11/2017.
//  Copyright © 2017 BARIS YILMAZ. All rights reserved.
//
 
#import <Foundation/Foundation.h>


@interface NSString (WebRTC)

-(const char*)cStringWebRTC;
+(NSString *)stringWithCharList:(const char*)cString;

@end
