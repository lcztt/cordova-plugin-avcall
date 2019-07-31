package chat1v1.chatcall.ChatCall.util;

import android.Manifest;

import org.apache.cordova.CallbackContext;
import org.apache.cordova.CordovaPlugin;
import org.apache.cordova.PermissionHelper;

/**
 * Created by Genda on 2019-07-29.
 */
public class PermissionUtil {

    public static final int PERMISSION_VOICE = 11;
    public static final int PERMISSION_VIDEO = 22;

    private static String[] mVoicePermissions = {
            Manifest.permission.INTERNET,
            Manifest.permission.ACCESS_NETWORK_STATE,
            Manifest.permission.ACCESS_WIFI_STATE,
            Manifest.permission.READ_PHONE_STATE,
            Manifest.permission.WRITE_EXTERNAL_STORAGE,
            Manifest.permission.RECORD_AUDIO,
    };

    private static String[] mVideoPermissions = {
            Manifest.permission.INTERNET,
            Manifest.permission.ACCESS_NETWORK_STATE,
            Manifest.permission.ACCESS_WIFI_STATE,
            Manifest.permission.READ_PHONE_STATE,
            Manifest.permission.WRITE_EXTERNAL_STORAGE,
            Manifest.permission.RECORD_AUDIO,
            Manifest.permission.CAMERA
    };


    public static boolean authPermission(int permissionType, CallbackContext callbackContext, CordovaPlugin cordovaPlugin) {
        switch (permissionType) {
            case 1:
                if (hasPermission(mVideoPermissions, cordovaPlugin)) {
                    callbackContext.success("");
                    return true;
                } else {
                    PermissionHelper.requestPermissions(cordovaPlugin, PERMISSION_VIDEO, mVideoPermissions);
                }
            case 2:
            case 3:
                if (hasPermission(mVoicePermissions, cordovaPlugin)) {
                    callbackContext.success("");
                    return true;
                } else {
                    PermissionHelper.requestPermissions(cordovaPlugin, PERMISSION_VOICE, mVoicePermissions);
                }
            default:
                return false;
        }
    }

    //public static void reqPermission(int callType, CordovaPlugin cordovaPlugin) {
    //    String[] permission;
    //    int reqCode;
    //    if (callType == 1) {
    //        permission = mVideoPermissions;
    //        reqCode = PERMISSION_VIDEO;
    //    } else if (callType == 2) {
    //        permission = mVoicePermissions;
    //        reqCode = PERMISSION_VOICE;
    //    } else {
    //        return;
    //    }
    //    PermissionHelper.requestPermissions(cordovaPlugin, reqCode, permission);
    //}
    //
    //public static boolean checkCallPermission(int callType, CordovaPlugin cordovaPlugin) {
    //    String[] permission;
    //    if (callType == 1) {
    //        permission = mVideoPermissions;
    //    } else if (callType == 2) {
    //        permission = mVoicePermissions;
    //    } else {
    //        return false;
    //    }
    //    return hasPermission(permission, cordovaPlugin);
    //}

    public static boolean hasPermission(String[] permissions, CordovaPlugin cordovaPlugin) {
        for (String p : permissions) {
            if (!PermissionHelper.hasPermission(cordovaPlugin, p)) {
                return false;
            }
        }
        return true;
    }
}
