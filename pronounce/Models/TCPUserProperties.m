//
//  TCPUser.m
//  pronounce
//
//  Created by Jonathan Xu on 2/16/14.
//  Copyright (c) 2014 Team Canada. All rights reserved.
//

#import "TCPUserProperties.h"
#import "TCPLanguageProficiencyModel.h"
#import "PFObject+Subclass.h"

@implementation TCPUserProperties

@dynamic user;
@dynamic facebookID;
@dynamic name;
@dynamic gender;
@dynamic pictureURLString;
@dynamic locationString;
@dynamic languageProficiencyArray;

+ (NSString *)parseClassName
{
    return @"TCPUserProperties";
}

// singleton

+ (TCPUserProperties *)currentUserProperties
{
    static dispatch_once_t once;
    static TCPUserProperties *instance;
    dispatch_once(&once, ^{
        if (!instance) {
            instance = [[TCPUserProperties alloc] init];
        }
    });
    return instance;
}

- (void)loginPFUser:(PFUser *)user
{
    PFQuery *query = [PFQuery queryWithClassName:[TCPUserProperties parseClassName]];
    [query whereKey:@"user" equalTo:user];
    
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (objects) {
            TCPUserProperties *userProperties = [TCPUserProperties currentUserProperties];
            if ([objects count] == 0) {
                userProperties.user = user;
                
                FBRequest *fbRequest = [FBRequest requestForMe];
                [fbRequest startWithCompletionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
                    if (!error) {
                        // result is a dictionary with the user's Facebook data
                        NSDictionary *userData = (NSDictionary *)result;
                        
                        userProperties.facebookID = userData[@"id"];
                        userProperties.name = userData[@"name"];
                        userProperties.gender = userData[@"gender"];
                        
                        NSDictionary *locationDict = userData[@"location"];
                        if (locationDict) {
                            userProperties.locationString = locationDict[@"name"];
                        }
                        
                        userProperties.pictureURLString = [NSString stringWithFormat:@"https://graph.facebook.com/%@/picture?type=large&return_ssl_resources=1", userProperties.facebookID];
                        
                        [userProperties saveInBackground];
                    }
                }];
            }
            else if ([objects count] == 1) {
                userProperties.objectId = ((TCPUserProperties *)[objects firstObject]).objectId;
                [userProperties fetchInBackgroundWithBlock:^(PFObject *object, NSError *error) {
                    NSLog(@"fetched userProperties in background");
                    [PFObject fetchAllIfNeededInBackground:userProperties.languageProficiencyArray
                                                     block:^(NSArray *objects, NSError *error) {
                        NSLog(@"fetched userProperties.languageProficiencyArray in background");
                    }];
                }];
            }
            else {
                NSLog(@"TCPUserProperties:initSingletonWithPFUser: more than 1 TCPUserProperties for user %@", user.objectId);
            }
        }
        else {
            NSLog(@"TCPUserProperties:initCurrentUserPropertiesWithUser: Parse returned nil for user %@", user.objectId);
        }
    }];
}

#pragma mark - APIs

- (void)syncToParse
{
    [self saveInBackground];
}

- (void)addLanguageProficiencyPlaceholder
{
    TCPLanguageProficiencyModel *placeholder = [[TCPLanguageProficiencyModel alloc] init];
    if (!self.languageProficiencyArray) {
        self.languageProficiencyArray = [[NSMutableArray alloc] init];
    }
    [self.languageProficiencyArray insertObject:placeholder atIndex:0];
}

@end
