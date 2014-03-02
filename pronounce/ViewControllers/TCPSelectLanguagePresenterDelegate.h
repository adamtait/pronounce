//
//  TCPSelectLanguagePresenterDelegate.h
//  pronounce
//
//  Created by Jonathan Xu on 3/1/14.
//  Copyright (c) 2014 Team Canada. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TCPSelectLanguageDelegate.h"

// When an UIView can not present the select language modal, use this delegate
@protocol TCPSelectLanguagePresenterDelegate <NSObject>
- (void)presentLanguageSelectionModal:(NSString *)title
               selectLanguageDelegate:(id <TCPSelectLanguageDelegate>)selectLanguageDelegate;
@end
