//
//  TCPTranslateAPI.m
//  pronounce
//
//  Created by Jonathan Xu on 2/16/14.
//  Copyright (c) 2014 Team Canada. All rights reserved.
//

#import "TCPTranslateAPI.h"

@implementation TCPTranslateAPI

+ (TCPTranslateAPI *)sharedInstance
{
    static dispatch_once_t once;
    static TCPTranslateAPI *instance;
    dispatch_once(&once, ^{
        instance = [[TCPTranslateAPI alloc] init];
    });
    return instance;
}

- (NSString *)translate:(NSString *)text
           fromLanguage:(TCPLanguageModel *)fromLanguage
             toLanguage:(TCPLanguageModel *)toLanguage
{
    return @"车站在哪里";
}

@end
