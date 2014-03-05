//
//  TCPFavoriteTranslationModel.h
//  pronounce
//
//  Created by Jonathan Xu on 3/4/14.
//  Copyright (c) 2014 Team Canada. All rights reserved.
//

#import <Parse/Parse.h>
#import "TCPTranslationModel.h"

@interface TCPFavoriteTranslationModel : PFObject <PFSubclassing>

+ (NSString *)parseClassName;

+ (void)favoritesWithCompletion:(void (^)(NSArray *))completion;

+ (void)getByTranslation:(TCPTranslationModel *)translation
              completion:(void (^)(TCPFavoriteTranslationModel *))completion;

@property (nonatomic, strong) PFUser *user;
@property (nonatomic, strong) TCPTranslationModel *translation;

@end
