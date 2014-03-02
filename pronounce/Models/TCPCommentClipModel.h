//
//  TCPCommentClipModel.h
//  pronounce
//
//  Created by Jonathan Xu on 2/16/14.
//  Copyright (c) 2014 Team Canada. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import "TCPTranslationModel.h"

@interface TCPCommentClipModel : NSObject

    @property (strong, nonatomic) TCPTranslationModel *translation;
    @property (strong, nonatomic) NSDate *timestamp;
    @property (strong, nonatomic) NSString *comment;
    @property (strong, nonatomic) NSString *clipUrl;
    @property (nonatomic) CLLocationCoordinate2D locationofSubmission;
    @property (strong, nonatomic) NSArray *ratings; // of TCPRatingModel

    - (id)initWithAudioDataFileURL:(NSURL *)audioData;
    - (void)saveInBackground;
@end
