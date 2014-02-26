//
//  TCPUser.m
//  pronounce
//
//  Created by Jonathan Xu on 2/16/14.
//  Copyright (c) 2014 Team Canada. All rights reserved.
//

#import "TCPUser.h"

@interface TCPUser ()
@property (nonatomic) BOOL inSyncWithPFUser;
@end

@implementation TCPUser

+ (TCPUser *)currentUser
{
    static dispatch_once_t once;
    static TCPUser *instance;
    dispatch_once(&once, ^{
        instance = [[TCPUser alloc] init];
    });
    return instance;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.currentPFUser = [PFUser currentUser];
    }
    return self;
}

- (void)setCurrentPFUser:(PFUser *)user {
    _currentPFUser = user;
    if (user) {
        if (self.inSyncWithPFUser) {
            [[NSNotificationCenter defaultCenter] postNotificationName:@"userDidLogin" object:user];
        }
        else {
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
                    
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"userDidLogin" object:nil];
                }
            }];
        }
        
    }
}

@end
