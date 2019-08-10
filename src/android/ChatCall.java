package chat1v1.chatcall.ChatCall;

import android.annotation.SuppressLint;
import android.app.Activity;
import android.content.Context;
import android.content.Intent;
import android.content.pm.PackageManager;
import android.graphics.Bitmap;
import android.graphics.Color;
import android.util.Log;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.webkit.WebSettings;
import android.webkit.WebView;

import com.alibaba.fastjson.JSON;

import org.apache.cordova.CallbackContext;
import org.apache.cordova.CordovaInterface;
import org.apache.cordova.CordovaPlugin;
import org.apache.cordova.CordovaWebView;
import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;
import org.wysaid.view.CameraGLSurfaceView;
import org.wysaid.view.CustomizedCameraTexture;

import java.io.File;
import java.util.HashMap;
import java.util.Timer;
import java.util.TimerTask;

import javax.microedition.khronos.egl.EGLContext;

import chat1v1.chatcall.ChatCall.presenter.IVideoChatAtView;
import chat1v1.chatcall.ChatCall.presenter.VideoChatPresenter;
import chat1v1.chatcall.ChatCall.util.BackUtil;
import chat1v1.chatcall.ChatCall.util.PermissionUtil;
import chat1v1.chatcall.ChatCall.util.RingingUtil;
import io.agora.rtc.Constants;
import io.agora.rtc.IRtcEngineEventHandler;
import io.agora.rtc.video.AgoraVideoFrame;

/**
 * Created by ztl on 2018/1/17.
 */

public class ChatCall extends CordovaPlugin implements IVideoChatAtView {
    private static final String TAG = "plugin_ChatCall";

    public static final String EFFECT_CONFIGS[] = {
            "",
            "@beautify bilateral 100 3.5 2 @beautify face 1 720 1080", //Beautify
            "@blur lerp 1", //can adjust blur mix
    };

    private static final int CALLING_TYPE_CALL = 1; // 拨打
    private static final int CALLING_TYPE_ANSWER = 2; // 接听
    private static final int CALLING_TYPE_ADMIN = 3; // 管理员进入

    private static final int CALL_JOIN_ROOM = 1; // 加入房间
    private static final int CALL_RECEIVE_FIST_REMOTE = 2; // 收到远程第一针
    private static final int CALL_OFF_LINE = 3; // 用户离开
    private static final int CALL_CONNECTION_LOST = 4; // 声网连接丢失
    private static final int CALL_SDK_ERROR = 5; // sdk 错误
    private static final int CALL_HEART = 6; // 心跳
    private static final int CALL_TAKE_SCREEN = 7; //  截屏
    private static final int CALL_DURATION = 8; // 通话时间变动
    private static final int CALL_GOLD_NO_TIMER = 9; // 金币不足，距离挂断的倒计时

    private Context mContext;
    private Activity activity;
    private CordovaInterface cordova;
    private CordovaWebView cordovaWebView;
    private ViewGroup rootView;
    private WebView webView;
    private WebSettings settings;
    private CallbackContext mCallbackContext;

    private VideoChatPresenter mPresenter;
    private VideoChatPreview view_video;
    private RingingUtil mRingingUtil;

    // 通话的参数
    private ChatEntity mChatEntity;
    private int mCallingType;
    private float mBeautyIntensity = 0.5f;

