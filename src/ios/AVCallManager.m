//
//  AVCallManager.m
//  Solution
//
//  Created by 仇啟飞 on 2018/9/4.
//  Copyright © 2018年 Solution. All rights reserved.
//

#import "AVCallManager.h"
#import <AVFoundation/AVFoundation.h>
#import <AgoraRtcEngineKit/AgoraRtcEngineKit.h>
#import "AVCallInfoModel.h"
#import "YYTimer.h"
#import "AVCallVideoBeautyOptions.h"
#import "AVCallVideoBeautySetterView.h"
#import "AVCallRingTool.h"
#import "XCDevicePermission.h"
#import "UIView+AVCall.h"
#import "MainViewController.h"


OS_UNUSED OS_ALWAYS_INLINE static  bool AVCallIsBangsScreen()
{
    if (@available(iOS 11.0, *)) {
        
        UIEdgeInsets safeAreaInsets = [UIApplication sharedApplication].keyWindow.safeAreaInsets;
        // iOS 12. 非齐刘海也会保留20的安全区域
        return safeAreaInsets.top > 20 && safeAreaInsets.bottom > 0;
    }
    return false;
}

#define XCScreenWidth ([[UIScreen mainScreen] bounds].size.width)
#define XCScreenHeight ([[UIScreen mainScreen] bounds].size.height)

#define kHomeIndicatorHeight (AVCallIsBangsScreen() ? 34 : 0)
#define kTabBarHeight   (AVCallIsBangsScreen() ? 83 : 49)

#define kStatusBarHeight (AVCallIsBangsScreen() ? 44 : 20)
#define kNavigationBarHeight (AVCallIsBangsScreen() ? 88 : 64)

#define kSmallVideoViewH (136)
#define kSmallVideoViewW (77)
#define kSmallVideoRect (CGRectMake(XCScreenWidth - kSmallVideoViewW - 15, kStatusBarHeight + 15, kSmallVideoViewW, kSmallVideoViewH))


@interface AVCallManager ()
<AgoraRtcEngineDelegate, AVCallVideoBeautySetterViewDelegate>
{
    struct {
        unsigned int hasJoinedChannel:1;
        unsigned int selfHasHangup:1;
//        unsigned int haveReceiveRemoteFirstDataPackage:1;
    } _flag;
}

@property (nonatomic, strong) CDVInvokedUrlCommand *command;

@property (nonatomic, strong) UIView *remoteVideoView;
@property (nonatomic, strong) UIView *localVideoView;

@property (nonatomic, strong) AgoraRtcEngineKit *agoraKit;
@property (nonatomic, strong) AVCallVideoBeautySetterView *beauthSetterView;
@property (nonatomic, strong) AVCallVideoBeautyOptions *beauthParams;

@property (nonatomic, strong) YYTimer *activeTimer;
@property (nonatomic, assign) NSUInteger totalChatTime;
@property (nonatomic, assign) NSInteger countDownDuration;

@property (nonatomic, strong) UIPanGestureRecognizer *panGesture;
@property (nonatomic, strong) UITapGestureRecognizer *switchGesture;

@property (nonatomic, strong) AVCallInfoModel *callInfo;

@property (nonatomic, weak) UIViewController *rootVC;
@property (nonatomic, weak) UIView *controlView;
@property (nonatomic, strong) UIColor *webViewBackColor;

@end

@implementation AVCallManager

static AVCallManager *_shareInstance = nil;
+ (instancetype)shareInstance
{
    if (!_shareInstance) {
        _shareInstance = [[AVCallManager alloc] init];
        _shareInstance.countDownDuration = -1;
    }
    return _shareInstance;
}

+ (void)releaseInstance
{
    _shareInstance = nil;
}

- (void)dealloc
{
    NSLog(@"dealloc %@", NSStringFromClass(self.class));
}

#pragma mark - callback

