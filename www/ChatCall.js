var exec = require('cordova/exec');

function ChatCall() {

}

// 检查客户端音视频权限，成功回调success，失败回调fail
// 参数：type:1 视频，2 音频
ChatCall.prototype.checkAuth = function (success, fail, params) {
    exec(success, fail, 'ChatCall', 'checkAuth', [params])
};

// 接听者在收到通话邀请后，接听或拒绝前，需要调用该方法播放铃声
// 点击接听后，startCall 方法内部会主动关闭铃声
// 点击拒绝后，需要调用 stopAudio 方法关闭铃声
// 注意，需要在通话页面退出的时候或退出登录的时候主动调用关闭铃声的方法。避免在离开通话界面时用户没机会点击拒绝关闭铃声
// 参数：无
ChatCall.prototype.playAudio = function (success, fail, params) {
    exec(success, fail, 'ChatCall', 'playAudio', [params])
};

// 接听者拒绝通话后，调用该方法关闭铃音
ChatCall.prototype.stopAudio = function (success, fail, params) {
    exec(success, fail, 'ChatCall', 'stopAudio', [params]);
};

// 唤起视频通话界面：
// 1. 发起者创建房间成功后，调用该方法进入房间，并显示本地画面，等待对方接受邀请
// 2. 接收者点击接听按钮后，调用该方法进入房间，并显示本地画面，等待对方画面到来
// 参数：
// app_id：声网 APPID
// token：进入房间的 token
// room_id：房间号

// call_type：通话类型，1 视频，2音频
// start_uid：通话发起者 UID
// receive_uid：通话接听者 UID
// self_uid：当前客户端登录用户 UID

// screen_interval（秒）：截屏时间间隔，值为0时客户端不截屏，该字段缺省时客户端默认60秒间隔
// heart_interval：心跳间隔，该字段缺省时客户端默认30秒间隔

// 注意：调用该方法前需要根据通话类型，调用 checkAuth 方法申请权限
ChatCall.prototype.startCall = function (success, fail, params) {
    exec(success, fail, 'ChatCall', 'startCall', [params]);
};

// 调用该方法关闭通话SDK
// 参数：无
ChatCall.prototype.stopCall = function (success, fail, params) {
    exec(success, fail, 'ChatCall', 'stopCall', [params]);
};

// 调用该方法切换前后摄像头，音频通话时，调用该方法无效
// 参数：无
ChatCall.prototype.switchCamera = function (success, fail, params) {
    exec(success, fail, 'ChatCall', 'switchCamera', [params]);
};

// 调用该方法设置美颜参数，音频通话时，调用该方法无效
// 参数：无
// android 参数 beauty 范围（0-1）
ChatCall.prototype.setterBeauty = function (success, fail, params) {
    exec(success, fail, 'ChatCall', 'setterBeauty', [params]);
};

// android 切换显示的view 参数无
ChatCall.prototype.switchView = function (success, fail, params) {
    exec(success, fail, 'ChatCall', 'switchView', [params])
};

// 金币不足，距离挂断的倒计时  参数 duration 倒计时时间 （例如60秒倒计时传60）
ChatCall.prototype.goldNoTimer = function (success, fail, params) {
    exec(success, fail, 'ChatCall', 'goldNoTimer', [params])
};

// 注册客户端状态变更回调方法
// 参数: eventID 参照 src/ios/AVCallDefines.h 文件定义的枚举：AVCallStatusCode
ChatCall.prototype.onCallEvent = function (eventID, params) {
    cordova.fireDocumentEvent('ChatCall.onCallEvent', {
        eventID: eventID,
        params: params
    })
};

if (!window.ChatCall) {
    window.ChatCall = new ChatCall();
}

module.exports = new ChatCall();