    private final IRtcEngineEventHandler mRtcEngineEventHandler = new IRtcEngineEventHandler() {

        @Override
        public void onJoinChannelSuccess(String channel, int uid, int elapsed) {
            mRemoteJoined = true;
            backEvent(CALL_JOIN_ROOM, new HashMap<>());
            Log.e(TAG, "onJoinChannelSuccess: 用户加入视频频道成功 +  ------- " + channel + "     uid = " + uid);
        }

        @Override
        public void onFirstRemoteAudioFrame(int uid, int elapsed) {
            if (mChatEntity.call.call_type == 2) {
                            Log.e(TAG, "onFirstRemoteAudioFrame: 收到第一帧远程 音频 流并解码成功时 uid = " + uid);
                            activity.runOnUiThread(new Runnable() {
                                @Override
                                public void run() {
                                    mPresenter.setupTime(mChatEntity.call.heart_interval);
                                    if (mRingingUtil != null) {
                                        mRingingUtil.stopRing();
                                    }
                                }
                            });
                            backEvent(CALL_RECEIVE_FIST_REMOTE, new HashMap<>());
                        }
        }

        @Override
        //远端视频接收解码回调
        public void onFirstRemoteVideoDecoded(int uid, int width, int height, int elapsed) {
            Log.e(TAG, "收到第一帧远程视频流并解码成功时 uid====" + uid);
            if (mCallingType == CALLING_TYPE_ADMIN) {
                activity.runOnUiThread(new Runnable() {
                    @Override
                    public void run() {
                        mPresenter.setupControllerRemoteVideo(uid);
                    }
                });
            } else {
                activity.runOnUiThread(new Runnable() {
                    @Override
                    public void run() {
                        mPresenter.setupTime(mChatEntity.call.heart_interval);
                        if (mRingingUtil != null) {
                            mRingingUtil.stopRing();
                        }
                        view_video.setVisibility(View.VISIBLE);
                        mPresenter.setupRemoteVideo(uid);
                        view_video.changePreview();
                    }
                });
                initTakeScreen();
            }
            backEvent(CALL_RECEIVE_FIST_REMOTE, new HashMap<>());
        }

        @Override
        //其他用户加入当前频道回调
        //该回调提示有新的用户加入了频道，并返回新加入用户的 ID。
        //如果加入之前，已经有其他用户在频道中了，新加入的用户也会收到这些已有用户加入频道的回调。
        public void onUserJoined(int uid, int elapsed) {
            Log.e(TAG, "onUserJoined: 其他用户加入当前频道回调 --------- " + uid);
        }

        @Override
        //其他用户离开当前频道回调
        //提示有用户离开了频道（或掉线）。SDK 判断用户离开频道（或掉线）的依据是超时: 在一定时间内（15 秒）
        //没有收到对方的任何数据包，判定为对方掉线。在网络较差的情况下，可能会有误报。建议可靠的掉线检测应该由信令来做。
        public void onUserOffline(final int uid, int reason) {
            if (uid == Integer.parseInt(mChatEntity.userInfo.start_uid) ||
                    uid == Integer.parseInt(mChatEntity.userInfo.receive_uid)) {
                Log.e(TAG, "onUserOffline: 其他用户离开当前频道回调 " + uid);
                HashMap<String, Object> params = new HashMap<>();
                params.put("reason", reason);
                params.put("uid", uid);
                backEvent(CALL_OFF_LINE, params);
            }
        }

        @Override
        public void onConnectionLost() {
            super.onConnectionLost();
            backEvent(CALL_CONNECTION_LOST, new HashMap<>());
        }

        @Override
        public void onWarning(int warn) {
            super.onWarning(warn);
        }

        @Override
        public void onError(int err) {
            super.onError(err);
            HashMap<String, Object> params = new HashMap<>();
            params.put("errorCode", err);
            backEvent(CALL_SDK_ERROR, params);
        }

        @Override
        public void onNetworkQuality(int uid, int txQuality, int rxQuality) {
            super.onNetworkQuality(uid, txQuality, rxQuality);
            Log.e(TAG, "onNetworkQuality: 网络状态(上行) " + txQuality + " （下行）" + rxQuality);
        }
    };

    @Override
    public void initialize(CordovaInterface cordova, CordovaWebView webView) {
        super.initialize(cordova, webView);
        Log.e(TAG, "initialize: cordova 插件 开始初始化 ......");
        this.cordovaWebView = webView;
        this.cordova = cordova;
        this.activity = cordova.getActivity();
        this.mContext = this.activity.getApplicationContext();
        this.rootView = (ViewGroup) activity.findViewById(android.R.id.content);
        this.webView = (WebView) rootView.getChildAt(0);
        if (mRingingUtil == null) {
            mRingingUtil = new RingingUtil(this.mContext);
        }
    }

