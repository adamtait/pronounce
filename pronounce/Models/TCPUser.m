//
//  TCPUser.m
//  pronounce
//
//  Created by Jonathan Xu on 2/16/14.
//  Copyright (c) 2014 Team Canada. All rights reserved.
//

#import "TCPUser.h"

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

@end
