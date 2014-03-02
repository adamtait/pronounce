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

static TCPUserProperties *instance;

+ (TCPUserProperties *)currentUserProperties
{
    PFUser *user = [PFUser currentUser];
    
    static dispatch_once_t once;
    static TCPUserProperties *instance;
    dispatch_once(&once, ^{
        if (!instance) {
            PFQuery *query = [PFQuery queryWithClassName:[TCPUserProperties parseClassName]];
            [query whereKey:@"user" equalTo:user];
            [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
                if (objects) {
                    if ([objects count] == 0) {
                        instance = [[TCPUserProperties alloc] init];
                        instance.user = user;
                        
                        FBRequest *fbRequest = [FBRequest requestForMe];
                        [fbRequest startWithCompletionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
                            if (!error) {
                                // result is a dictionary with the user's Facebook data
                                NSDictionary *userData = (NSDictionary *)result;
                                
                                instance.facebookID = userData[@"id"];
                                instance.name = userData[@"name"];
                                instance.gender = userData[@"gender"];
                                
                                NSDictionary *locationDict = userData[@"location"];
                                if (locationDict) {
                                    instance.locationString = locationDict[@"name"];
                                }
                                
                                instance.pictureURLString = [NSString stringWithFormat:@"https://graph.facebook.com/%@/picture?type=large&return_ssl_resources=1", instance.facebookID];
                                
                                [instance saveInBackground];
                            }
                        }];
                    }
                    else if ([objects count] == 1) {
                        instance = [objects firstObject];
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
    });
    return instance;
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
        self.languageProficiencyArray = @[placeholder];
    }
    else {
        NSMutableArray *mutable = [[NSMutableArray alloc] init];
        [mutable addObject:placeholder];
        [mutable addObjectsFromArray:self.languageProficiencyArray];
        self.languageProficiencyArray = [mutable copy];
    }
    
}

@end
