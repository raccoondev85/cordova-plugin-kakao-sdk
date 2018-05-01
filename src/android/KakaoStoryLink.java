package com.raccoondev85.plugin.kakao;

import android.app.Activity;
import android.content.Context;
import android.content.Intent;
import android.content.pm.PackageManager;
import android.content.pm.ResolveInfo;
import android.net.Uri;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import java.io.UnsupportedEncodingException;
import java.net.URLEncoder;
import java.nio.charset.Charset;
import java.util.List;
import java.util.Map;

/**
 * @author leoshin on 15. 10. 7.
 */
class KakaoStoryLink {
    private static final String storyLinkApiVersion = "1.0";
    private static final String storyLinkURLBaseString = "storylink://posting";

    private static final Charset storyLinkCharset = Charset.forName("UTF-8");
    private static final String storyLinkEncoding = storyLinkCharset.name();

    private final Context context;
    private String params;

    private KakaoStoryLink(Context context) {
        super();
        this.context = context;
        this.params = getBaseStoryLinkUrl();
    }

    /**
     * Return the default singleton instance
     *
     * @param context Application context
     * @return StroyLink instance.
     */
    static KakaoStoryLink getLink(Context context) {
        return new KakaoStoryLink(context);
    }

    /**
     * Opens kakaoLink for parameter.
     *
     * @param activity Activity that will call startActivity()
     * @param params Params for KakaoLink
     */
    private void openStoryLink(Activity activity, String params) {
        Intent intent = new Intent(Intent.ACTION_SEND, Uri.parse(params));
        activity.startActivity(intent);
    }

    /**
     * Opens kakaoLink URL for parameters.
     *
     * @param activity Activity that will call startActivity()
     * @param post (message or url)
     * @param appId
     *            your application ID
     * @param appVer
     *            your application version
     * @param appName
     *            your application name
     * @param encoding
     *            recommend UTF-8
     * @param urlInfoAndroid URL info map object that will be transformed to json
     */
    public void openKakaoLink(Activity activity, String post, String appId, String appVer, String appName, String encoding, Map<String, Object> urlInfoAndroid) {

        if (isEmptyString(post) || isEmptyString(appId) || isEmptyString(appVer) || isEmptyString(appName) || isEmptyString(encoding))
            throw new IllegalArgumentException();

        try {
            if (storyLinkCharset.equals(Charset.forName(encoding)))
                post = new String(post.getBytes(encoding), storyLinkEncoding);
        } catch (UnsupportedEncodingException e) {
            e.printStackTrace();
        }

        this.params = getBaseStoryLinkUrl();

        appendParam("post", post);
        appendParam("appid", appId);
        appendParam("appver", appVer);
        appendParam("apiver", storyLinkApiVersion);
        appendParam("appname", appName);
        appendUrlInfo(urlInfoAndroid);

        openStoryLink(activity, params);
    }

    /**
     * @return Whether the application can open StoryLink URLs.
     */
    @SuppressWarnings("BooleanMethodIsAlwaysInverted")
    boolean isAvailableIntent() {
        Uri kakaoLinkTestUri = Uri.parse(storyLinkURLBaseString);
        Intent intent = new Intent(Intent.ACTION_SEND, kakaoLinkTestUri);
        List<ResolveInfo> list = context.getPackageManager().queryIntentActivities(intent, PackageManager.MATCH_DEFAULT_ONLY);
        return list != null && !list.isEmpty();
    }

    private boolean isEmptyString(String str) {
        return (str == null || str.trim().length() == 0);
    }

    private void appendParam(final String name, final String value) {
        try {
            String encodedValue = URLEncoder.encode(value, storyLinkEncoding);
            params = params + name + "=" + encodedValue + "&";
        } catch (UnsupportedEncodingException e) {
            e.printStackTrace();
        }
    }

    private void appendUrlInfo(Map<String, Object> urlInfoAndroid) {
        params += "urlinfo=";

        JSONObject metaObj = new JSONObject();

        try {
            for (String key : urlInfoAndroid.keySet()) {
                if("imageurl".equals(key)) {
                    metaObj.put(key, getImageUrl(urlInfoAndroid.get(key)));
                } else {
                    metaObj.put(key, urlInfoAndroid.get(key));
                }
            }
        } catch (JSONException e) {
            e.printStackTrace();
        }

        try {
            String encodedValue = URLEncoder.encode(metaObj.toString(), storyLinkEncoding);
            params += encodedValue;
        } catch (UnsupportedEncodingException e) {
            e.printStackTrace();
        }
    }

    private JSONArray getImageUrl(Object imageUrl) {
        JSONArray arrImageUrl = new JSONArray();
        String[] objImageUrl = (String[]) imageUrl;

        for (String anObjImageUrl : objImageUrl) {
            arrImageUrl.put(anObjImageUrl);
        }
        return arrImageUrl;
    }

    private String getBaseStoryLinkUrl() {
        return storyLinkURLBaseString + "?";
    }

    /**
     * Opens StoryLink for parameter.
     *
     * @param activity Activity that will call startActivity()
     * @param path Image path
     */
    public void openStoryLinkImageApp(Activity activity, String path) {
        Intent intent = new Intent(Intent.ACTION_SEND);
        intent.setType("image/png");
        intent.putExtra(Intent.EXTRA_STREAM, Uri.parse(path));
        intent.setPackage("com.kakao.story");
        activity.startActivity(intent);
    }
}
