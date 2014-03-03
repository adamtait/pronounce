//
//  TCPLanguageModel.m
//  pronounce
//
//  Created by Jonathan Xu on 2/8/14.
//  Copyright (c) 2014 Team Canada. All rights reserved.
//

#import "TCPLanguageModel.h"
#import "PFObject+Subclass.h"

@implementation TCPLanguageModel

@dynamic englishName;
@dynamic nativeName;
@dynamic ietfShortCode;
@dynamic ietfLongCode;

+ (NSString *)parseClassName
{
    return @"TCPLanguageModel";
}

- (NSString *)getIetfLongCode
{
    return self.ietfLongCode ? self.ietfLongCode : self.ietfShortCode;
}

@end
