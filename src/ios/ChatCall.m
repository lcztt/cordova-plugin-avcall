#import <Cordova/CDV.h>
#import "AVCallManager.h"
#import "AVCallRingTool.h"
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
        
        [XCDevicePermission checkCameraPermission:^(BOOL granted) {
            
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

- (void)playAudio:(CDVInvokedUrlCommand *)command
{
    [[AVCallRingTool shareManager] playRingWithRepeat:NO];
}

- (void)stopAudio:(CDVInvokedUrlCommand *)command
{
    [[AVCallRingTool shareManager] stopRingCall];
}

- (void)startCall:(CDVInvokedUrlCommand *)command
{
    [AVCallManager shareInstance].commandDelegate = self.commandDelegate;
    [[AVCallManager shareInstance] startAVCallWith:command];
}

- (void)stopCall:(CDVInvokedUrlCommand *)command
{
    [AVCallManager shareInstance].commandDelegate = self.commandDelegate;
    [[AVCallManager shareInstance] stopAVCallWith:command];
    [AVCallManager releaseInstance];
}

- (void)switchCamera:(CDVInvokedUrlCommand *)command
{
    [AVCallManager shareInstance].commandDelegate = self.commandDelegate;
    [[AVCallManager shareInstance] switchCamera:command];
}

- (void)setterBeauty:(CDVInvokedUrlCommand *)command
{
    [AVCallManager shareInstance].commandDelegate = self.commandDelegate;
    [[AVCallManager shareInstance] setterBeauty:command];
}

- (void)goldNoTimer:(CDVInvokedUrlCommand *)command
{
    [AVCallManager shareInstance].commandDelegate = self.commandDelegate;
    [[AVCallManager shareInstance] goldNoTimer:command];
}

- (void)muteRemoteAudio:(CDVInvokedUrlCommand *)command
{
    [AVCallManager shareInstance].commandDelegate = self.commandDelegate;
    [[AVCallManager shareInstance] muteRemoteAudio:command];
}

@end
