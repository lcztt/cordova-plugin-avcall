//
//  VideoChatInstance.h
//  Solution
//
//  Created by 仇啟飞 on 2018/9/4.
//  Copyright © 2018年 Solution. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Cordova/CDV.h>


@interface VideoChatInstance : NSObject

+ (instancetype)shareInstance;
+ (void)releaseInstance;

@property (nonatomic, weak) id <CDVCommandDelegate> commandDelegate;

- (void)startAVCallWith:(CDVInvokedUrlCommand *)command;
- (void)stopAVCallWith:(CDVInvokedUrlCommand *)command;

- (BOOL)isInRoom;
- (void)playRingAfterInRoom;

- (void)switchCamera:(CDVInvokedUrlCommand *)command;
- (void)setterBeauty:(CDVInvokedUrlCommand *)command;
- (void)goldNoTimer:(CDVInvokedUrlCommand *)command;
- (void)muteRemoteAudio:(CDVInvokedUrlCommand *)command;

@end
