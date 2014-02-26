//
//  TCPCommentClipModel.m
//  pronounce
//
//  Created by Jonathan Xu on 2/16/14.
//  Copyright (c) 2014 Team Canada. All rights reserved.
//

#import "TCPCommentClipModel.h"
#import "TCPAwsAPI.h"

@interface TCPCommentClipModel ()

    // private properties
    @property (nonatomic, strong) NSString *uniqueID;
    @property (nonatomic, strong) NSURL *audioFileUrl;

    // private class methods
    + (NSString *)generateUUID;

@end

@implementation TCPCommentClipModel

+ (NSString *)generateUUID
{
    CFUUIDRef uuid = CFUUIDCreate(kCFAllocatorDefault);
    return (__bridge_transfer NSString *)CFUUIDCreateString(kCFAllocatorDefault, uuid);
}

- (id)initWithAudioDataFileURL:(NSURL *)audioData
{
    self = [super init];
    if (self) {
        _uniqueID = [TCPCommentClipModel generateUUID];
        _audioFileUrl = audioData;
    }
    return self;
}

- (void)saveInBackground
{
    NSData *audioData = [[NSFileManager defaultManager] contentsAtPath:[_audioFileUrl path]];
    NSString *awsKey = [NSString stringWithFormat:@"comment_clip_%@", _uniqueID];
    [TCPAwsAPI upload:audioData inBucket:@"pronounce" forKey:awsKey];
}

@end
