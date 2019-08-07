package chat1v1.chatcall.ChatCall.presenter;

import chat1v1.chatcall.ChatCall.VideoChatPreview;

/**
 * Created by Genda on 2019-07-28.
 */
public interface IVideoChatAtView {
    VideoChatPreview getVideoChatPreview();

    void onVideoCallDuration(long duration);

    void onVideoCallHeart();

    void onVideoCallGoldNoTimer(int duration);
}
