//
//  TCPSelectLanguageViewController.h
//  pronounce
//
//  Created by Jonathan Xu on 2/9/14.
//  Copyright (c) 2014 Team Canada. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TCPSelectLanguageDelegate.h"

@interface TCPSelectLanguageViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>
@property (weak, nonatomic) id <TCPSelectLanguageDelegate> selectLanguageDelegate;
@end