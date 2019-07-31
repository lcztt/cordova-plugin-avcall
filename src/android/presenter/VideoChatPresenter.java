package chat1v1.chatcall.ChatCall.presenter;

import android.annotation.SuppressLint;
import android.content.Context;
import android.os.Handler;
import android.os.PowerManager;
import android.util.Log;

import io.agora.rtc.Constants;
import io.agora.rtc.IRtcEngineEventHandler;
import io.agora.rtc.RtcEngine;
import io.agora.rtc.video.VideoCanvas;

/**
 * Created by Genda on 2019-07-28.
 */
public class VideoChatPresenter extends BasePresenter<IVideoChatAtView> {

    private static final String TAG = "VideoChatPresenter";

    private RtcEngine mRtcEngine;
    private Handler mHandler;

    private long mTime;
    private long mMinTime = 0;
    private Runnable mUpdateTimeRunnable;

    public VideoChatPresenter(Context context) {
        super(context);
    }

    public VideoChatPresenter(Context context, int callType, String agoraID, IRtcEngineEventHandler iRtcEngineEventHandler) {
        super(context);

        try {
            mRtcEngine = RtcEngine.create(mContext, agoraID, iRtcEngineEventHandler);
            mRtcEngine.enableWebSdkInteroperability(true);
            if (callType == 1) {
                Log.e(TAG, "VideoChatPresenter: 初始化 视频 RTC engine ......");
                mRtcEngine.enableVideo();
                if (mRtcEngine.isTextureEncodeSupported()) {
                    mRtcEngine.setExternalVideoSource(true, true, true);
                } else {
                    throw new RuntimeException("Can not work on device do not supporting texture" + mRtcEngine.isTextureEncodeSupported());
                }
                mRtcEngine.setChannelProfile(Constants.CHANNEL_PROFILE_LIVE_BROADCASTING);
                mRtcEngine.setVideoProfile(Constants.VIDEO_PROFILE_720P, true);
            }
        } catch (Exception e) {
            Log.e(TAG, " agora VideoChatPresenter: init RtcEngine error " + e.getMessage());
            throw new RuntimeException("NEED TO check rtc sdk init fatal error\n" + Log.getStackTraceString(e));
        }

        PowerManager pm = (PowerManager) mContext.getSystemService(Context.POWER_SERVICE);
        boolean isScreenOn = pm.isScreenOn();
        if (!isScreenOn) {
            @SuppressLint("InvalidWakeLockTag") PowerManager.WakeLock wl = pm.newWakeLock(PowerManager.ACQUIRE_CAUSES_WAKEUP | PowerManager.SCREEN_DIM_WAKE_LOCK, "bright");
            wl.acquire();
            wl.release();
        }

        mHandler = new Handler();
    }

    /**
     * 加入频道
     */
    public void joinChannel(String channelKey, String channelName, int channelId) {
        if (mRtcEngine != null) {
            mRtcEngine.setClientRole(Constants.CLIENT_ROLE_BROADCASTER);
            Log.e(TAG, "joinChannel: name = " + channelName + "     channel_id = " + channelId);
            int joinChannel = mRtcEngine.joinChannel(channelKey, channelName, "Extra Data", channelId);
            Log.e(TAG, "joinChannel: 加入房间结果 ----- " + joinChannel);
        }
    }

    public void setupRemoteVideo(int userId) {
        mRtcEngine.setupRemoteVideo(new VideoCanvas(getView().getVideoChatPreview().getRemoteSurfaceView()
                , VideoCanvas.RENDER_MODE_HIDDEN, userId));
    }

    private int mControllerOtherId = 0;

    public void setupControllerRemoteVideo(int userId) {
        if (mControllerOtherId == 0) {
            mControllerOtherId = userId;
            mRtcEngine.setupRemoteVideo(new VideoCanvas(getView().getVideoChatPreview().getRemoteSurfaceView()
                    , VideoCanvas.RENDER_MODE_HIDDEN, mControllerOtherId));
        } else {
            mRtcEngine.setupRemoteVideo(new VideoCanvas(getView().getVideoChatPreview().getLocalSurfaceView()
                    , VideoCanvas.RENDER_MODE_HIDDEN, userId));
        }
    }

    public void setupTime(int heartTime) {
        if (mUpdateTimeRunnable != null) {
            mHandler.removeCallbacks(mUpdateTimeRunnable);
        }
        mUpdateTimeRunnable = new UpdateTimeRunnable(heartTime);
        mHandler.post(mUpdateTimeRunnable);
    }

    public void hansFree(boolean isOpen) {
        if (mRtcEngine != null) {
            mRtcEngine.setEnableSpeakerphone(isOpen);
        }
    }

    public void finishVideoChat() {
        int i = mRtcEngine.leaveChannel();
        Log.e(TAG, "finishVideoChat: 结束 通话  leaveChannel " + i + " －－－－－－－－－－－－ ");
        RtcEngine.destroy();
        mRtcEngine = null;
        mHandler.removeCallbacks(mUpdateTimeRunnable);
    }

    public RtcEngine getRtcEngine() {
        return mRtcEngine;
    }

    private class UpdateTimeRunnable implements Runnable {
        private int mHeartTime;

        public UpdateTimeRunnable(int heartTime) {
            mHeartTime = heartTime;
        }

        @Override
        public void run() {
            mTime++;
            mMinTime++;
            getView().onVideoCallDuration(mTime);
            if (mMinTime == mHeartTime) {
                mMinTime = 0;
                getView().onVideoCallHeart();
            }
            mHandler.postDelayed(this, 1000);
        }
    }
}
