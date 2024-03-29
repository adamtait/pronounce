//
//  TCPLanguageProficiencyTableView.h
//  pronounce
//
//  Created by Jonathan Xu on 2/28/14.
//  Copyright (c) 2014 Team Canada. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TCPSelectLanguagePresenterDelegate.h"

@interface TCPLanguageProficiencyTableView : UITableView

// pass to each cell to bring up select language modal
@property (weak, nonatomic) id <TCPSelectLanguagePresenterDelegate> selectLanguagePresenterDelegate;

- (void)addLanguage;

@end
