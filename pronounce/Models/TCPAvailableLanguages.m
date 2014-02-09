//
//  TCPAvailableLanguages.m
//  pronounce
//
//  Created by Jonathan Xu on 2/8/14.
//  Copyright (c) 2014 Team Canada. All rights reserved.
//

#import "TCPAvailableLanguages.h"
#import "TCPLanguageModel.h"

@interface TCPAvailableLanguages ()
@property (strong, nonatomic) NSArray *languages;
@end

@implementation TCPAvailableLanguages

- (instancetype)init
{
    self = [super init];
    if (self) {
        TCPLanguageModel *en = [[TCPLanguageModel alloc] init:@"English"
                                                   nativeName:@"English"
                                                ietfShortCode:@"en"
                                                 ietfLongCode:@"en_US"];
        TCPLanguageModel *zh = [[TCPLanguageModel alloc] init:@"Chinese"
                                                   nativeName:@"中文"
                                                ietfShortCode:@"zh"
                                                 ietfLongCode:@"zh_CN"];
        self.languages = @[en, zh];
    }
    return self;
}

- (NSArray *)all
{
    return self.languages;
}

@end
