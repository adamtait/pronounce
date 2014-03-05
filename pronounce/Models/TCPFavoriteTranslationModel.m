//
//  TCPFavoriteTranslationModel.m
//  pronounce
//
//  Created by Jonathan Xu on 3/4/14.
//  Copyright (c) 2014 Team Canada. All rights reserved.
//

#import "TCPFavoriteTranslationModel.h"
#import "PFObject+Subclass.h"

@implementation TCPFavoriteTranslationModel

@dynamic TCPTranslationModelObjectID;
@dynamic TCPUserPropertiesModelObjectID;

+ (NSString *)parseClassName
{
    return @"TCPFavoriteTranslationModel";
}

+ (void)getByUserPropertiesID:(NSString *)userPropertiesID
           translationModelID:(NSString *)translationModelID
                   completion:(void (^)(TCPFavoriteTranslationModel *))completion
{
    PFQuery *query = [PFQuery queryWithClassName:[TCPFavoriteTranslationModel parseClassName]];
    [query whereKey:@"TCPUserPropertiesModelObjectID" equalTo:userPropertiesID];
    [query whereKey:@"TCPTranslationModelObjectID" equalTo:translationModelID];
    
    // for Parse cache policies, see https://www.parse.com/docs/ios_guide#queries-caching/iOS
//    query.cachePolicy = kPFCachePolicyCacheElseNetwork;
    [query getFirstObjectInBackgroundWithBlock:^(PFObject *object, NSError *error) {
        TCPFavoriteTranslationModel *model = (TCPFavoriteTranslationModel *)object;
        completion(model);
    }];
}

+ (NSArray *)favorites;
{
    return nil;
}

@end
