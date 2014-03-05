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

+ (TCPFavoriteTranslationModel *)favoriteTranslationModelByID:(NSString *)translationModelID
{
    return nil;
}

+ (NSArray *)favoritesForCurrentUser
{
    return nil;
}

@end
