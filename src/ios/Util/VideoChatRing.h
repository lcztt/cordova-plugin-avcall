//
//  VideoChatRing.h
//  Solution
//
//  Created by 仇啟飞 on 2018/9/21.
//  Copyright © 2018年 Solution. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface VideoChatRing : NSObject

@property (nonatomic, assign) BOOL isPlayRing;

+ (VideoChatRing *)shareManager;

- (void)playRingWithRepeat:(BOOL)isRepeat;
- (void)stopRingCall;

@end

NS_ASSUME_NONNULL_END
