//
//  TCPTranslateAPI.h
//  pronounce
//
//  Created by Jonathan Xu on 2/16/14.
//  Copyright (c) 2014 Team Canada. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TCPLanguageModel.h"
#import "TCPTranslateAPICompletionDelegate.h"

@interface TCPTranslateAPI : NSObject

// Not thread-safe
+ (TCPTranslateAPI *)sharedInstance;

- (void)translate:(NSString *)fromText
     fromLanguage:(TCPLanguageModel *)fromLanguage
       toLanguage:(TCPLanguageModel *)toLanguage;

@property (weak, nonatomic) id <TCPTranslateAPICompletionDelegate> completionDelegate;

@end
