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

- Parse
- Microsoft Translator API
- AVFoundation, AVSpeechSynthesizer

Other

- UITabBarController
- delegate
- AFNetworking, AFHTTPSessionManager, AFHTTPRequestOperation
- NSOperationQueue
