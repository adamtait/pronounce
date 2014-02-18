//
//  TCPLanguageCell.m
//  pronounce
//
//  Created by Jonathan Xu on 2/9/14.
//  Copyright (c) 2014 Team Canada. All rights reserved.
//

#import "TCPLanguageCell.h"

@interface TCPLanguageCell ()
@property (weak, nonatomic) IBOutlet UILabel *englishNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *nativeNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *checkedLabel;
@end

@implementation TCPLanguageCell

- (void)setModel:(TCPLanguageModel *)model
{
    _model = model;
    self.englishNameLabel.text = model.englishName;
    self.nativeNameLabel.text = model.nativeName;
}

- (void)setChecked:(BOOL)checked
{
    _checked = checked;
    self.checkedLabel.hidden = !checked;
}

@end