    @Override
    public boolean execute(String action, JSONArray args, final CallbackContext callbackContext) throws JSONException {

        this.mCallbackContext = callbackContext;
        Log.e(TAG, "execute: ---------------- 插件执行 ----- " + action);

        switch (action) {
            case "checkAuth":
                JSONObject jsonObject = new JSONObject(args.getString(0));
                int permissionType = Integer.parseInt(jsonObject.optString("action_type"));
                return PermissionUtil.authPermission(permissionType, mCallbackContext, this);
            case "startCall":
                Log.e(TAG, "execute: ------- ======== " + args.getString(0));
                mChatEntity = JSON.parseObject(args.getString(0), ChatEntity.class);
                Log.e(TAG, "execute: --d-as-dsa-da-sd-asd-a-da " + mChatEntity.call.screen_interval);
                initActionType();
                if (mChatEntity.call.call_type == 1) {
                    initVideoView();
                    initVideoPresenter();
                    if (mCallingType == CALLING_TYPE_CALL) {
                        if (mRingingUtil == null) {
                            mRingingUtil = new RingingUtil(mContext);
                        }
                        mRingingUtil.onIncomingCallRinging();
                        setupLocalVideo(Integer.parseInt(mChatEntity.call.room_id), Integer.parseInt(mChatEntity.userInfo.start_uid));
                    } else if (mCallingType == CALLING_TYPE_ANSWER) {
                        setupLocalVideo(Integer.parseInt(mChatEntity.call.room_id), Integer.parseInt(mChatEntity.userInfo.receive_uid));
                    } else if (mCallingType == CALLING_TYPE_ADMIN) {
                        mPresenter.joinChannel(mChatEntity.call.token, mChatEntity.call.room_id + "", Integer.parseInt(mChatEntity.userInfo.self_uid));
                        mPresenter.getRtcEngine().setClientRole(Constants.CLIENT_ROLE_AUDIENCE);
                        mPresenter.getRtcEngine().muteLocalAudioStream(false);
                    }
                    mCallbackContext.success("创建房间成功");
                } else {
                    initVideoPresenter();
                    //mPresenter.onIncomingCallRinging();
                    if (mCallingType == CALLING_TYPE_CALL) {
                        if (mRingingUtil == null) {
                            mRingingUtil = new RingingUtil(mContext);
                        }
                        mRingingUtil.onIncomingCallRinging();
                        mPresenter.joinChannel(mChatEntity.call.token, mChatEntity.call.room_id + "", Integer.parseInt(mChatEntity.userInfo.start_uid));
                    } else if (mCallingType == CALLING_TYPE_ANSWER) {
                        mPresenter.joinChannel(mChatEntity.call.token, mChatEntity.call.room_id + "", Integer.parseInt(mChatEntity.userInfo.receive_uid));
                    } else if (mCallingType == CALLING_TYPE_ADMIN) {
                        mPresenter.joinChannel(mChatEntity.call.token, mChatEntity.call.room_id + "", Integer.parseInt(mChatEntity.userInfo.self_uid));
                        mPresenter.getRtcEngine().muteLocalAudioStream(false);
                    }
                }
                return true;
            case "stopCall": // 结束通话
                //JSONObject endCallObject = new JSONObject(args.getString(0));
                //String roomID = endCallObject.optString("room_id");
                finishCall();
                return true;
            case "goldNoTimer":
                JSONObject goldNoObject = new JSONObject(args.getString(0));
                int duration = Integer.parseInt(goldNoObject.optString("duration"));
                mPresenter.setGoldNoTime(duration);
                return true;
            case "setterBeauty":
                JSONObject beautyObject = new JSONObject(args.getString(0));
                float beauty = Float.parseFloat(beautyObject.optString("beauty"));
                if (beauty > 1 || beauty < 0) {
                    mCallbackContext.error("params is error");
                } else {
                    mBeautyIntensity = beauty;
                    mCallbackContext.success("handing success");
                }
                return true;
            case "switchCamera":
                if (mCustomizedCameraRenderer != null) {
                    mCustomizedCameraRenderer.switchCamera();
                }
                return true;
            case "switchView":
                activity.runOnUiThread(new Runnable() {
                    @Override
                    public void run() {
                        view_video.changePreview();
                    }
                });
                return true;
            case "playAudio":
                if (mRingingUtil != null) {
                    mRingingUtil.onIncomingCallRinging();
                    mCallbackContext.success();
                } else {
                    mCallbackContext.error("mRingingUtil is null");
                }
                return true;
            case "stopAudio":
                if (mRingingUtil != null) {
                    mRingingUtil.stopRing();
                    mCallbackContext.success();
                } else {
                    mCallbackContext.error("mRingingUtil is null");
                }
                return true;
        }
        return true;
    }

    private void initVideoPresenter() {
        if (mPresenter != null) return;
        mPresenter = new VideoChatPresenter(activity, mChatEntity.call.call_type
                , mChatEntity.call.app_id, mRtcEngineEventHandler);
        mPresenter.attachView(this);
    }

