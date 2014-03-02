//
//  TCPTranslateAPI.m
//  pronounce
//
//  Created by Jonathan Xu on 2/16/14.
//  Copyright (c) 2014 Team Canada. All rights reserved.
//

#import "TCPTranslateAPI.h"
#import "AFHTTPSessionManager.h"
#import "AFNetworking.h"

static NSString *const kMicrosoftTranslatorClientID = @"Randomguava_Pronounce";
static NSString *const kMicrosoftTranslatorClientSecret = @"IIoGQ0f8lt1AMMtcjwNGqEzubv1GnHFfq71JDMXhcLQ=";
static NSString *const kMicrosoftAccessURL = @"https://datamarket.accesscontrol.windows.net/v2/OAuth2-13";
static NSString *const kMicrosoftAccessFormattedBody = @"client_id=%@&client_secret=%@&grant_type=client_credentials&scope=http://api.microsofttranslator.com";
static NSString *const kMicrosoftTranslatorFormattedURL = @"http://api.microsofttranslator.com/v2/Http.svc/Translate?text=%@&from=%@&to=%@";

@interface TCPTranslateAPI () <NSXMLParserDelegate>
@property (strong, nonatomic) NSOperationQueue *operationQueue;
@property (strong, nonatomic) NSString *accessToken;
@property (strong, nonatomic) NSDate *accessTokenExpiresAt;

@property (nonatomic) BOOL captureCharacters;
@property (nonatomic) NSMutableString *capturedCharacters;
@end

@implementation TCPTranslateAPI

- (instancetype)init
{
    self = [super init];
    if (self) {
        _operationQueue = [[NSOperationQueue alloc] init];
        _operationQueue.maxConcurrentOperationCount = 1;
        _captureCharacters = NO;
    }
    return self;
}

+ (TCPTranslateAPI *)sharedInstance
{
    static dispatch_once_t once;
    static TCPTranslateAPI *instance;
    dispatch_once(&once, ^{
        instance = [[TCPTranslateAPI alloc] init];
    });
    return instance;
}

+ (NSString *)percentEscapeString:(NSString *)string
{
    return CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault,
                                                                     (CFStringRef)string,
                                                                     NULL,
                                                                     (CFStringRef)@":/?@!$&'()*+,;=",
                                                                     kCFStringEncodingUTF8));
}

// curl -X POST 'https://datamarket.accesscontrol.windows.net/v2/OAuth2-13' --header 'Content-Type: application/x-www-form-urlencoded' --data 'grant_type=client_credentials&client_id=Randomguava_Pronounce&client_secret=IIoGQ0f8lt1AMMtcjwNGqEzubv1GnHFfq71JDMXhcLQ%3D&scope=http://api.microsofttranslator.com'

- (void)fetchAccessTokenWithSuccess:(void (^)())success
                            failure:(void (^)())failure
{
    if ((self.accessToken) &&
        ([self.accessTokenExpiresAt compare:[NSDate date]] == NSOrderedDescending))
    {
        NSLog(@"TCPTranslateAPI:fetchAccessTokenWithSuccess: reuse cached access token");
        success();
        return;
    }
    
    NSString *requestBody = [NSString stringWithFormat:kMicrosoftAccessFormattedBody,
                             [TCPTranslateAPI percentEscapeString:kMicrosoftTranslatorClientID],
                             [TCPTranslateAPI percentEscapeString:kMicrosoftTranslatorClientSecret]];
    
    NSMutableURLRequest *request =[NSMutableURLRequest requestWithURL:[NSURL URLWithString:kMicrosoftAccessURL]
                                                          cachePolicy:NSURLRequestUseProtocolCachePolicy
                                                      timeoutInterval:60.0];
    [request setHTTPMethod:@"POST"];
    [request addValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPBody:[requestBody dataUsingEncoding:NSUTF8StringEncoding]];
    
    __weak TCPTranslateAPI *weakSelf = self;
    
    AFHTTPRequestOperation *op = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    op.responseSerializer = [AFJSONResponseSerializer serializer];
    [op setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"TCPTranslateAPI:fetchAccessTokenWithSuccess: success");
        NSDictionary *responseDict = (NSDictionary *)responseObject;
        weakSelf.accessToken = [responseDict objectForKey:@"access_token"];
        NSString *expiresInSecondsStr = [responseDict objectForKey:@"expires_in"];
        if (expiresInSecondsStr) {
            int expiresInSeconds = [expiresInSecondsStr intValue] - 2; // -2 just to be safe
            weakSelf.accessTokenExpiresAt = [[NSDate date] dateByAddingTimeInterval:expiresInSeconds];
        }
        success();
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"TCPTranslateAPI:fetchAccessTokenWithSuccess: failure");
        failure();
    }];
    
    [self.operationQueue addOperation:op];
}

