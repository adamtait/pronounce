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
@dynamic TCPUserPropertiesModelObjectID;
@synthesize userProperties;
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
    
    // for Parse cache policies, see https://www.parse.com/docs/ios_guide#queries-caching/iOS
    query.cachePolicy = kPFCachePolicyNetworkOnly;  //kPFCachePolicyCacheElseNetwork;
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error)
     {
         for (TCPCommentClipModel *commentClipModel in objects) {
             PFQuery *query = [PFQuery queryWithClassName:[TCPUserProperties parseClassName]];
             [query whereKey:@"objectId" equalTo:commentClipModel.TCPUserPropertiesModelObjectID];
             query.cachePolicy = kPFCachePolicyNetworkOnly;     //kPFCachePolicyCacheElseNetwork;
             commentClipModel.userProperties = (TCPUserProperties *)[query getFirstObject];
             NSLog(@"got user properties / %@ / for user properties objectId / %@ /", commentClipModel.userProperties, commentClipModel.TCPUserPropertiesModelObjectID);
         }
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
           userPropertiesModel:(TCPUserProperties *)userPropertiesModel
{
    self = [super init];
    if (self) {
        self.TCPTranslationModelObjectID = translationModel.objectId;
        self.uniqueID = [TCPCommentClipModel generateUUID];
        self.audioFileUrl = audioData;
        self.userProperties = userPropertiesModel;
        self.TCPUserPropertiesModelObjectID = userPropertiesModel.objectId;
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