    private void initVideoView() {
        if (view_video != null) return;
        activity.runOnUiThread(new Runnable() {
            @Override
            public void run() {
                LayoutInflater layoutInflater = LayoutInflater.from(activity);
                view_video = (VideoChatPreview) layoutInflater.inflate(_R("layout", "layout_video_chat"), null);
                rootView.addView(view_video);
                view_video.setVisibility(View.VISIBLE);
                webView.setBackgroundColor(Color.TRANSPARENT);
                // 关闭 webView 的硬件加速（否则不能透明）
                webView.setLayerType(WebView.LAYER_TYPE_SOFTWARE, null);
                webView.bringToFront();
            }
        });
    }

    private void initActionType() {
        if (mChatEntity.userInfo.self_uid.equals(mChatEntity.userInfo.start_uid)) {
            mCallingType = CALLING_TYPE_CALL;
        } else if (mChatEntity.userInfo.self_uid.equals(mChatEntity.userInfo.receive_uid)) {
            mCallingType = CALLING_TYPE_ANSWER;
        } else {
            mCallingType = CALLING_TYPE_ADMIN;
        }
    }

    private CustomizedCameraTexture mCustomizedCameraRenderer;
    private volatile boolean mJoined = false;
    private volatile boolean mRemoteJoined = false;

    private CustomizedCameraTexture setupLocalVideo(final int channelID, final int uid) {

        CustomizedCameraTexture surfaceV = new CustomizedCameraTexture(mContext, null);
        surfaceV.presetCameraForward(false);
        surfaceV.setFitFullView(true);

        mCustomizedCameraRenderer = surfaceV;
        mCustomizedCameraRenderer.setOnFrameAvailableHandler(new org.wysaid.view.CustomizedCameraTexture.OnFrameAvailableListener() {
            @Override
            public void onFrameAvailable(int texture, EGLContext eglContext, int rotation, float[] transform) {
                //if (isOpenBlur) {
                //    mCustomizedCameraRenderer.setFilterWithConfig(EFFECT_CONFIGS[2]);
                //} else {
                mCustomizedCameraRenderer.setFilterWithConfig(EFFECT_CONFIGS[1]);
                mCustomizedCameraRenderer.setFilterIntensity(mBeautyIntensity);
                //}
                AgoraVideoFrame vf = new AgoraVideoFrame();
                vf.format = AgoraVideoFrame.FORMAT_TEXTURE_2D;
                vf.timeStamp = System.currentTimeMillis();
                vf.stride = 480;
                vf.height = (480 * 16 / 9);
                vf.textureID = texture;
                vf.syncMode = true;
                vf.eglContext11 = eglContext;
                vf.transform = transform;
                if (mCallingType == CALLING_TYPE_CALL) {
                    if (mRemoteJoined) {
                        boolean result = mPresenter.getRtcEngine().pushExternalVideoFrame(vf);
                    }
                } else {
                    boolean result = mPresenter.getRtcEngine().pushExternalVideoFrame(vf);
                }
            }
        });

        mCustomizedCameraRenderer.setOnEGLContextHandler(new org.wysaid.view.CustomizedCameraTexture.OnEGLContextListener() {
            @Override
            public void onEGLContextReady(EGLContext eglContext) {
                if (!mJoined) {
                    mPresenter.joinChannel(mChatEntity.call.token, mChatEntity.call.room_id + "", uid); // Tutorial Step 4
                    mJoined = true;
                }
            }
        });

        activity.runOnUiThread(new Runnable() {
            @Override
            public void run() {
                view_video.getFl_local().setVisibility(View.VISIBLE);
                view_video.getFl_local().addView(surfaceV, 0);
                surfaceV.setZOrderOnTop(false);
            }
        });
        return surfaceV;
    }

