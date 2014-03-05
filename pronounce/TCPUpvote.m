//
//  TCPUpvote.m
//  pronounce
//
//  Created by Adam Tait on 3/4/14.
//  Copyright (c) 2014 Team Canada. All rights reserved.
//

#import "TCPUpvote.h"
#import "TCPUserProperties.h"
#import "PFObject+Subclass.h"

@implementation TCPUpvote

#pragma mark - Parse declared dynamic properties

@dynamic TCPUserPropertiesObjectID;
@dynamic TCPCommentClipModelObjectID;


#pragma mark - Public Class Methods

+ (NSString *)parseClassName
{
    return @"TCPUpvote";
}

+ (void)createWithCurrentUserForCommentClipModel:(TCPCommentClipModel *)commentClipModel
{
    TCPUpvote *upvote = [[TCPUpvote alloc] init];
    upvote.TCPUserPropertiesObjectID = [TCPUserProperties currentUserProperties].objectId;
    upvote.TCPCommentClipModelObjectID = commentClipModel.objectId;
    [upvote saveInBackground];
}

#pragma mark - asynchronous get methods

+ (void)getCountForCommentClipModel:(TCPCommentClipModel *)commentClipModel
                         completion:(void (^)(int, NSError*))completion
{
    PFQuery *query = [PFQuery queryWithClassName:[TCPUpvote parseClassName]];
    [query whereKey:@"TCPCommentClipModelObjectID" containsString:commentClipModel.objectId];
    query.cachePolicy = kPFCachePolicyNetworkOnly;  //kPFCachePolicyCacheElseNetwork;
    [query countObjectsInBackgroundWithBlock:completion];
}


+ (void)existsWithCurrentUserForCommentClipModel:(TCPCommentClipModel *)commentClipModel
                                      completion:(void (^)(BOOL))completion
{
    PFQuery *query = [PFQuery queryWithClassName:[TCPUpvote parseClassName]];
    [query whereKey:@"TCPCommentClipModelObjectID" containsString:commentClipModel.objectId];
    [query whereKey:@"TCPUserPropertiesObjectID" containsString:[TCPUserProperties currentUserProperties].objectId];
    query.cachePolicy = kPFCachePolicyNetworkOnly;  //kPFCachePolicyCacheElseNetwork;
    [query countObjectsInBackgroundWithBlock:^(int number, NSError * error)
     {
         completion(number > 0);
     }];
}


#pragma mark - synchronous get methods
// NOTE: these are generally bad, as they block the current thread while performing a network request

+ (int)getCountForCommentClipModel:(TCPCommentClipModel *)commentClipModel
{
    PFQuery *query = [PFQuery queryWithClassName:[TCPUpvote parseClassName]];
    [query whereKey:@"TCPCommentClipModelObjectID" containsString:commentClipModel.objectId];
    query.cachePolicy = kPFCachePolicyNetworkOnly;  //kPFCachePolicyCacheElseNetwork;
    NSError *error = nil;
    int count = [query countObjects:&error];
    if (error) {
        return 0;   // bad hard-coded default in case of error
    }
    return count;
}


+ (BOOL)existsWithCurrentUserForCommentClipModel:(TCPCommentClipModel *)commentClipModel
{
    PFQuery *query = [PFQuery queryWithClassName:[TCPUpvote parseClassName]];
    [query whereKey:@"TCPCommentClipModelObjectID" containsString:commentClipModel.objectId];
    query.cachePolicy = kPFCachePolicyNetworkOnly;  //kPFCachePolicyCacheElseNetwork;
    NSError *error = nil;
    int count = [query countObjects:&error];
    if (error) {
        return NO;      // bad hard-coded default in case of error
    }
    return (count > 0);
}

@end
