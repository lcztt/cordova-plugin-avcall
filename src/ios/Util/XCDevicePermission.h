//
//  XCDevicePermission.h
//  TridentKit
//
//  Created by vitas on 2018/9/7.
//  Copyright © 2018 Trident. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Photos/Photos.h>
#import <AVFoundation/AVFoundation.h>
#import <AddressBook/AddressBook.h>

@interface XCDevicePermission : NSObject

// 获取通知权限
+ (void)checkNotificationPermission:(void(^)(BOOL granted))hander;

// 获取录音权限状态
+ (AVAuthorizationStatus)getRecordPermissionss;
// 检查录音权限
+ (void)checkMicrophonePermission:(void (^)(BOOL granted))complectionBlock;
// 检查录音权限,若未申请语音权限时，会根据wait字段判断是否需要等待申请权限结果
+ (void)checkMicrophonePermissionWaitForRequestResult:(BOOL)wait complection:(void (^)(BOOL granted))complectionBlock;

// 获取摄像头权限状态
+ (AVAuthorizationStatus)getCameraPermissionss;
// 检查摄像头权限
+ (void)checkCameraPermission:(void (^)(BOOL granted))complectionBlock;

// 获取相册权限状态
+ (PHAuthorizationStatus)getPhotoLibraryPermissionss;
// 检查相册权限
+ (void)checkPhotoAlbumPermission:(void (^)(BOOL granted))complectionBlock;

@end
