//
//  TCPAvailableLanguages.h
//  pronounce
//
//  Created by Jonathan Xu on 2/8/14.
//  Copyright (c) 2014 Team Canada. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TCPLanguageModel.h"

@interface TCPAvailableLanguages : NSObject
+ (TCPAvailableLanguages *)sharedInstance;
- (NSUInteger)count;
- (TCPLanguageModel *)objectAtIndex:(NSUInteger)index;
- (TCPLanguageModel *)languageByObjectID:(NSString *)objectID;
- (TCPLanguageModel *)languageByLongCode:(NSString *)code;
@end
