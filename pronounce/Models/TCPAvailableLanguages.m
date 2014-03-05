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

+ (TCPAvailableLanguages *)sharedInstance
{
    static dispatch_once_t once;
    static TCPAvailableLanguages *instance;
    dispatch_once(&once, ^{
        instance = [[TCPAvailableLanguages alloc] init];
    });
    return instance;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        // TODO: on main thread, uses network first time, could use NSNotification
        PFQuery *query = [PFQuery queryWithClassName:[TCPLanguageModel parseClassName]];
        [query orderByAscending:@"englishName"];
        // https://www.parse.com/docs/ios_guide#queries-caching/iOS
        query.cachePolicy = kPFCachePolicyCacheElseNetwork;
        self.languages = [query findObjects];
    }
    return self;
}

- (NSUInteger)count
{
    return [self.languages count];
}

- (TCPLanguageModel *)objectAtIndex:(NSUInteger)index
{
    return [self.languages objectAtIndex:index];
}

- (TCPLanguageModel *)languageByObjectID:(NSString *)objectID
{
    for (TCPLanguageModel *lan in self.languages) {
        if ([lan.objectId isEqualToString:objectID]) {
            return lan;
        }
    }
    return nil;
}

- (TCPLanguageModel *)languageByLongCode:(NSString *)code
{
    for (TCPLanguageModel *lan in self.languages) {
        if ([lan.ietfLongCode isEqualToString:code]) {
            return lan;
        }
    }
    return nil;
}

@end
