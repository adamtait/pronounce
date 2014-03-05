//
//  TCPFavoriteTranslationModel.h
//  pronounce
//
//  Created by Jonathan Xu on 3/4/14.
//  Copyright (c) 2014 Team Canada. All rights reserved.
//

#import <Parse/Parse.h>

@interface TCPFavoriteTranslationModel : PFObject <PFSubclassing>

+ (NSString *)parseClassName;

// APIs assumes current user properties
+ (NSArray *)favorites;

+ (void)getByUserPropertiesID:(NSString *)userPropertiesID
           translationModelID:(NSString *)translationModelID
                   completion:(void (^)(TCPFavoriteTranslationModel *))completion;


@property (nonatomic, strong) NSString *TCPUserPropertiesModelObjectID;
@property (nonatomic, strong) NSString *TCPTranslationModelObjectID;

@end
