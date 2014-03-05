//
//  TCPModelUpdatedDelegate.h
//  pronounce
//
//  Created by Adam Tait on 3/4/14.
//  Copyright (c) 2014 Team Canada. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol TCPModelUpdatedDelegate <NSObject>

    - (void)modelDidFinishLoadingWithSuccess:(BOOL)success;

@end