- (void)callbackJSWith:(AVCallStatusCode)code params:(NSDictionary *)params
{
    if (!params) {
        params = @{};
    }
    
    if (code == AVCallStatusCodeSDKError ||
        code == AVCallStatusCodeOffline ||
        code == AVCallStatusCodeLostConnection) {
        
        [UIApplication sharedApplication].idleTimerDisabled = NO;
    }
    
    NSMutableDictionary *dictM = [NSMutableDictionary dictionaryWithDictionary:params];
    [dictM setObject:@(self.callInfo.room_id) forKey:@"room_id"];
    
    NSString *paramStr = [self jsonStringEncodedWith:dictM];
    NSString *jsStr = [NSString stringWithFormat:@"window.ChatCall.onCallEvent(%@, %@)", @(code), paramStr];
    [self.commandDelegate evalJs:jsStr];
}

#pragma mark - public

- (void)startAVCallWith:(CDVInvokedUrlCommand *)command
{
    self.command = command;
    
    NSDictionary *dict = command.arguments[0];
    AVCallInfoModel *model = [[AVCallInfoModel alloc] init];
    self.callInfo = model;
    if (![dict isKindOfClass:[NSDictionary class]]) {
        NSDictionary *params = @{@"code":@(1), @"desc":@"参数不完整"};
        CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsDictionary:params];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
        return;
    }
    
    NSDictionary *call = dict[@"call"];
    NSDictionary *userInfo = dict[@"userInfo"];
    
    if (![call isKindOfClass:[NSDictionary class]] ||
        ![userInfo isKindOfClass:[NSDictionary class]]) {
        
        NSDictionary *params = @{@"code":@(1), @"desc":@"参数不完整"};
        CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsDictionary:params];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
        return;
    }
    model.app_id = call[@"app_id"];
    model.token = call[@"token"];
    model.room_id = [call[@"room_id"] integerValue];
    
    model.call_type = [call[@"call_type"] integerValue];
    
    model.start_uid = [userInfo[@"start_uid"] integerValue];
    model.receive_uid = [userInfo[@"receive_uid"] integerValue];
    model.self_uid = [userInfo[@"self_uid"] integerValue];
    
    NSInteger screen_interval = [call[@"screen_interval"] integerValue];
    if (screen_interval > 0) {
        model.screen_interval = screen_interval;
    }
    
    NSInteger heart_interval = [call[@"heart_interval"] integerValue];
    if (heart_interval > 0) {
        model.heart_interval = heart_interval;
    }
    
    // 检测参数
    if (model.app_id.length > 0 &&
        model.token.length > 0 &&
        model.room_id > 0 &&
        model.call_type > 0 &&
        model.start_uid > 0 &&
        model.receive_uid > 0 &&
        model.self_uid > 0) {
        // nothing
    } else {
        
        NSDictionary *params = @{@"code":@(1), @"desc":@"参数不完整"};
        CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsDictionary:params];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
        return;
    }
    
    // 检测音视频权限由JS做,这里只是再次确保权限正确
    [XCDevicePermission checkMicrophonePermission:^(BOOL granted) {
        if (granted) {
            if (self.callInfo.call_type == AVCallTypeVideo) {
                [XCDevicePermission checkCameraPermission:^(BOOL granted) {
                    if (granted) {
                        [self startCall];
                    }
                }];
            } else {
                [self startCall];
            }
        }
    }];
}

- (void)stopAVCallWith:(CDVInvokedUrlCommand *)command
{
    self.command = command;
    [self stopCall];
}

- (void)switchCamera:(CDVInvokedUrlCommand *)command
{
    if (self.callInfo.call_type == AVCallTypeVideo) {
        [self.agoraKit switchCamera];
    }
}