// Http / XML:
// curl 'http://api.microsofttranslator.com/v2/Http.svc/Translate?text=hello&from=en&to=es' --header 'Content-Type: text/plain' --header 'Authorization: Bearer http%3a%2f%2fschemas.xmlsoap.org%2fws%2f2005%2f05%2fidentity%2fclaims%2fnameidentifier=Randomguava_Pronounce&http%3a%2f%2fschemas.microsoft.com%2faccesscontrolservice%2f2010%2f07%2fclaims%2fidentityprovider=https%3a%2f%2fdatamarket.accesscontrol.windows.net%2f&Audience=http%3a%2f%2fapi.microsofttranslator.com&ExpiresOn=1393137295&Issuer=https%3a%2f%2fdatamarket.accesscontrol.windows.net%2f&HMACSHA256=1TsyoMT1rHVzNVniuZn67rBMuF76N7faX0t1VGEKoUk%3d'


- (void)translate:(NSString *)fromText
     fromLanguage:(TCPLanguageModel *)fromLanguage
       toLanguage:(TCPLanguageModel *)toLanguage
{
    // short circuit
    if (!fromText ||
        ([fromText length] == 0) ||
        [fromLanguage.ietfLongCode isEqualToString:toLanguage.ietfLongCode]) {
        [self translateComplete:fromText];
        return;
    }
    
    __weak TCPTranslateAPI *weakSelf = self;
    [self fetchAccessTokenWithSuccess:^{
        NSString *accessToken = [NSString stringWithFormat:@"Bearer %@", self.accessToken];
        NSString *urlString = [NSString stringWithFormat:kMicrosoftTranslatorFormattedURL,
                               [TCPTranslateAPI percentEscapeString:fromText],
                               fromLanguage.ietfShortCode,
                               toLanguage.ietfShortCode];
        NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:urlString]
                                                               cachePolicy:NSURLRequestUseProtocolCachePolicy
                                                           timeoutInterval: 60.0];
        [request addValue:accessToken forHTTPHeaderField:@"Authorization"];
        
        AFHTTPRequestOperation *op = [[AFHTTPRequestOperation alloc] initWithRequest:request];
        op.responseSerializer = [AFXMLParserResponseSerializer serializer];
        [op setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
            NSLog(@"TCPTranslateAPI:translate: success");
            NSXMLParser *parser = (NSXMLParser *)responseObject;
            parser.delegate = weakSelf;
            [parser parse];
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            NSLog(@"TCPTranslateAPI:translate: failure");
            [weakSelf.completionDelegate completeWithTranslatedString:nil success:NO];
        }];

        [weakSelf.operationQueue addOperation:op];
    } failure:^{
        [weakSelf.completionDelegate completeWithTranslatedString:nil success:NO];
    }];
}

- (void)translateComplete:(NSString *)translatedText
{
    // set self.completionDelegate to nil before sending a YES message
    // so later on NO message will be sent to nil
    __weak id <TCPTranslateAPICompletionDelegate> delegate = self.completionDelegate;
    self.completionDelegate = nil;
    [delegate completeWithTranslatedString:translatedText
                                   success:YES];
}

// NSXMLParserDelegate

- (void)parser:(NSXMLParser *)parser
didStartElement:(NSString *)elementName
  namespaceURI:(NSString *)namespaceURI
 qualifiedName:(NSString *)qualifiedName
    attributes:(NSDictionary *)attributeDict
{
    if ([elementName isEqual:@"string"]) {
        self.captureCharacters = YES;
        self.capturedCharacters = [[NSMutableString alloc] initWithCapacity:500];
    }
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string
{
    if (self.captureCharacters) {
        [self.capturedCharacters appendString:string];
    }
}

- (void)parser:(NSXMLParser *)parser
 didEndElement:(NSString *)elementName
  namespaceURI:(NSString *)namespaceURI
 qualifiedName:(NSString *)qName
{
    if (self.captureCharacters) {
        self.captureCharacters = NO;
        [self translateComplete:[self.capturedCharacters copy]];
    }
}

- (void)parserDidEndDocument:(NSXMLParser *)parser
{
    // if parser rans into end of document, and self.completionDelegate is not nil,
    // send a NO message.
    [self.completionDelegate completeWithTranslatedString:nil success:NO];
}

@end
