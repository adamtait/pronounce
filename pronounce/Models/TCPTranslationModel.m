//
//  TCPTranslationModel.m
//  pronounce
//
//  Created by Jonathan Xu on 2/16/14.
//  Copyright (c) 2014 Team Canada. All rights reserved.
//

#import "TCPTranslationModel.h"
#import "TCPCommentClipModel.h"
#import "TCPTranslateAPI.h"
#import "PFObject+Subclass.h"

@interface TCPTranslationModel ()

    // private instance methods
    - (void)completeWithTranslatedString:(NSString *)toText success:(BOOL)success;
    - (void)loadLanguages;

    // private properties
    @property (weak, nonatomic) id <TCPTranslateAPICompletionDelegate> viewDelegate;

@end


@implementation TCPTranslationModel

#pragma mark - Parse declared dynamic properties

// properties saved to Parse
@dynamic phrase;                // type: NSString
@dynamic fromLanguageObjectId;  // type: NSString
@dynamic toLanguageObjectId;    // type: NSString
@dynamic exampleTranslation;    // type: NSString

// properties & associations that exist only in memory
@synthesize fromLanguage;       // type: TCPLanguageModel
@synthesize toLanguage;         // type: TCPLanguageModel
@synthesize commentClips;       // type: NSMutableArray
@synthesize viewDelegate;       // type: TCPTranslateViewController


#pragma mark - public class methods

+ (NSString *)parseClassName
{
    return @"TCPTranslationModel";
}

#pragma mark - public instance methods

+ (void)asyncLoadWithPhrase:(NSString *)phrase
             fromLanguage:(TCPLanguageModel *)fromLanguage
               toLanguage:(TCPLanguageModel *)toLanguage
             viewDelegate:(id)viewDelegate
               completion:(void (^)(TCPTranslationModel *))completion
{
    // try loading from Parse (with PFQuery)
    // request matching TranslationModel from Parse
    PFQuery *query = [PFQuery queryWithClassName:[TCPTranslationModel parseClassName]];
    [query whereKey:@"phrase"       equalTo:phrase];
    [query whereKey:@"fromLanguage" equalTo:fromLanguage];
    [query whereKey:@"toLanguage"   equalTo:toLanguage];
    
    // for Parse cache policies, see https://www.parse.com/docs/ios_guide#queries-caching/iOS
    query.cachePolicy = kPFCachePolicyCacheElseNetwork;
    [query getFirstObjectInBackgroundWithBlock:^(PFObject *object, NSError *error)
    {
        if (!error) {
            // Results were successfully found, looking first on the
            // network and then on disk.
            
            TCPTranslationModel *model = (TCPTranslationModel *)object;
            model.viewDelegate = viewDelegate;
            
            [model loadLanguages];
            
            // request matching CommentClips from Parse
            [TCPCommentClipModel loadAllForTranslation:model
                                            completion:^(NSArray *commentClips)
             {
                 model.commentClips = [NSMutableArray arrayWithArray:commentClips];
                 
                 // done loading all the dependent objects, so call the callback
                 completion(model);
                 // and the TranslateAPICompletionDelegate
                 [viewDelegate completeWithTranslatedString:model.exampleTranslation success:YES];
             }];
            
            
        }
        else if (!object)
        {
            // No results were found on Parse, so let's create a new model
            
            TCPTranslationModel *model;
            model = [[super alloc] init];
            model.phrase = phrase;
            model.fromLanguage = fromLanguage;
            model.toLanguage = toLanguage;
            model.viewDelegate = viewDelegate;
            
            // get exampleTranslation from Bing
            __weak TCPTranslationModel *weakSelf = model;
            TCPTranslateAPI *translator = [TCPTranslateAPI sharedInstance];
            translator.completionDelegate = weakSelf;
            [translator translate:phrase
                     fromLanguage:fromLanguage
                       toLanguage:toLanguage];
            
            // save new model to Parse
            [model saveInBackground];
            completion(model);
        }
        else
        {
            // The network was inaccessible and we have no cached data for
            // this query.
            NSLog(@"TODO handle network errors");
        }
    }];
}


#pragma mark - private instance methods

- (void)completeWithTranslatedString:(NSString *)toText
                             success:(BOOL)success
{
    NSLog(@"got translation back from Bing / %@ /", toText);
    if (success) {
        self.exampleTranslation = toText;
        [self saveInBackground];
        
        [self.viewDelegate completeWithTranslatedString:toText success:success];
    }
}

- (void)loadLanguages
{
    self.fromLanguage = [TCPLanguageModel loadFromObjectId:self.fromLanguageObjectId];
    self.toLanguage = [TCPLanguageModel loadFromObjectId:self.toLanguageObjectId];
}




#pragma mark - private properties

- (void)setFromLanguage:(TCPLanguageModel *)newFromLanguage
{
    self.fromLanguageObjectId = newFromLanguage.objectId;
}

- (void)setToLanguage:(TCPLanguageModel *)newToLanguage
{
    self.toLanguageObjectId = newToLanguage.objectId;
}

@end
