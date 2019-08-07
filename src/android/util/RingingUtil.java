package chat1v1.chatcall.ChatCall.util;

import android.annotation.SuppressLint;
import android.content.Context;
import android.media.AudioManager;
import android.media.MediaPlayer;
import android.media.RingtoneManager;
import android.net.Uri;
import android.os.Vibrator;

import java.io.IOException;

/**
 * Created by Genda on 2019-07-30.
 */
public class RingingUtil {

    private MediaPlayer mMediaPlayer;
    private Vibrator mVibrator;
    private Context mContext;

    public RingingUtil(Context context) {
        mContext = context;
    }

    public void onIncomingCallRinging() {
        @SuppressLint("WrongConstant") AudioManager audio = (AudioManager) mContext.getSystemService("audio");
        assert audio != null;
        int ringerMode = audio.getRingerMode();
        if (ringerMode != AudioManager.RINGER_MODE_SILENT) {
            if (ringerMode == AudioManager.RINGER_MODE_VIBRATE) {
                mVibrator = (Vibrator) mContext.getSystemService(Context.VIBRATOR_SERVICE);
                mVibrator.vibrate(new long[]{500, 1000}, 0);
            } else {
                Uri uri = RingtoneManager.getDefaultUri(RingtoneManager.TYPE_RINGTONE);
                mMediaPlayer = new MediaPlayer();
                try {
                    mMediaPlayer.setDataSource(mContext, uri);
                    mMediaPlayer.setLooping(true);
                    mMediaPlayer.prepare();
                    mMediaPlayer.start();
                } catch (IOException e) {
                    e.printStackTrace();
                }
            }
        }
    }

    public void stopRing() {
        if (mMediaPlayer != null) {
            mMediaPlayer.stop();
            mMediaPlayer = null;
        }
        if (mVibrator != null) {
            mVibrator.cancel();
            mVibrator = null;
        }
    }
}
