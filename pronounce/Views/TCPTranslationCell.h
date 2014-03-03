//
//  TCPTranslationView.h
//  pronounce
//
//  Created by Jonathan Xu on 3/2/14.
//  Copyright (c) 2014 Team Canada. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TCPTranslationModel.h"

@interface TCPTranslationCell : UITableViewCell

@property (strong, nonatomic) TCPTranslationModel *model;

- (CGFloat)calculatedHeight;

@end
