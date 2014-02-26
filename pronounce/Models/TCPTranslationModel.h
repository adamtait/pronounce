//
//  TCPTranslationModel.h
//  pronounce
//
//  Created by Jonathan Xu on 2/16/14.
//  Copyright (c) 2014 Team Canada. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TCPLanguageModel.h"

@interface TCPTranslationModel : NSObject

    @property (strong, nonatomic) NSString *fromText;
    @property (strong, nonatomic) TCPLanguageModel *fromLanguage;
    @property (strong, nonatomic) NSString *toText;
    @property (strong, nonatomic) TCPLanguageModel *toLanguage;

@end
