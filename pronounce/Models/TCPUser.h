//
//  TCPUser.h
//  pronounce
//
//  Created by Jonathan Xu on 2/16/14.
//  Copyright (c) 2014 Team Canada. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@interface TCPUser : NSObject

+ (TCPUser *)currentUser;

@property (nonatomic) long long facebookId;
@property (strong, nonatomic) NSString *name;
@property (strong, nonatomic) NSString *profileImageUrl;
@property (strong, nonatomic) NSDictionary *languagesByProficiencyLevel;
@property (strong, nonatomic) NSArray *favorites; // of TCPTranslationModel
@property (nonatomic) CLLocationCoordinate2D location;

@end