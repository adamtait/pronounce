//
//  TCPTranslationView.m
//  pronounce
//
//  Created by Jonathan Xu on 3/2/14.
//  Copyright (c) 2014 Team Canada. All rights reserved.
//

#import "TCPTranslationCell.h"

@interface TCPTranslationCell ()
@property (weak, nonatomic) IBOutlet UILabel *fromTextLabel;
@property (weak, nonatomic) IBOutlet UILabel *fromLanguageLabel;
@property (weak, nonatomic) IBOutlet UILabel *toTextLabel;
@property (weak, nonatomic) IBOutlet UILabel *toLanguageLabel;
@end

@implementation TCPTranslationCell

+ (CGFloat)horizontalMargins
{
    return 20; // from xib
}

+ (CGFloat)verticalMargins
{
    return (20 + 4 + 10 + 4 + 20); // from xib
}

- (void)setModel:(TCPTranslationModel *)model
{
    _model = model;
    
    self.fromTextLabel.text = model.fromText;
    self.fromLanguageLabel.text = model.fromLanguage.englishName;
    self.toTextLabel.text = model.toText;
    self.toLanguageLabel.text = model.toLanguage.englishName;
}

@end