- (void)setterBeauty:(CDVInvokedUrlCommand *)command
{
    if (self.callInfo.call_type == AVCallTypeVideo) {
        
        if (command.arguments.count > 0) {
            NSDictionary *params = command.arguments[0];
            if ([params isKindOfClass:[NSDictionary class]]) {
                BOOL beauty = [params[@"beauty"] boolValue];
                [self.agoraKit setBeautyEffectOptions:beauty options:self.beauthParams.beautyOptions];
                return;
            }
        }
        
        [self openBeautySetterView];
    }
}

- (void)goldNoTimer:(CDVInvokedUrlCommand *)command
{
    if (command.arguments.count > 0) {
        NSDictionary *params = command.arguments[0];
        if ([params isKindOfClass:[NSDictionary class]]) {
            NSInteger duration = [params[@"duration"] integerValue];
            if (duration > 0) {
                self.countDownDuration = duration;
            }
        }
    }
}

- (void)muteRemoteAudio:(CDVInvokedUrlCommand *)command
{
    if (command.arguments.count > 0) {
        NSDictionary *params = command.arguments[0];
        if ([params isKindOfClass:[NSDictionary class]]) {
            [self.agoraKit muteAllRemoteAudioStreams:[params[@"mute"] boolValue]];
            
            NSDictionary *params = @{};
            CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:params];
            [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
            return;
        }
    }
    
    NSDictionary *params = @{@"code":@(1), @"desc":@"参数不完整"};
    CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsDictionary:params];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}
    
#pragma mark - private

- (void)startCall
{
    MainViewController *vc = (MainViewController *)[UIApplication sharedApplication].keyWindow.rootViewController;
    if (![vc isKindOfClass:[MainViewController class]]) {
        CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsDictionary:@{}];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:self.command.callbackId];
        return;
    }
    
    self.rootVC = vc;
    self.controlView = vc.webView;
    
    self.webViewBackColor = vc.webView.backgroundColor;
    vc.webView.backgroundColor = [UIColor clearColor];
    vc.webView.opaque = false;
    
    [self initAgoraRtc];
    [self setupLocalVideoView:self.localVideoView];
    self.localVideoView.alpha = 0;
    [self.rootVC.view insertSubview:self.localVideoView belowSubview:self.controlView];
    [UIView animateWithDuration:0.25 animations:^{
        self.localVideoView.alpha = 1;
    } completion:^(BOOL finished) {
        
    }];
    
    [self.agoraKit startPreview];
    
    [self joinChannel];
}

- (void)stopCall
{
    if (_flag.selfHasHangup) {
        return;
    }
    _flag.selfHasHangup = YES;
    
    [self stopActiveTimer];
    
    [self leaveChannel];
    
    [UIView animateWithDuration:0.25 animations:^{
        self.localVideoView.alpha = 0;
        self.remoteVideoView.alpha = 0;
    } completion:^(BOOL finished) {
        [self.localVideoView removeFromSuperview];
        [self.remoteVideoView removeFromSuperview];
    }];
    
    [UIApplication sharedApplication].idleTimerDisabled = NO;
    
    CDVPluginResult *result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:@{}];
    [self.commandDelegate sendPluginResult:result callbackId:self.command.callbackId];
}

