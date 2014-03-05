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

@dynamic user;
@dynamic translation;

+ (NSString *)parseClassName
{
    return @"TCPFavoriteTranslationModel";
}

+ (void)favoritesWithCompletion:(void (^)(NSArray *))completion
{
    PFUser *user = [PFUser currentUser];
    if (!user) {
        completion(nil);
        return;
    }
    
    PFQuery *query = [PFQuery queryWithClassName:[TCPFavoriteTranslationModel parseClassName]];
    [query whereKey:@"user" equalTo:user];
    [query includeKey:@"translation"];
    
    // for Parse cache policies, see https://www.parse.com/docs/ios_guide#queries-caching/iOS
    //    query.cachePolicy = kPFCachePolicyCacheElseNetwork;
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        completion(objects);
    }];
}

+ (void)getByTranslation:(TCPTranslationModel *)translation
              completion:(void (^)(TCPFavoriteTranslationModel *))completion
{
    PFUser *user = [PFUser currentUser];
    if (!user) {
        completion(nil);
        return;
    }

    PFQuery *query = [PFQuery queryWithClassName:[TCPFavoriteTranslationModel parseClassName]];
    [query whereKey:@"user" equalTo:user];
    [query whereKey:@"translation" equalTo:translation];
    [query includeKey:@"translation"];
    
    // for Parse cache policies, see https://www.parse.com/docs/ios_guide#queries-caching/iOS
//    query.cachePolicy = kPFCachePolicyCacheElseNetwork;
    [query getFirstObjectInBackgroundWithBlock:^(PFObject *object, NSError *error) {
        TCPFavoriteTranslationModel *model = (TCPFavoriteTranslationModel *)object;
        completion(model);
    }];
}

- (instancetype)initWithTranslation:(TCPTranslationModel *)translation
{
    self = [super init];
    
    if (self) {
        self.user = [PFUser currentUser];
        self.translation = translation;
        [self saveInBackground];
    }

    return self;
}

@end
