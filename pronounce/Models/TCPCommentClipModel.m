//
//  TCPCommentClipModel.m
//  pronounce
//
//  Created by Jonathan Xu on 2/16/14.
//  Copyright (c) 2014 Team Canada. All rights reserved.
//

#import "TCPCommentClipModel.h"
#import "TCPAwsAPI.h"
#import "TCPUpvote.h"
#import "PFObject+Subclass.h"

@interface TCPCommentClipModel ()

    // private properties
    @property BOOL hasFinishedLoading;

    // private class methods
    + (NSString *)generateUUID;

    // private instance methods
    - (TCPUserProperties *)getSubmitterUserProperties;
    - (void)loadCompositeObjects;

@end

@implementation TCPCommentClipModel


#pragma mark - external references, local & synthesized properties

@synthesize delegate;
@synthesize userProperties;
@synthesize upvotes;
@synthesize currentUserHasUpvoted;
@synthesize audioFileUrl;
@synthesize hasFinishedLoading;

#pragma mark - Parse declared dynamic properties

@dynamic TCPTranslationModelObjectID;
@dynamic TCPUserPropertiesModelObjectID;
@dynamic uniqueID;



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
    query.cachePolicy = kPFCachePolicyCacheElseNetwork;
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error)
     {
         for (TCPCommentClipModel *commentClipModel in objects)
         {
             commentClipModel.hasFinishedLoading = NO;
             [commentClipModel loadCompositeObjects];
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
        self.hasFinishedLoading = YES;
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


#pragma mark - Private Instance Methods

- (TCPUserProperties *)getSubmitterUserProperties
{
    PFQuery *query = [PFQuery queryWithClassName:[TCPUserProperties parseClassName]];
    [query whereKey:@"objectId" equalTo:self.TCPUserPropertiesModelObjectID];
    query.cachePolicy = kPFCachePolicyCacheElseNetwork;
    return (TCPUserProperties *)[query getFirstObject];
}

- (void)setDelegate:(id<TCPModelUpdatedDelegate>)delegateReference
{
    self->delegate = delegateReference;
    if (self.hasFinishedLoading) {
        [self.delegate modelDidFinishLoadingWithSuccess:YES];
    }
}

- (void)loadCompositeObjects
{
    self.hasFinishedLoading = NO;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0),
                   ^{
                       self.userProperties = [self getSubmitterUserProperties];
                       self.upvotes = [TCPUpvote getCountForCommentClipModel:self];
                       self.currentUserHasUpvoted = [TCPUpvote existsWithCurrentUserForCommentClipModel:self];
                       self.hasFinishedLoading = YES;
                       
                       if (self.delegate) {
                           [self.delegate modelDidFinishLoadingWithSuccess:YES];
                       }
                   });
}

@end
