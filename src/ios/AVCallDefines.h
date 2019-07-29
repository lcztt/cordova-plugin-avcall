//
//  AVCallDefines.h
//  avcall
//
//  Created by vitas on 2019/7/29.
//

#ifndef AVCallDefines_h
#define AVCallDefines_h

typedef NS_ENUM(NSInteger, AVCallType) {
    AVCallTypeVideo = 1,
    AVCallTypeAudio = 2,
};

typedef NS_ENUM(NSInteger, AVCallHangupBy) {
    AVCallHangupByStart = 1,
    AVCallHangupByReceiver = 2,
};

// params 基础参数：{"room_id":房间号}
typedef NS_ENUM(NSInteger, AVCallStatusCode) {
    AVCallStatusCodeNone,
    AVCallStatusCodeJoinChannel = 1, // 加入房间
    AVCallStatusCodeReceiveRemoteFirstFrame = 2, // 接收到对方数据
    AVCallStatusCodeOffline = 3, // 对方离开房间（主动退出或对方网络原因导致连接中断），params:{"reason":(退出原因：0，主动挂断 1，连接中断), "uid":(退出者uid)}
    AVCallStatusCodeLostConnection = 4, // 自己声网连接中断
    AVCallStatusCodeSDKError = 5, // 声网SDK错误回调，params:{"errorCode":(声网SDK提供的错误码)};
    AVCallStatusCodeHeart = 6, // 心跳回调
    AVCallStatusCodeScreenshot = 7, // 截图，params:{"img_path":图片地址}
    AVCallStatusCodeDuration = 8, // 通话时长，params:{"duration":通话总秒数}
};


#endif /* AVCallDefines_h */
