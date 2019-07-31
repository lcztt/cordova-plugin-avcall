package chat1v1.chatcall.ChatCall.presenter;

import android.content.Context;

import java.lang.ref.Reference;
import java.lang.ref.WeakReference;

/**
 * Created by Genda on 2019-07-28.
 */
public class BasePresenter<V> {

    public Context mContext;

    protected Reference<V> mViewRef;

    public BasePresenter(Context context) {
        mContext = context;
    }

    public void attachView(V view){
        mViewRef = new WeakReference<V>(view);
    }

    public boolean isViewAttached() {
        return mViewRef != null && mViewRef.get() != null;
    }

    public void detachView() {
        if (mViewRef != null) {
            mViewRef.clear();
            mViewRef = null;
        }
    }

    public V getView() {
        return mViewRef != null ? mViewRef.get() : null;
    }
}