//
//  TCPTranslateAPI.h
//  pronounce
//
//  Created by Jonathan Xu on 2/16/14.
//  Copyright (c) 2014 Team Canada. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TCPLanguageModel.h"

@interface TCPTranslateAPI : NSObject

+ (TCPTranslateAPI *)sharedInstance;

- (NSString *)translate:(NSString *)text
           fromLanguage:(TCPLanguageModel *)fromLanguage
             toLanguage:(TCPLanguageModel *)toLanguage;

@end
