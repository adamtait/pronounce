//
//  TCPCommentClipModel.m
//  pronounce
//
//  Created by Jonathan Xu on 2/16/14.
//  Copyright (c) 2014 Team Canada. All rights reserved.
//

#import "TCPCommentClipModel.h"
#import "TCPAwsAPI.h"
#import "PFObject+Subclass.h"

@interface TCPCommentClipModel ()

    // private class methods
    + (NSString *)generateUUID;

    // private properties
    

    // private instance methods
    - (NSString *)generateS3Key;

@end

@implementation TCPCommentClipModel

@dynamic uniqueID;
//@dynamic comment;
//@synthesize ratings;
@synthesize audioFileUrl;


#pragma mark - Public Class Methods

+ (NSString *)parseClassName
{
    return @"TCPCommentClipModel";
}


#pragma mark - Private Class Methods

+ (NSString *)generateUUID
{
    CFUUIDRef uuid = CFUUIDCreate(kCFAllocatorDefault);
    return (__bridge_transfer NSString *)CFUUIDCreateString(kCFAllocatorDefault, uuid);
}


#pragma mark - Public Instance Methods

- (id)initWithAudioDataFileURL:(NSURL *)audioData
{
    self = [super init];
    if (self) {
        self.uniqueID = [TCPCommentClipModel generateUUID];
        self.audioFileUrl = audioData;
    }
    return self;
}

- (void)saveInBackground
{
    NSData *audioData = [[NSFileManager defaultManager] contentsAtPath:[self.audioFileUrl path]];
    NSString *awsKey = [self generateS3Key];

    // save the audio to S3
    [TCPAwsAPI upload:audioData inBucket:@"pronounce" forKey:awsKey];

    // save instance properties to Parse
    [self save];
}


#pragma mark - Private Instance Methods

- (NSString *)generateS3Key
{
    return [NSString stringWithFormat:@"comment_clip_%@", self.uniqueID];
}

@end
