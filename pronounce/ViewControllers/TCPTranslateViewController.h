//
//  TCPTranslateViewController.h
//  pronounce
//
//  Created by Jonathan Xu on 2/8/14.
//  Copyright (c) 2014 Team Canada. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import "TCPSelectLanguageDelegate.h"

@interface TCPTranslateViewController : UIViewController <TCPSelectLanguageDelegate, AVAudioRecorderDelegate, AVAudioPlayerDelegate>

@end
