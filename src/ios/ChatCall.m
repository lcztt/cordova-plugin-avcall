#import <Cordova/CDV.h>
#import "AVCallManager.h"
#import "AVCallRingTool.h"
#import "XCDevicePermission.h"


@interface ChatCall : CDVPlugin

@end

@implementation ChatCall

- (void)checkAuth:(CDVInvokedUrlCommand *)command
{
    NSDictionary *dict = command.arguments[0];
    NSInteger type = [dict[@"type"] integerValue];
    
    // 检查视频权限
    if (type == 1) {
        
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
}

- (void)switchCamera:(CDVInvokedUrlCommand *)command
{
    [AVCallManager shareInstance].commandDelegate = self.commandDelegate;
    [[AVCallManager shareInstance] switchCamera:command];
}

- (void)setterBeauty:(CDVInvokedUrlCommand *)command
{
    [AVCallManager shareInstance].commandDelegate = self.commandDelegate;
    [[AVCallManager shareInstance] switchCamera:command];
}

@end
