//
//  VideoChatRing.m
//  Solution
//
//  Created by 仇啟飞 on 2018/9/21.
//  Copyright © 2018年 Solution. All rights reserved.
//

#import "VideoChatRing.h"
#import <AVFoundation/AVFoundation.h>


@interface VideoChatRing () <AVAudioPlayerDelegate>

@property (nonatomic, strong) AVAudioPlayer              *player;

@end

@implementation VideoChatRing

static VideoChatRing *_ringCallManager = nil;

+ (VideoChatRing *)shareManager {
    
    if (!_ringCallManager) {
        _ringCallManager = [[VideoChatRing alloc] init];
    }
    return _ringCallManager;
}

// 加载音效
- (SystemSoundID)loadSound:(NSString *)soundFileName {
    
    NSString *path = [[NSBundle mainBundle]pathForResource:soundFileName ofType:nil];
    NSURL *url = [NSURL fileURLWithPath:path];
    SystemSoundID soundId;
    // url先写个错的，然后让xcode帮我们智能修订，这里的方法不要硬记！
    AudioServicesCreateSystemSoundID((__bridge CFURLRef)(url), &soundId);
    
    return soundId;
}

// 初始化音乐播放器
- (void)playRingWithRepeat:(BOOL)isRepeat {
    
    NSString *path = [[NSBundle mainBundle] pathForResource:@"voip_call" ofType:@"caf"];
    NSURL *url = [NSURL fileURLWithPath:path];
    _player = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:nil];
    [_player setNumberOfLoops:isRepeat ? -1 : 1];
    _player.delegate = self;
    [_player prepareToPlay];
    [_player play];
    _isPlayRing = YES;
}

- (void)stopRingCall {
    _isPlayRing = NO;
    [_player stop];
    _player = nil;
}

- (void)beginReceivingRemoteControlEvents
{
    if ([[AVAudioSession sharedInstance] isOtherAudioPlaying]) {
        [[AVAudioSession sharedInstance] setActive:YES error:nil];
    }
    [[UIApplication sharedApplication] beginReceivingRemoteControlEvents];
}

- (void)endReceivingRemoteControlEvents
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [[UIApplication sharedApplication] endReceivingRemoteControlEvents];
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategorySoloAmbient error:nil];
    [[AVAudioSession sharedInstance] setActive:NO withOptions:AVAudioSessionSetActiveOptionNotifyOthersOnDeactivation error:nil];
}


- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag {
    
    [self stopRingCall];
    [self endReceivingRemoteControlEvents];
}

@end
