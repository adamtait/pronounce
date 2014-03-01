//
//  TCPLanguageProficiencyModel.m
//  pronounce
//
//  Created by Jonathan Xu on 2/28/14.
//  Copyright (c) 2014 Team Canada. All rights reserved.
//

#import "TCPLanguageProficiencyModel.h"
#import "PFObject+Subclass.h"

@implementation TCPLanguageProficiencyModel

@dynamic language;
@dynamic proficiencyLevel;

+ (NSString *)parseClassName
{
    return @"TCPLanguageProficiencyModel";
}

@end
