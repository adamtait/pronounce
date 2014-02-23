## pronounce

##### (real name yet to be decided)

Team Canada's attempt at helping the world speak better


### Overview

#### User Value Proposition

+ I want to learn a new language, but I'm finding it hard to pronounce words & phrases. Let me lookup a good example pronunciation from someone who knows the language better.
+ I want to speak to someone in a language that I'm not fluent in. How do I ask them a specific question?
+ I am fluent in a language and I want to help others learn it. I'm not afraid to have my voice recorded and shared with others.
+ I am proficient in a language but still learning it. I am happy to help others by suggesting a correct pronunciation.
+ I already know a language, but I'm speaking with someone who speaks a different dialect. How do I pronounce my words so that they can understand?

#### User Stories

+ search for a word (or phrase) to translate from one language to another (restricted set of languages)
+ add a pronunciation clip for a word (or phrase)
+ add a text comment or reply pronunciation clip to an existing word (or phrase)
+ save a translated word (or phrase) for quick review
+ review active pronunciation clips, related to languages that I know or want to learn
+ change my user settings

#### UI Layout


4 tabs: Translate, Feeds, Favorite, Me / Settings



#### Architecture Decision Records (ADRs)

[haven't heard of ADRs before?](http://thinkrelevance.com/blog/2011/11/15/documenting-architecture-decisions)


##### the feed

+ primary filter will be specified languages, regardless of proficiency
+ feed items should be reverse ordered by timestamp
+ (future) location information can be used as a filter
+ api should include a :limit argument


##### translation suggestions

+ should try to suggest the exact match of fromLanguage, toLanguage & fromLanguageText
+ if it can't find that match, then try other combinations of toLanguage & toLanguageText


### Tech 

#### Parse

#### UITabBarController

#### Microsoft Translator API

[Microsoft Translator API](http://www.microsoft.com/en-us/translator/developers.aspx) is an API available from Windows Azure Marketplace. This API is available for free for usage up to 2 million characters per month. It is the primary reason for which we chose this over Google Translate.

This API also has capabilities to
- Language detection
- Text to speech

These two capabilities are not currently utilized in this application. Though they are very interesting. Language detection can be used to simplify UI and user flow, where user could simplify paste or type text in, and this app will figure out the language. For text to speech we are using Apple's `AVSpeechSynthesizer`; however Microsoft Translator API's audios seem more natural, and less "machine like".

We perform a two step translation process
- call Windows Azure OAuth access control to obtain an access token, which is valid for 10 minutes. The access token is cached locally so subsequent calls do not need to obtain access token for every call.
- call `Translate` API to translate from one language to another.

#### delegate 

Delegates are used in this project for

- `TCPTranslateAPICompletionDelegate`, an async callback when a translation is obtained by calling Microsoft Translator API
- `TCPSelectLanguageDelegate`, used by `TCPSelectLanaguageViewController` to callback the presenting view controller, and let it know a language has been selected

#### AFNetworking, AFHTTPSessionManager, AFHTTPRequestOperation, NSOperationQueue

We use `AFNetworking`, `AFHTTPSessionManager`, `AFHTTPRequestOperation`, and `NSOperationQueue` for networking calls, for example, to Microsoft Translator API.

#### AFXMLParserResponseSerializer, NSXMLParser and NSXMLParserDelegate

Microsoft Translator API's `Translate` call returns XML document.  We use `AFXMLParserResponseSerializer`, `NSXMLParser`, and `NSXMLParserDelegate` to extract translated string from HTTP response body.

#### AVFoundation, AVSpeechSynthesizer