#pragma mark - AgoraRtcEngineKit
- (void)initAgoraRtc
{
    if (!self.agoraKit) {
        self.agoraKit = [AgoraRtcEngineKit sharedEngineWithAppId:self.callInfo.app_id delegate:self];
        [self.agoraKit setChannelProfile:AgoraChannelProfileCommunication];
    }
    
    if (self.callInfo.call_type == AVCallTypeVideo) {
        
        // 在 Agora SDK 中，音频功能是默认打开的
        // 调用 enableVideo 方法主动开启视频模式
        [self.agoraKit enableVideo];
        
        AgoraVideoEncoderConfiguration *configuration = [[AgoraVideoEncoderConfiguration alloc] initWithSize:AgoraVideoDimension640x480 frameRate:AgoraVideoFrameRateFps24 bitrate:AgoraVideoBitrateStandard orientationMode:AgoraVideoOutputOrientationModeAdaptative];
        configuration.degradationPreference = AgoraDegradationMaintainQuality;
        [self.agoraKit setVideoEncoderConfiguration:configuration];
        
        // 管理员不需要设置美颜
        if (!self.callInfo.is_admin) {
            [self.agoraKit setBeautyEffectOptions:self.beauthParams.isBeautyOn
                                          options:self.beauthParams.beautyOptions];
        }
    } else if (self.callInfo.call_type == AVCallTypeAudio) {
        
        [self.agoraKit disableVideo];
    }
    
    [self.agoraKit setDefaultAudioRouteToSpeakerphone:YES];
    [self.agoraKit setAudioProfile:AgoraAudioProfileSpeechStandard scenario:AgoraAudioScenarioDefault];
    
    // 管理员关闭本地音视频
    if (self.callInfo.is_admin) {
        
        [self.agoraKit enableLocalAudio:NO];
        
        if (self.callInfo.call_type == AVCallTypeVideo) {
            [self.agoraKit enableLocalVideo:NO];
        }
    }
    
    // 设置语音采集音量
    [self.agoraKit adjustRecordingSignalVolume:400];
}

- (void)joinChannel
{
    [self.agoraKit joinChannelByToken:self.callInfo.token
                            channelId:[NSString stringWithFormat:@"%@", @(self.callInfo.room_id)]
                                 info:nil
                                  uid:self.callInfo.self_uid
                          joinSuccess:nil];
}

- (void)leaveChannel
{
    // 离开频道后不要重复离开 可能会引起crash
    if (_flag.hasJoinedChannel) {
        _flag.hasJoinedChannel = NO;
        
        if (self.callInfo.call_type == AVCallTypeVideo) {
            [self.agoraKit stopPreview];
        }
        [self.agoraKit leaveChannel:nil];
        [AgoraRtcEngineKit destroy];
    }
}

- (void)setupRemoteVideoView:(UIView *)view
{
    AgoraRtcVideoCanvas *remoteVideoCanvas = [[AgoraRtcVideoCanvas alloc] init];
    remoteVideoCanvas.uid = self.callInfo.remote_uid;
    remoteVideoCanvas.renderMode = AgoraVideoRenderModeHidden;
    remoteVideoCanvas.view = view;
    [self.agoraKit setupRemoteVideo:remoteVideoCanvas];
}

- (void)setupLocalVideoView:(UIView *)view
{
    AgoraRtcVideoCanvas *videoCanvas = [[AgoraRtcVideoCanvas alloc] init];
    videoCanvas.uid = self.callInfo.local_uid;
    videoCanvas.view = view;
    videoCanvas.renderMode = AgoraVideoRenderModeHidden;
    [self.agoraKit setupLocalVideo:videoCanvas];
}

#pragma mark - AgoraRtcEngineKit delegate

/**
 * 加入频道
 */
- (void)rtcEngine:(AgoraRtcEngineKit *)engine didJoinChannel:(NSString *)channel withUid:(NSUInteger)uid elapsed:(NSInteger) elapsed
{
    NSLog(@"RTC：加入房间 %@...", @(uid));
    
    _flag.hasJoinedChannel = YES;
    
    if (_flag.selfHasHangup) {
        return;
    }
    
    [UIApplication sharedApplication].idleTimerDisabled = YES;
    
    if (!self.callInfo.is_admin) {
        
        [self callbackJSWith:AVCallStatusCodeJoinChannel params:@{}];
        
        if (self.callInfo.is_self_start) {
            
            [self playRingWithFileName:@"voip_call" type:nil loop:YES];
        } else {
            
            [[AVCallRingTool shareManager] stopRingCall];
            [self startActiveTimer];
        }
    }
    
    NSDictionary *params = @{@"code":@(1), @"desc":@"加入房间"};
    CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:params];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:self.command.callbackId];
}

