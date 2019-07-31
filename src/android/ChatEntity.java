package chat1v1.chatcall.ChatCall;

import android.os.Parcel;
import android.os.Parcelable;

/**
 * Created by Genda on 2019-07-27.
 */
public class ChatEntity implements Parcelable {

    public CallBean call;
    public UserInfoBean userInfo;

    public ChatEntity() {
    }

    protected ChatEntity(Parcel in) {
        call = in.readParcelable(CallBean.class.getClassLoader());
        userInfo = in.readParcelable(UserInfoBean.class.getClassLoader());
    }

    public static final Creator<ChatEntity> CREATOR = new Creator<ChatEntity>() {
        @Override
        public ChatEntity createFromParcel(Parcel in) {
            return new ChatEntity(in);
        }

        @Override
        public ChatEntity[] newArray(int size) {
            return new ChatEntity[size];
        }
    };

    @Override
    public int describeContents() {
        return 0;
    }

    @Override
    public void writeToParcel(Parcel dest, int flags) {
        dest.writeParcelable(call, flags);
        dest.writeParcelable(userInfo, flags);
    }

    public static class CallBean implements Parcelable{

        public String app_id;
        public String room_id;
        public String token;
        public int call_type;
        public int screen_interval = 60;
        public int heart_interval = 30;

        public CallBean() {
        }

        protected CallBean(Parcel in) {
            app_id = in.readString();
            room_id = in.readString();
            token = in.readString();
            call_type = in.readInt();
            screen_interval = in.readInt();
            heart_interval = in.readInt();
        }

        public static final Creator<CallBean> CREATOR = new Creator<CallBean>() {
            @Override
            public CallBean createFromParcel(Parcel in) {
                return new CallBean(in);
            }

            @Override
            public CallBean[] newArray(int size) {
                return new CallBean[size];
            }
        };

        @Override
        public int describeContents() {
            return 0;
        }

        @Override
        public void writeToParcel(Parcel dest, int flags) {
            dest.writeString(app_id);
            dest.writeString(room_id);
            dest.writeString(token);
            dest.writeInt(call_type);
            dest.writeInt(screen_interval);
            dest.writeInt(heart_interval);
        }
    }

    public static class UserInfoBean implements Parcelable{

        public String start_uid;
        public String receive_uid;
        public String self_uid;

        public UserInfoBean() {
        }

        protected UserInfoBean(Parcel in) {
            start_uid = in.readString();
            receive_uid = in.readString();
            self_uid = in.readString();
        }

        public static final Creator<UserInfoBean> CREATOR = new Creator<UserInfoBean>() {
            @Override
            public UserInfoBean createFromParcel(Parcel in) {
                return new UserInfoBean(in);
            }

            @Override
            public UserInfoBean[] newArray(int size) {
                return new UserInfoBean[size];
            }
        };

        @Override
        public int describeContents() {
            return 0;
        }

        @Override
        public void writeToParcel(Parcel dest, int flags) {
            dest.writeString(start_uid);
            dest.writeString(receive_uid);
            dest.writeString(self_uid);
        }
    }
}


