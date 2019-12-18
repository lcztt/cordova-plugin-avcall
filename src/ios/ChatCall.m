#import <Cordova/CDV.h>
#import "VideoChatInstance.h"
#import "VideoChatRing.h"
#import "XCDevicePermission.h"
#import "AVCallDefines.h"

@interface ChatCall : CDVPlugin

@end

@implementation ChatCall

- (void)checkAuth:(CDVInvokedUrlCommand *)command
{
    NSDictionary *dict = command.arguments[0];
    if (![dict isKindOfClass:[NSDictionary class]]) {
        NSDictionary *params = @{@"code":@(1), @"desc":@"参数不完整"};
        CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsDictionary:params];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
        return;
    }
    NSInteger type = [dict[@"type"] integerValue];
    
    // 检查视频权限
    if (type == AVCallTypeVideo) {
        
        [XCDevicePermission checkCameraPermission:^(BOOL granted) {
            
            if (granted) {
                
                CDVPluginResult *result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
                [self.commandDelegate sendPluginResult:result callbackId:command.callbackId];
            } else {
                
                CDVPluginResult *result = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR];
                [self.commandDelegate sendPluginResult:result callbackId:command.callbackId];
            }
        }];
    } else {
        
        [XCDevicePermission checkMicrophonePermission:^(BOOL granted) {
            
            if (granted) {
                
                CDVPluginResult *result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
                [self.commandDelegate sendPluginResult:result callbackId:command.callbackId];
            } else {
                
                CDVPluginResult *result = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR];
                [self.commandDelegate sendPluginResult:result callbackId:command.callbackId];
            }
        }];
    }
}

- (void)checkAudioAuth:(CDVInvokedUrlCommand *)command
{
    [XCDevicePermission checkMicrophonePermissionWaitForRequestResult:NO complection:^(BOOL granted) {
        
        if (granted) {
            
            CDVPluginResult *result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
            [self.commandDelegate sendPluginResult:result callbackId:command.callbackId];
        } else {
            
            CDVPluginResult *result = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR];
            [self.commandDelegate sendPluginResult:result callbackId:command.callbackId];
        }
    }];
}

- (void)playAudio:(CDVInvokedUrlCommand *)command
{
    [[VideoChatRing shareManager] playRingWithRepeat:NO];
}

- (void)stopAudio:(CDVInvokedUrlCommand *)command
{
    [[VideoChatRing shareManager] stopRingCall];
}

- (void)startCall:(CDVInvokedUrlCommand *)command
{
    [VideoChatInstance shareInstance].commandDelegate = self.commandDelegate;
    [[VideoChatInstance shareInstance] startAVCallWith:command];
}

- (void)stopCall:(CDVInvokedUrlCommand *)command
{
    [VideoChatInstance shareInstance].commandDelegate = self.commandDelegate;
    [[VideoChatInstance shareInstance] stopAVCallWith:command];
    [VideoChatInstance releaseInstance];
}

- (void)switchCamera:(CDVInvokedUrlCommand *)command
{
    [VideoChatInstance shareInstance].commandDelegate = self.commandDelegate;
    [[VideoChatInstance shareInstance] switchCamera:command];
}

- (void)setterBeauty:(CDVInvokedUrlCommand *)command
{
    [VideoChatInstance shareInstance].commandDelegate = self.commandDelegate;
    [[VideoChatInstance shareInstance] setterBeauty:command];
}

- (void)goldNoTimer:(CDVInvokedUrlCommand *)command
{
    [VideoChatInstance shareInstance].commandDelegate = self.commandDelegate;
    [[VideoChatInstance shareInstance] goldNoTimer:command];
}

- (void)muteRemoteAudio:(CDVInvokedUrlCommand *)command
{
    [VideoChatInstance shareInstance].commandDelegate = self.commandDelegate;
    [[VideoChatInstance shareInstance] muteRemoteAudio:command];
}

@end
