//
//  TCPUpvote.h
//  pronounce
//
//  Created by Adam Tait on 3/4/14.
//  Copyright (c) 2014 Team Canada. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Parse/Parse.h>
#import "TCPCommentClipModel.h"

@interface TCPUpvote : PFObject <PFSubclassing>

    // public class methods
    + (NSString *)parseClassName;
    + (void)createWithCurrentUserForCommentClipModel:(TCPCommentClipModel *)commentClipModel;

    // asynchronous get methods
    + (void)getCountForCommentClipModel:(TCPCommentClipModel *)commentClipModel
                             completion:(void (^)(int, NSError*))completion;
    + (void)existsWithCurrentUserForCommentClipModel:(TCPCommentClipModel *)commentClipModel
                                          completion:(void (^)(BOOL))completion;

    // synchonous get methods
    + (int)getCountForCommentClipModel:(TCPCommentClipModel *)commentClipModel;
    + (BOOL)existsWithCurrentUserForCommentClipModel:(TCPCommentClipModel *)commentClipModel;

    // public properties
    @property (nonatomic, strong) NSString *TCPUserPropertiesObjectID;
    @property (nonatomic, strong) NSString *TCPCommentClipModelObjectID;

@end
