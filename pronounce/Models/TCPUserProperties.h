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

@interface TCPUserProperties : PFObject <PFSubclassing>

+ (NSString *)parseClassName;

+ (TCPUserProperties *)currentUserProperties;

- (void)loginPFUser:(PFUser *)user;

@property (strong, nonatomic) PFUser *user;
@property (strong, nonatomic) NSString *facebookID;
@property (strong, nonatomic) NSString *name;
@property (strong, nonatomic) NSString *gender;
@property (strong, nonatomic) NSString *pictureURLString;
@property (strong, nonatomic) NSString *locationString;
@property (strong, nonatomic) NSMutableArray *languageProficiencyArray;
//@property (strong, nonatomic) NSArray *favorites; // of TCPTranslationModel
//@property (nonatomic) CLLocationCoordinate2D location;

- (void)syncToParse;
- (void)addLanguageProficiencyPlaceholder;

@end