    private void finishCall() {
        if (mRingingUtil != null) {
            mRingingUtil.stopRing();
        }
        if (mChatEntity.call.call_type == 1) {
            mCustomizedCameraRenderer.queueEvent(new Runnable() {
                @Override
                public void run() {
                    if (mCustomizedCameraRenderer != null) {
                        mCustomizedCameraRenderer.onRelease();
                        //mCustomizedCameraRenderer.onDestroyView();
                        mCustomizedCameraRenderer = null;
                    }
                }
            });

            activity.runOnUiThread(new Runnable() {
                @Override
                public void run() {
                    mPresenter.setGoldNoTime(0);
                    mPresenter.finishVideoChat();
                    mPresenter.detachView();
                    mPresenter = null;
                    mJoined = false;
                    mRemoteJoined = false;
                    if (view_video == null) return;
                    rootView.removeView(view_video);
                    view_video = null;
                    webView.setBackgroundResource(0);
                    webView.setLayerType(View.LAYER_TYPE_HARDWARE, null);
                }
            });
        } else {
            activity.runOnUiThread(new Runnable() {
                @Override
                public void run() {
                    if (mPresenter != null) {
                        mPresenter.finishVideoChat();
                        mPresenter.detachView();
                        mPresenter = null;
                        mJoined = false;
                        mRemoteJoined = false;
                    }
                }
            });
        }
    }

    private Timer mTimer;
    private TimerTask mTimerTask;

    private void initTakeScreen() {
        if (mChatEntity == null) {
            Log.e(TAG, "initTakeScreen: mChatEntity is null ......");
            return;
        }
        if (mChatEntity.call.screen_interval != 0) {
            mTimer = new Timer();
            mTimerTask = new TimerTask() {
                @Override
                public void run() {
                    File desFile = new File(activity.getCacheDir() + "/" + "other" + ".takeVideo.jpg");
                    String path = desFile.getPath();
                    if (mCustomizedCameraRenderer != null) {
                        mCustomizedCameraRenderer.takeShot(new CameraGLSurfaceView.TakePictureCallback() {
                            @Override
                            public void takePictureOK(Bitmap bmp) {
                                if (bmp != null) {
                                    BackUtil.saveBitmap(bmp, path);
                                    bmp.recycle();

                                    HashMap<String, Object> params = new HashMap<>();
                                    params.put("img_path", path);
                                    backEvent(CALL_TAKE_SCREEN, params);
                                }
                            }
                        });
                    }
                }
            };

            new Thread(new Runnable() {
                @Override
                public void run() {
                    mTimer.schedule(mTimerTask, 3000, mChatEntity.call.screen_interval * 1000);
                }
            }).start();
        }
    }

    @Override
    public void onActivityResult(int requestCode, int resultCode, Intent intent) {
    }

    public void onRequestPermissionResult(int requestCode, String[] permissions, int[] grantResults) throws JSONException {
        if (grantResults.length <= 0) return;
        JSONObject jsonObject = new JSONObject();
        for (int r : grantResults) {
            if (r == PackageManager.PERMISSION_DENIED) {
                jsonObject.put("auth", 0);
                mCallbackContext.error(jsonObject);
                return;
            }
        }
        mCallbackContext.success(jsonObject);
    }

    private void backEvent(int eventID, JSONObject jsonObject) {
        @SuppressLint("DefaultLocale") final String jsStr =
                String.format("window.ChatCall.onCallEvent(%d, %s)", eventID, jsonObject.toString());
        activity.runOnUiThread(new Runnable() {
            @Override
            public void run() {
                cordovaWebView.loadUrl("javascript:" + jsStr);
            }
        });
    }

    private void backEvent(int eventID, HashMap<String, Object> params) {

        try {
            JSONObject jsonObject = new JSONObject();
            jsonObject.put("room_id", mChatEntity.call.room_id);
            if (params != null) {
                for (String key : params.keySet()) {
                    jsonObject.put(key, params.get(key));
                }
            }
            backEvent(eventID, jsonObject);
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    public int _R(String defType, String name) {
        return activity.getApplication().getResources().getIdentifier(
                name, defType, activity.getApplication().getPackageName());
    }

    @Override
    public VideoChatPreview getVideoChatPreview() {
        return view_video;
    }

    @Override
    public void onVideoCallDuration(long duration) {
        HashMap<String, Object> params = new HashMap<>();
        params.put("duration", duration);
        backEvent(CALL_DURATION, params);
    }

    @Override
    public void onVideoCallGoldNoTimer(int duration) {
        HashMap<String, Object> params = new HashMap<>();
        params.put("duration", duration);
        backEvent(CALL_GOLD_NO_TIMER, params);
    }

    @Override
    public void onVideoCallHeart() {
        backEvent(CALL_HEART, new HashMap<>());
    }
}
