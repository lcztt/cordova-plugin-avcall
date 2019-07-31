package chat1v1.chatcall.ChatCall;

import android.content.Context;
import android.support.annotation.NonNull;
import android.support.annotation.Nullable;
import android.util.AttributeSet;
import android.util.Log;
import android.view.SurfaceView;
import android.view.View;
import android.widget.FrameLayout;

import bobo.chatapp.R;
import io.agora.rtc.RtcEngine;

/**
 * Created by Genda on 2019-07-27.
 */
public class VideoChatPreview extends FrameLayout {

    private static final String TAG = "VideoChatPreview";
    private Context mContext;

    private FrameLayout fl_local;
    private FrameLayout fl_remote;

    public VideoChatPreview(@NonNull Context context) {
        this(context, null);
    }

    public VideoChatPreview(@NonNull Context context, @Nullable AttributeSet attrs) {
        this(context, attrs, 0);
    }

    public VideoChatPreview(@NonNull Context context, @Nullable AttributeSet attrs, int defStyleAttr) {
        super(context, attrs, defStyleAttr);

        mContext = context;
        View view = inflate(mContext, R.layout.view_video_chat_preview, this);
        fl_local = view.findViewById(R.id.fl_video_chat_preview_local);
        fl_remote = view.findViewById(R.id.fl_video_chat_preview_remote);

        //fl_remote.setOnClickListener(new OnClickListener() {
        //    @Override
        //    public void onClick(View v) {
        //        changePreview();
        //    }
        //});
    }

    public void changePreview() {
        try {
            SurfaceView fromView = (SurfaceView) fl_remote.getChildAt(0);
            SurfaceView toView = (SurfaceView) fl_local.getChildAt(0);

            fl_local.removeAllViews();
            fl_remote.removeAllViews();

            if (fromView != null && toView != null) {
                fromView.setZOrderOnTop(false);
                fromView.setZOrderMediaOverlay(false);
                fl_remote.addView(toView);

                toView.setZOrderOnTop(true);
                toView.setZOrderMediaOverlay(true);
                fl_local.addView(fromView);
            }

        } catch (Exception e) {
            Log.e(TAG, "changePreview: 切换视图view 出错 ...... " + e.getMessage());
            e.printStackTrace();
        }
    }

    public SurfaceView getLocalSurfaceView() {
        SurfaceView surfaceView = RtcEngine.CreateRendererView(mContext);
        surfaceView.setZOrderMediaOverlay(true);
        fl_local.addView(surfaceView);
        return surfaceView;
    }

    public SurfaceView getRemoteSurfaceView() {
        if (fl_remote.getChildCount() >= 1) {
            return null;
        }
        SurfaceView surfaceV = RtcEngine.CreateRendererView(mContext);
        surfaceV.setFitsSystemWindows(true);
        surfaceV.setZOrderOnTop(true);
        surfaceV.setZOrderMediaOverlay(true);

        fl_remote.addView(surfaceV, 0);
        return surfaceV;
    }

    public FrameLayout getFl_local() {
        return fl_local;
    }
}
