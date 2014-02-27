//
//  TCPUser.m
//  pronounce
//
//  Created by Jonathan Xu on 2/16/14.
//  Copyright (c) 2014 Team Canada. All rights reserved.
//

#import "TCPUser.h"
#import "PFObject+Subclass.h"

@interface TCPUser ()
@end

@implementation TCPUser

@dynamic currentPFUser;
@dynamic facebookID;
@dynamic name;
@dynamic gender;
@dynamic pictureURLString;

+ (NSString *)parseClassName
{
    return @"TCPUser";
}

+ (TCPUser *)currentUser
{
    static dispatch_once_t once;
    static TCPUser *instance;
    dispatch_once(&once, ^{
        // get current PFUser, if exists, and if it has a reference to TCPUser, initialize TCPUser with that reference.
        // otherwise, initialize a new TCPUser
        PFUser *pfUser = [PFUser currentUser];
        if (!pfUser) {
            instance = [[TCPUser alloc] init];
        }
        else {
            NSString *tcpUserRef = [pfUser objectForKey:@"tcpuser_id"];
            if (!tcpUserRef) {
                instance = [[TCPUser alloc] init];
                [instance loginWithPFUser:pfUser];
            }
            else {
                instance = [TCPUser objectWithoutDataWithObjectId:tcpUserRef];
                instance.currentPFUser = pfUser; // this needs to be manually set
                [instance fetchIfNeeded];
            }
        }
    });
    return instance;
}

- (void)loginWithPFUser:(PFUser *)pfUser {
    self.currentPFUser = pfUser;
    if (pfUser) {
        // fetch user detail, set on self, and save to Parse
        // also set a reference on PFUser that points to self

        __weak TCPUser *weakSelf = self;
        
        FBRequest *fbRequest = [FBRequest requestForMe];
        [fbRequest startWithCompletionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
            if (!error) {
                // result is a dictionary with the user's Facebook data
                NSDictionary *userData = (NSDictionary *)result;
                
                weakSelf.facebookID = userData[@"id"];
                weakSelf.name = userData[@"name"];
                weakSelf.gender = userData[@"gender"];
                weakSelf.pictureURLString = [NSString stringWithFormat:@"https://graph.facebook.com/%@/picture?type=large&return_ssl_resources=1", weakSelf.facebookID];
                
                [weakSelf saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                    [pfUser setObject:weakSelf.objectId forKey:@"tcpuser_id"];
                    [pfUser saveInBackground];
                }];
                
                [[NSNotificationCenter defaultCenter] postNotificationName:@"userDidLogin" object:nil];
            }
        }];
    }
}

@end
