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

+ (TCPLanguageModel *)loadFromObjectId:(NSString *)objectId
{
    // try loading from Parse (with PFQuery)
    PFQuery *query = [PFQuery queryWithClassName:[TCPLanguageModel parseClassName]];
    [query whereKey:@"objectId"       equalTo:objectId];
    
    // for Parse cache policies, see https://www.parse.com/docs/ios_guide#queries-caching/iOS
    query.cachePolicy = kPFCachePolicyCacheElseNetwork;
    
    NSError *error = nil;
    return [query findObjects:&error].firstObject;
}

- (NSString *)getIetfLongCode
{
    return self.ietfLongCode ? self.ietfLongCode : self.ietfShortCode;
}

@end
