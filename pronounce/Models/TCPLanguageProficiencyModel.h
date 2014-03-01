//
//  TCPLanguageProficiencyModel.h
//  pronounce
//
//  Created by Jonathan Xu on 2/28/14.
//  Copyright (c) 2014 Team Canada. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TCPLanguageModel.h"
#import <Parse/Parse.h>

@interface TCPLanguageProficiencyModel : PFObject <PFSubclassing>

+ (NSString *)parseClassName;

@property (strong, nonatomic) TCPLanguageModel *language;
@property (nonatomic) NSUInteger proficiencyLevel; // 0 to 2
@end
