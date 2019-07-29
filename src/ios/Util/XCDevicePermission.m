//
//  XCDevicePermission.m
//  TridentKit
//
//  Created by vitas on 2018/9/7.
//  Copyright © 2018 Trident. All rights reserved.
//

#import "XCDevicePermission.h"
#ifdef NSFoundationVersionNumber_iOS_9_x_Max
#import <UserNotifications/UserNotifications.h>
#endif
#import "UIAlertController+Additions.h"


@implementation XCDevicePermission

+ (void)checkNotificationPermission:(void(^)(BOOL granted))hander
{
    [[UNUserNotificationCenter currentNotificationCenter] getNotificationSettingsWithCompletionHandler:^(UNNotificationSettings * _Nonnull settings) {
        dispatch_async(dispatch_get_main_queue(), ^{
            
            if (hander) {
                switch (settings.authorizationStatus) {
                    case UNAuthorizationStatusNotDetermined:
                        hander(NO);
                        break;
                    case UNAuthorizationStatusDenied:
                        hander(NO);
                        break;
                    case UNAuthorizationStatusAuthorized:
                        hander(YES);
                        break;
                    default:
                        break;
                }
            }
        });
    }];
}

// 获取录音权限状态
+ (AVAuthorizationStatus)getRecordPermissionss;
{
    AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeAudio];
    
    return authStatus;
}

// 检查录音权限
+ (void)checkMicrophonePermission:(void (^)(BOOL granted))permissionBlock
{
    [self checkMicrophonePermissionWaitForRequestResult:YES complection:permissionBlock];
}

// 聊天发送语音时权限检查
+ (void)checkMicrophonePermissionWaitForRequestResult:(BOOL)wait complection:(void (^)(BOOL))complectionBlock
{
    AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeAudio];
    
    if (authStatus == AVAuthorizationStatusAuthorized) {
        
        if (complectionBlock) {
            complectionBlock(YES);
        }
        
    } else if (authStatus == AVAuthorizationStatusRestricted ||
               authStatus == AVAuthorizationStatusDenied) {
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            [self showRecordAccessFailAlert];
            
            if (complectionBlock) {
                complectionBlock(NO);
            }
        });
        
    } else if (authStatus == AVAuthorizationStatusNotDetermined) {
        
        if (!wait) {
            if (complectionBlock) {
                complectionBlock(NO);
            }
        }
        
        [AVCaptureDevice requestAccessForMediaType:AVMediaTypeAudio completionHandler:^(BOOL granted) {
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
                if (!granted) {
                    [self showRecordAccessFailAlert];
                }
                
                if (wait) {
                    if (complectionBlock) {
                        complectionBlock(granted);
                    }
                }
            });
        }];
    }
}

// 获取摄像头权限
+ (AVAuthorizationStatus)getCameraPermissionss
{
    AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    
    return authStatus;
}

// 检查摄像头权限
+ (void)checkCameraPermission:(void (^)(BOOL granted))permissionBlock
{
    AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    
    switch (authStatus) {
        case AVAuthorizationStatusRestricted:
        case AVAuthorizationStatusDenied:
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                
                [self showCameraAccessFailAlert];
                
                if (permissionBlock) {
                    permissionBlock(NO);
                }
            });
        }
            break;
        
        case AVAuthorizationStatusAuthorized:
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (permissionBlock) {
                    permissionBlock(YES);
                }
            });
        }
            break;
            
        case AVAuthorizationStatusNotDetermined:
        {
            [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    
                    if (permissionBlock) {
                        permissionBlock(granted);
                    }
                    
                    if (!granted) {
                        [self showCameraAccessFailAlert];
                    }
                });
            }];
        }
            break;

        default:
            break;
    }
}

// 获取相册权限状态
+ (PHAuthorizationStatus)getPhotoLibraryPermissionss
{
    return [PHPhotoLibrary authorizationStatus];
}

// 检查相册权限
+ (void)checkPhotoAlbumPermission:(void (^)(BOOL granted))permissionBlock
{
    PHAuthorizationStatus authStatus = [PHPhotoLibrary authorizationStatus];
    
    if (authStatus == PHAuthorizationStatusAuthorized) {
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (permissionBlock) {
                permissionBlock(YES);
            }
        });
        
    } else if (authStatus == PHAuthorizationStatusDenied ||
               authStatus == PHAuthorizationStatusRestricted) {
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            [self showPhotoAlbumAccessFailAlert];
            
            if (permissionBlock) {
                permissionBlock(NO);
            }
        });
        
    } else if (authStatus == PHAuthorizationStatusNotDetermined) {
        
        [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
                if (status == PHAuthorizationStatusAuthorized) {
                    
                    if (permissionBlock) {
                        permissionBlock(YES);
                    }
                } else {
                    
                    [self showPhotoAlbumAccessFailAlert];
                    
                    if (permissionBlock) {
                        permissionBlock(NO);
                    }
                }
            });
        }];
    }
}

#pragma makr -


+ (void)showRecordAccessFailAlert
{
    NSString *title = @"麦克风访问失败";
    NSString *message = @"请在“设置-隐私-麦克风”中开启对APP的使用权限";
    [self showAlertWithTitle:title message:message];
}

+ (void)showCameraAccessFailAlert
{
    NSString *title = @"相机访问失败";
    NSString *message = @"请在“设置-隐私-相机”中开启对APP的使用权限";
    [self showAlertWithTitle:title message:message];
}

+ (void)showPhotoAlbumAccessFailAlert
{
    NSString *title = @"相册访问失败";
    NSString *message = @"请在“设置-隐私-相册”中开启对APP的使用权限";
    [self showAlertWithTitle:title message:message];
}

+ (void)showAlertWithTitle:(NSString *)title message:(NSString *)message
{
    UIAlertController *alert = [UIAlertController alertWithTitle:title message:message cancelButtonTitle:@"确定"];
    [alert addButtonWithTitle:@"去设置" handler:^(UIAlertAction * _Nonnull action) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString] options:@{} completionHandler:nil];
    }];
    [alert show];
}


@end
