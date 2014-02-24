//
//  TCPTranslatorAPICompletionDelegate.h
//  pronounce
//
//  Created by Jonathan Xu on 2/22/14.
//  Copyright (c) 2014 Team Canada. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol TCPTranslateAPICompletionDelegate <NSObject>
- (void)completeWithTranslatedString:(NSString *)toText success:(BOOL)success;
@end