/**
 * 第一次收到数据
 */
- (void)rtcEngine:(AgoraRtcEngineKit *)engine firstRemoteVideoDecodedOfUid:(NSUInteger)uid size:(CGSize)size elapsed:(NSInteger)elapsed
{
    NSLog(@"RTC：收到对方视频数据...");
    
    if (self.callInfo.is_admin) {
        
        if (uid == self.callInfo.local_uid) {
            
            [self setupRemoteVideoView:self.localVideoView];
            self.localVideoView.frame = kSmallVideoRect;
            [self.rootVC.view insertSubview:self.localVideoView aboveSubview:self.controlView];
            self.localVideoView.alpha = 0;
            [UIView animateWithDuration:0.25 animations:^{
                self.localVideoView.alpha = 1;
            } completion:^(BOOL finished) {
                [self.localVideoView addGestureRecognizer:self.panGesture];
            }];
        } else if (uid == self.callInfo.remote_uid) {
            
            [self setupRemoteVideoView:self.remoteVideoView];
            [self.rootVC.view insertSubview:self.remoteVideoView belowSubview:self.controlView];
        }
        
        if (self.localVideoView.superview && self.remoteVideoView.superview) {
            [self.localVideoView addGestureRecognizer:self.switchGesture];
        }
    } else {
        
        if (uid == self.callInfo.remote_uid) {
            
            [self callbackJSWith:AVCallStatusCodeReceiveRemoteFirstFrame params:@{}];
            
            // 发起方收到接听方的第一帧画面
            if (self.callInfo.is_self_start) {
                
                // 关闭音效
                [self.agoraKit stopAllEffects];
                
                [self startActiveTimer];
            }
            
            // 设置对方画面
            [self setupRemoteVideoView:self.remoteVideoView];
            [self.rootVC.view insertSubview:self.remoteVideoView belowSubview:self.localVideoView];
            
            [UIView animateWithDuration:0.2 animations:^{
                
                self.localVideoView.frame = kSmallVideoRect;
            } completion:^(BOOL finished) {
                
                [self.localVideoView bringToFront];
                [self.localVideoView addGestureRecognizer:self.panGesture];
                [self.localVideoView addGestureRecognizer:self.switchGesture];
            }];
        }
    }
}

- (void)rtcEngine:(AgoraRtcEngineKit *)engine firstRemoteAudioFrameOfUid:(NSUInteger)uid elapsed:(NSInteger)elapsed
{
    NSLog(@"RTC：收到对方语音数据...");
    
    // 视频通话也会回调此方法,因此只能在语音通话中处理一下逻辑
    if (self.callInfo.call_type == AVCallTypeAudio) {
        
        if (self.callInfo.is_admin) {
            
        } else {
            
            if (uid == self.callInfo.remote_uid) {
                
                [self callbackJSWith:AVCallStatusCodeReceiveRemoteFirstFrame params:@{}];
                
                // 发起方收到接听方的第一帧语音
                if (self.callInfo.is_self_start) {
                    
                    // 关闭音效
                    [self.agoraKit stopAllEffects];
                    [self startActiveTimer];
                }
            }
        }
    }
}

- (void)rtcEngine:(AgoraRtcEngineKit *)engine didLeaveChannelWithStats:(AgoraChannelStats *)stats
{
    NSLog(@"RTC：离开房间...");
}

- (void)rtcEngine:(AgoraRtcEngineKit *)engine didOfflineOfUid:(NSUInteger)uid reason:(AgoraUserOfflineReason)reason
{
    NSLog(@"RTC：离开了频道 %@...", @(uid));
    
    if (self.callInfo.is_admin) {
        
        NSDictionary *params = @{@"reason":@(reason), @"uid":@(uid)};
        [self callbackJSWith:AVCallStatusCodeOffline params:params];
    } else {
        
        if (uid == self.callInfo.remote_uid) {
            
            NSDictionary *params = @{@"reason":@(reason), @"uid":@(uid)};
            if (reason == AgoraUserOfflineReasonQuit) {
                NSLog(@"原因：挂断");
            } else if (reason == AgoraUserOfflineReasonDropped) {
                NSLog(@"原因：掉线");
            }
            
            [self callbackJSWith:AVCallStatusCodeOffline params:params];
        }
    }
}

