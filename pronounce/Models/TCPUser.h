//
//  TCPUser.h
//  pronounce
//
//  Created by Jonathan Xu on 2/16/14.
//  Copyright (c) 2014 Team Canada. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import <Parse/Parse.h>

@interface TCPUser : PFObject <PFSubclassing>

+ (NSString *)parseClassName;

+ (TCPUser *)currentUser;

@property (strong, nonatomic) PFUser *currentPFUser;

@property (strong, nonatomic) NSString *facebookID;
@property (strong, nonatomic) NSString *name;
@property (strong, nonatomic) NSString *gender;
@property (strong, nonatomic) NSString *pictureURLString;

//@property (strong, nonatomic) NSDictionary *languagesByProficiencyLevel;
//@property (strong, nonatomic) NSArray *favorites; // of TCPTranslationModel
//@property (nonatomic) CLLocationCoordinate2D location;

- (void)loginWithPFUser:(PFUser *)pfUser;

@end