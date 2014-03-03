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

@interface TCPCommentClipModel : PFObject <PFSubclassing>

    + (NSString *)parseClassName;
    - (id)initWithAudioDataFileURL:(NSURL *)audioData;
    - (void)saveInBackground;

//    @property (strong, nonatomic) TCPTranslationModel *translation;
    @property (nonatomic, strong) NSString *uniqueID;
    @property (nonatomic, strong) NSURL *audioFileUrl;
//    @property (strong, nonatomic) NSDate *timestamp;
//    @property (strong, nonatomic) NSString *comment;
    
//    @property (strong, nonatomic) NSArray *ratings; // of TCPRatingModel

@end