- (void)rtcEngineConnectionDidLost:(AgoraRtcEngineKit *)engine
{
    NSLog(@"RTC：网络连接丢失...");
    
    if (self.callInfo.is_admin) {
        
        [self callbackJSWith:AVCallStatusCodeLostConnection params:@{}];
    } else {
        
        [self callbackJSWith:AVCallStatusCodeLostConnection params:@{}];
    }
}

- (void)rtcEngine:(AgoraRtcEngineKit *)engine didOccurError:(AgoraErrorCode)errorCode
{
    NSLog(@"RTC：agora rtc error: ❌ %@...", @(errorCode));
    
    if (_flag.hasJoinedChannel) {
        
        if (self.callInfo.is_admin) {
            
            NSDictionary *params = @{@"errorCode":@(errorCode)};
            [self callbackJSWith:AVCallStatusCodeSDKError params:params];
        } else {
            
            NSDictionary *params = @{@"errorCode":@(errorCode)};
            [self callbackJSWith:AVCallStatusCodeSDKError params:params];
        }
    } else {
        
        NSDictionary *params = @{@"code":@(1), @"desc":@"加入房间失败"};
        CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:params];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:self.command.callbackId];
    }
}

- (void)rtcEngine:(AgoraRtcEngineKit *)engine didOccurWarning:(AgoraWarningCode)warningCode
{
    NSLog(@"RTC：agora rtc warning: ⚠️ %@...", @(warningCode));
}

#pragma mark - Timer

- (void)startActiveTimer
{
    if (self.activeTimer) {
        [self.activeTimer invalidate];
        self.activeTimer = nil;
    }
    self.activeTimer = [YYTimer timerWithTimeInterval:1 target:self selector:@selector(chatTimerHandler) repeats:YES];
    self.totalChatTime = 0;
}

- (void)stopActiveTimer
{
    if (self.activeTimer) {
        [self.activeTimer invalidate];
        self.activeTimer = nil;
    }
}

- (void)chatTimerHandler
{
    self.totalChatTime++;
    
    // 心跳
    BOOL needSendHeart = self.totalChatTime % self.callInfo.heart_interval == 0;
    if (needSendHeart) {
        [self sendHeart];
    }
    
    // 截屏
    if (self.callInfo.screen_interval > 0 && self.callInfo.call_type == AVCallTypeVideo) {
        BOOL needScreenshot = self.totalChatTime % self.callInfo.screen_interval == 0;
        if (needScreenshot) {
            [self processScreenshot];
        }
    }
    
    // 更新显示通话时间
    [self updateCallDuration];
    
    // 更新倒计时
    [self updateCountDown];
}

#pragma mark - Heart

- (void)sendHeart
{
    [self callbackJSWith:AVCallStatusCodeHeart params:@{}];
}

#pragma mark - Screenshot

- (void)processScreenshot
{
    dispatch_async(dispatch_get_main_queue(), ^{
        
        UIImage *image = [self snapshotImage:self.localVideoView];
        NSString *path = [self getImageTempPath:image];
        
        NSDictionary *params = @{@"img_path":path};
        [self callbackJSWith:AVCallStatusCodeScreenshot params:params];
    });
}

