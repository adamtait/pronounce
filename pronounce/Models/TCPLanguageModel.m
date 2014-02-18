//
//  TCPLanguageModel.m
//  pronounce
//
//  Created by Jonathan Xu on 2/8/14.
//  Copyright (c) 2014 Team Canada. All rights reserved.
//

#import "TCPLanguageModel.h"

@implementation TCPLanguageModel

- (instancetype)init
{
    return nil;
}

- (instancetype)init:(NSString *)englishName
          nativeName:(NSString *)nativeName
       ietfShortCode:(NSString *)ietfShortCode
        ietfLongCode:(NSString *)ietfLongCode
{
    self = [super init];
    if (self) {
        self.englishName = englishName;
        self.nativeName = nativeName;
        self.ietfShortCode = ietfShortCode;
        self.ietfLongCode = ietfLongCode;
    }
    return self;
}

- (NSString *)getIetfLongCode
{
    return self.ietfLongCode ? self.ietfLongCode : self.ietfShortCode;
}

@end
