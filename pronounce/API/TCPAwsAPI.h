//
//  TCPAwsAPI.h
//  pronounce
//
//  Created by Adam Tait on 2/25/14.
//  Copyright (c) 2014 Team Canada. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TCPAwsAPI : NSObject

    // public class methods
    + (NSString *)generateS3KeyForUUID:(NSString *)uuid;
    + (NSURL *)getS3UrlForUUID:(NSString *)uuid;
    + (void)uploadAudioData:(NSData*)dataToUpload forUUID:(NSString *)uuid;

@end
