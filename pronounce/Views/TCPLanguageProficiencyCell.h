//
//  TCPLanguageProficiencyCell.h
//  pronounce
//
//  Created by Jonathan Xu on 2/27/14.
//  Copyright (c) 2014 Team Canada. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TCPLanguageProficiencyModel.h"
#import "TCPSelectLanguagePresenterDelegate.h"

@interface TCPLanguageProficiencyCell : UITableViewCell

+ (CGFloat)cellHeight;

@property (strong, nonatomic) TCPLanguageProficiencyModel *model;
@property (weak, nonatomic) id <TCPSelectLanguagePresenterDelegate> selectLanguagePresenterDelegate;

@end