- (UIImage *)snapshotImage:(UIView *)view
{
    UIGraphicsBeginImageContext(view.frame.size);
    [view drawViewHierarchyInRect:view.bounds afterScreenUpdates:NO];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

- (NSString *)getImageTempPath:(UIImage *)image
{
    NSString *tempFolder = NSTemporaryDirectory();
    NSString *tempImageDirPath = [tempFolder stringByAppendingPathComponent:@"screenshot"];
    [self creatDirPath:tempImageDirPath];
    NSString *image_name = [NSString stringWithFormat:@"%@.jpg", @([[NSDate date] timeIntervalSince1970])];
    NSString *image_path = [tempImageDirPath stringByAppendingPathComponent:image_name];
    
    [UIImageJPEGRepresentation(image, 0.7) writeToFile:image_path atomically:YES];
    
    CGFloat length = [[NSData dataWithContentsOfFile:image_path] length];
    if (length >= 500000) {
        [UIImageJPEGRepresentation(image, 0.5) writeToFile:image_path atomically:YES];
    }
    
    return image_path;
}

- (void)creatDirPath:(NSString *)path
{
    NSFileManager *fm = [NSFileManager defaultManager];
    BOOL isDir;
    BOOL exit =[fm fileExistsAtPath:path isDirectory:&isDir];
    if (!exit || !isDir) {
        [fm createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:nil];
    }
}

#pragma mark - Duration

- (void)updateCallDuration
{
    NSDictionary *params = @{@"duration":@(self.totalChatTime)};
    [self callbackJSWith:AVCallStatusCodeDuration params:params];
}

#pragma mark - Count Down

- (void)updateCountDown
{
    if (self.countDownDuration >= 0) {
        NSDictionary *params = @{@"duration":@(self.countDownDuration)};
        [self callbackJSWith:AVCallStatusCodeCountDown params:params];
        self.countDownDuration--;
    }
}

#pragma mark - Beauty

- (void)openBeautySetterView
{
    [[UIApplication sharedApplication].keyWindow.rootViewController.view addSubview:self.beauthSetterView];
}

#pragma mark - AVCallBeauthSetterViewDelegate

- (void)videoChatBeauthSetterViewDidChange:(AVCallVideoBeautySetterView *)view
{
    [self.agoraKit setBeautyEffectOptions:self.beauthParams.isBeautyOn options:self.beauthParams.beautyOptions];
}

#pragma mark - gesture

- (void)panSmallVideoView:(UIPanGestureRecognizer *)panGesture
{
    if (panGesture.state != UIGestureRecognizerStateEnded &&
        panGesture.state != UIGestureRecognizerStateFailed) {
        
        CGPoint location = [panGesture locationInView:[UIApplication sharedApplication].windows[0]];
        
        CGRect frame = panGesture.view.frame;
        
        frame.origin.x = location.x - frame.size.width / 2;
        frame.origin.y = location.y - frame.size.height / 2;
        
        if (frame.origin.x < 0) {
            frame.origin.x = 2;
        }
        
        if (frame.origin.y < 20) {
            frame.origin.y = 20;
        }
        
        if (frame.origin.x + frame.size.width > [UIScreen mainScreen].bounds.size.width) {
            frame.origin.x = [UIScreen mainScreen].bounds.size.width - 2 - frame.size.width;
        }
        
        if (frame.origin.y + frame.size.height >  [UIScreen mainScreen].bounds.size.height) {
            frame.origin.y = [UIScreen mainScreen].bounds.size.height - 2 - frame.size.height;
        }
        
        panGesture.view.frame = frame;
        
    } else if (panGesture.state == UIGestureRecognizerStateEnded) {
        
        NSLog(@"拖动Window结束");
        CGRect frame = panGesture.view.frame;
        if ((frame.size.width / 2 + frame.origin.x) >= XCScreenWidth / 2) {
            frame.origin.x = XCScreenWidth - frame.size.width - 12;
        } else {
            frame.origin.x = 12;
        }
        
        [UIView animateWithDuration:0.2 animations:^{
            panGesture.view.frame = frame;
        } completion:^(BOOL finished) {
        }];
    }
}

- (void)switchVideoPreview:(UITapGestureRecognizer *)tapGesture
{
    // 本地视频窗口变大窗口
    if (CGSizeEqualToSize(kSmallVideoRect.size, self.localVideoView.frame.size)) {
        
        [self.localVideoView removeGestureRecognizer:self.panGesture];
        [self.localVideoView removeGestureRecognizer:self.switchGesture];
        
        [self.controlView bringToFront];
        [self.remoteVideoView bringToFront];
        
        CGRect smallFrame = self.localVideoView.frame;
        self.remoteVideoView.frame = smallFrame;
        self.localVideoView.frame = self.controlView.bounds;
        
        [self.remoteVideoView addGestureRecognizer:self.panGesture];
        [self.remoteVideoView addGestureRecognizer:self.switchGesture];
    } else {
        // 本地视频窗口变小窗口
        
        [self.remoteVideoView removeGestureRecognizer:self.panGesture];
        [self.remoteVideoView removeGestureRecognizer:self.switchGesture];
        
        [self.controlView bringToFront];
        [self.localVideoView bringToFront];
        
        CGRect smallFrame = self.remoteVideoView.frame;
        self.localVideoView.frame = smallFrame;
        self.remoteVideoView.frame = self.controlView.bounds;
        
        [self.localVideoView addGestureRecognizer:self.panGesture];
        [self.localVideoView addGestureRecognizer:self.switchGesture];
    }
}

#pragma mark - util

- (void)playRingWithFileName:(NSString *)fileName type:(NSString *)type loop:(BOOL)isLoop
{
    if (!type) {
        type = @"caf";
    }
    
    NSString *ringPath = [[NSBundle mainBundle] pathForResource:fileName ofType:type];
    [self.agoraKit stopAllEffects];
    if (ringPath) {
        int ret = [self.agoraKit playEffect:0
                                   filePath:ringPath
                                  loopCount:isLoop ? -1 : 0
                                      pitch:1
                                        pan:0
                                       gain:100
                                    publish:NO];
    }
}

- (NSString *)jsonStringEncodedWith:(NSDictionary *)params
{
    if ([NSJSONSerialization isValidJSONObject:params]) {
        NSError *error;
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:params options:0 error:&error];
        NSString *json = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        return json;
    }
    return @"";
}

