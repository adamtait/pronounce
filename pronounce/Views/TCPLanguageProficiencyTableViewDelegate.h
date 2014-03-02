//
//  TCPLanguageProficiencyTableViewDelegate.h
//  pronounce
//
//  Created by Jonathan Xu on 3/1/14.
//  Copyright (c) 2014 Team Canada. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TCPSelectLanguageDelegate.h"

@protocol TCPLanguageProficiencyTableViewDelegate <NSObject>
// whether it is a good time to add a language.
// it is no when a new language has been added and has not been changed to a known language.
- (void)readyToAddLanguage:(BOOL)ready;
@end
