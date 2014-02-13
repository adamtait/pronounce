## Data Models

+ User
+ Translation
+ CommentClip
+ Ratings
+ Location
+ Language


## User

+ (long) Facebook ID
+ (string) name
+ (FB-url) profileImage
+ (Dictionary {language* => int}) languagesByProficiencyLevel
+ (Array translation*) favorites
+ (Array location*) locations


## Translation

+ (string) from
+ (string) to
+ (language) toLanguage
+ (language) fromLanguage


## CommentClip

+ (translation *) translation
+ (long) timestamp
+ (string) comment
+ (S3-url) clip
+ (User *) user
+ (NSLocation) locationOfSubmission
+ (Array ratings*) ratings


## Ratings

+ (int) numberOfStars
+ (User *) user


## Location

+ (long) latitude
+ (long) longitude


## Language

+ (string)englishName
+ (string)nativeName
+ (string)ietfShortCode
+ (string)ietfLongCode
