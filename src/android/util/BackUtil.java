package chat1v1.chatcall.ChatCall.util;

import android.graphics.Bitmap;
import android.os.Environment;

import java.io.File;
import java.io.FileNotFoundException;
import java.io.FileOutputStream;

/**
 * Created by Genda on 2019-07-26.
 */
public class BackUtil {



    public String getInnerSDCardPath() {
        return Environment.getExternalStorageDirectory().getPath();
    }

    /**
     * 将图片保存在指定路径中
     *
     * @param bitmap
     * @param descPath
     */
    public static void saveBitmap(Bitmap bitmap, String descPath) {
        File file = new File(descPath);
        if (!file.getParentFile().exists()) {
            file.getParentFile().mkdirs();
        }

        try {
            bitmap.compress(Bitmap.CompressFormat.JPEG, 30, new FileOutputStream(
                    file));
        } catch (FileNotFoundException e) {
            e.printStackTrace();
        }

        if (null != bitmap) {
            bitmap.recycle();
            bitmap = null;
        }
    }
}
