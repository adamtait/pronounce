//
//  TCPLanguageCell.h
//  pronounce
//
//  Created by Jonathan Xu on 2/9/14.
//  Copyright (c) 2014 Team Canada. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TCPLanguageModel.h"

@interface TCPLanguageCell : UITableViewCell
@property (weak, nonatomic) TCPLanguageModel *model;
@property (nonatomic) BOOL checked;
@end
