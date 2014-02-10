//
//  TCPSelectLanguageDelegate.h
//  pronounce
//
//  Created by Jonathan Xu on 2/10/14.
//  Copyright (c) 2014 Team Canada. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TCPLanguageModel.h"

@protocol TCPSelectLanguageDelegate <NSObject>
- (void)selectLanguage:(TCPLanguageModel *)language;
@end