#pragma mark - getter

- (UIView *)remoteVideoView
{
    if (!_remoteVideoView) {
        _remoteVideoView = [[UIView alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
        _remoteVideoView.backgroundColor = [UIColor clearColor];
    }
    return _remoteVideoView;
}

- (UIView *)localVideoView
{
    if (!_localVideoView) {
        _localVideoView = [[UIView alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
        _localVideoView.backgroundColor = [UIColor clearColor];
    }
    return _localVideoView;
}

- (UIPanGestureRecognizer *)panGesture
{
    if (!_panGesture) {
        _panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panSmallVideoView:)];
        _panGesture.maximumNumberOfTouches = 1;
        _panGesture.minimumNumberOfTouches = 1;
    }
    return _panGesture;
}

- (UITapGestureRecognizer *)switchGesture
{
    if (!_switchGesture) {
        _switchGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(switchVideoPreview:)];
        [_switchGesture requireGestureRecognizerToFail:self.panGesture];
    }
    return _switchGesture;
}

- (AVCallVideoBeautySetterView *)beauthSetterView
{
    if (!_beauthSetterView) {
        _beauthSetterView = [[AVCallVideoBeautySetterView alloc] init];
        _beauthSetterView.beauthParams = self.beauthParams;
        _beauthSetterView.delegate = self;
    }
    [_beauthSetterView reloadData];
    return _beauthSetterView;
}

- (AVCallVideoBeautyOptions *)beauthParams
{
    if (!_beauthParams) {
        _beauthParams = [AVCallVideoBeautyOptions defaultOptions];
    }
    return _beauthParams;
}

@end

