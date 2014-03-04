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

@end

@implementation TCPCommentClipModel

#pragma mark - Parse declared dynamic properties

@dynamic TCPTranslationModelObjectID;
@dynamic uniqueID;
//@dynamic comment;
//@synthesize ratings;
@synthesize audioFileUrl;


#pragma mark - Public Class Methods

+ (NSString *)parseClassName
{
    return @"TCPCommentClipModel";
}

+ (void)loadAllForTranslation:(TCPTranslationModel *)translation
                   completion:(void (^)(NSArray *))completion
{
    // request matching TCPCommentClipModel from Parse
    PFQuery *query = [PFQuery queryWithClassName:[TCPCommentClipModel parseClassName]];
    [query whereKey:@"TCPTranslationModelObjectID" containsString:translation.objectId];
    NSLog(@"trying to load commentClipModels for translation / %@ /", translation.objectId);
    
    // for Parse cache policies, see https://www.parse.com/docs/ios_guide#queries-caching/iOS
    query.cachePolicy = kPFCachePolicyCacheElseNetwork;
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error)
     {
         NSLog(@"found %lu comment clip models / %@ /", (unsigned long)[objects count] ,objects);
         completion(objects);
     }];
}


#pragma mark - Private Class Methods

+ (NSString *)generateUUID
{
    CFUUIDRef uuid = CFUUIDCreate(kCFAllocatorDefault);
    return (__bridge_transfer NSString *)CFUUIDCreateString(kCFAllocatorDefault, uuid);
}


#pragma mark - Public Instance Methods

- (id)initWithAudioDataFileURL:(NSURL *)audioData
              translationModel:(TCPTranslationModel *)translationModel
{
    self = [super init];
    if (self) {
        self.TCPTranslationModelObjectID = translationModel.objectId;
        self.uniqueID = [TCPCommentClipModel generateUUID];
        self.audioFileUrl = audioData;
    }
    return self;
}

- (void)saveAudioData
{
    NSData *audioData = [[NSFileManager defaultManager] contentsAtPath:[self.audioFileUrl path]];

    // save the audio to S3
    [TCPAwsAPI uploadAudioData:audioData forUUID:self.uniqueID];

    // save instance properties to Parse
    [self saveInBackground];
}

@end
