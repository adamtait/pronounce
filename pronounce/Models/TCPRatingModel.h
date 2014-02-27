//
//  TCPRatingModel.h
//  pronounce
//
//  Created by Jonathan Xu on 2/16/14.
//  Copyright (c) 2014 Team Canada. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TCPUserProperties.h"

@interface TCPRatingModel : NSObject
@property (strong, nonatomic) TCPUserProperties *user;
@property (nonatomic) int rating;
@end
