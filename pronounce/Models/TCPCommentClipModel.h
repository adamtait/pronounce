//
//  TCPCommentClipModel.h
//  pronounce
//
//  Created by Jonathan Xu on 2/16/14.
//  Copyright (c) 2014 Team Canada. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import <Parse/Parse.h>
#import "TCPTranslationModel.h"
#import "TCPUserProperties.h"

@interface TCPCommentClipModel : PFObject <PFSubclassing>

    // public class methods
    + (NSString *)parseClassName;
    + (void)loadAllForTranslation:(TCPTranslationModel *)translation
                       completion:(void (^)(NSArray *))completion;

    // public instance methods
    - (id)initWithAudioDataFileURL:(NSURL *)audioData
                  translationModel:(TCPTranslationModel *)translationModel
               userPropertiesModel:(TCPUserProperties *)userPropertiesModel;
    - (void)saveAudioData;

    // public properties
//    @property (strong, nonatomic) TCPTranslationModel *translation;
    @property (nonatomic, strong) NSString *TCPTranslationModelObjectID;
    @property (nonatomic, strong) NSString *TCPUserPropertiesModelObjectID;
    @property (nonatomic, strong) TCPUserProperties *userProperties;
    @property (nonatomic, strong) NSString *uniqueID;
    @property (nonatomic, strong) NSURL *audioFileUrl;
    @property NSInteger upvotes;
    @property BOOL currentUserHasUpvoted;
//    @property (strong, nonatomic) NSDate *timestamp;
//    @property (strong, nonatomic) NSString *comment;
    
//    @property (strong, nonatomic) NSArray *ratings; // of TCPRatingModel

@end
