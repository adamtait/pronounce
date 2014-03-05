//
//  TCPTranslationView.h
//  pronounce
//
//  Created by Jonathan Xu on 3/2/14.
//  Copyright (c) 2014 Team Canada. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TCPTranslationModel.h"
#import "TCPFavoriteTranslationModel.h"

@interface TCPTranslationCell : UITableViewCell

+ (CGFloat)horizontalMargins;
+ (CGFloat)verticalMargins;

// required
@property (strong, nonatomic) TCPTranslationModel *model;
// optional
@property (strong, nonatomic) TCPFavoriteTranslationModel *favoriteTranslationModel;
@end
