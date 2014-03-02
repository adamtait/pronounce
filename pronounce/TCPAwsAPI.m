//
//  TCPAwsAPI.m
//  pronounce
//
//  Created by Adam Tait on 2/25/14.
//  Copyright (c) 2014 Team Canada. All rights reserved.
//

NSString *const AWS_SDK_Access_Key = @"AKIAIOLK4RIGEIVRUVEA";
NSString *const AWS_SDK_Secret_Access_Key = @"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";


#import "TCPAwsAPI.h"
#import <AWSiOSSDK/AmazonWebServiceClient.h>
#import <AWSiOSSDK/S3/AmazonS3Client.h>

@implementation TCPAwsAPI

+ (void)upload:(NSData*)dataToUpload inBucket:(NSString*)bucket forKey:(NSString*)key
{
    @try {
        AmazonS3Client *s3 = [[AmazonS3Client alloc] initWithAccessKey:AWS_SDK_Access_Key withSecretKey:AWS_SDK_Secret_Access_Key];
        [s3 createBucket:[[S3CreateBucketRequest alloc] initWithName:bucket]];
        
        S3PutObjectRequest *putObjectRequest = [[S3PutObjectRequest alloc] initWithKey:key inBucket:bucket];
        
        putObjectRequest.contentType = @"audio/m4a";
        putObjectRequest.data = dataToUpload;
        dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0),
                       ^{
                           @try {
                               [s3 putObject:putObjectRequest];
                           }
                           @catch ( AmazonServiceException *exception ) {
                               NSLog( @"Failed attempting to upload file to Amazon S3. Reason: %@", exception  );
                           }
                       });
    }
    @catch ( AmazonServiceException *exception ) {
        NSLog( @"Upload Failed, Reason: %@", exception );
    }	
}

@end
