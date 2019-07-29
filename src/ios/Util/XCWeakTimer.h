//
//  XCWeakTimer.h
//  XCKit
//
//  Created by vitas on 2018/4/8.
//  Copyright © 2018 trident. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^TimerHandler)(id userInfo);

@interface XCWeakTimer : NSObject

@property (nonatomic, weak, readonly) NSTimer *timer;

+ (NSTimer *)scheduledTimerWithTimeInterval:(NSTimeInterval)interval
                                     target:(id)aTarget
                                   selector:(SEL)aSelector
                                   userInfo:(id)userInfo
                                    repeats:(BOOL)repeats;

+ (NSTimer *)scheduledTimerWithTimeInterval:(NSTimeInterval)interval
                                      block:(TimerHandler)block
                                   userInfo:(id)userInfo
                                    repeats:(BOOL)repeats;

@end
