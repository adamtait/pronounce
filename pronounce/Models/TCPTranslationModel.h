//
//  TCPTranslationModel.h
//  pronounce
//
//  Created by Jonathan Xu on 2/16/14.
//  Copyright (c) 2014 Team Canada. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TCPLanguageModel.h"
#import "TCPTranslateAPICompletionDelegate.h"
#import <Parse/Parse.h>

@interface TCPTranslationModel : PFObject <PFSubclassing, TCPTranslateAPICompletionDelegate>

    // public class methods
    + (NSString *)parseClassName;

    + (void)asyncLoadWithPhrase:(NSString *)phrase
                   fromLanguage:(TCPLanguageModel *)fromLanguage
                     toLanguage:(TCPLanguageModel *)toLanguage
                   viewDelegate:(id)viewDelegate
                     completion:(void (^)(TCPTranslationModel *))completion;


    // public properties
    @property (strong, nonatomic) NSString *phrase;
    @property (strong, nonatomic) TCPLanguageModel *fromLanguage;
    @property (strong, nonatomic) NSString *fromLanguageObjectId;
    @property (strong, nonatomic) TCPLanguageModel *toLanguage;
    @property (strong, nonatomic) NSString *toLanguageObjectId;
    @property (strong, nonatomic) NSString *exampleTranslation;
    @property (strong, nonatomic) NSMutableArray *commentClips;

@end
