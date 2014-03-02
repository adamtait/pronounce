//
//  TCPLanguageModel.h
//  pronounce
//
//  Created by Jonathan Xu on 2/8/14.
//  Copyright (c) 2014 Team Canada. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Parse/Parse.h>

@interface TCPLanguageModel : PFObject <PFSubclassing>

+ (NSString *)parseClassName;

@property (strong, nonatomic) NSString *englishName; // English, Chinese
@property (strong, nonatomic) NSString *nativeName; // English, 中文
@property (strong, nonatomic) NSString *ietfShortCode; // en, zh
@property (strong, nonatomic) NSString *ietfLongCode; // en-US, zh-CN

@end
