package com.raccoondev85.plugin.kakao;

import android.app.Activity;
import android.app.Dialog;
import android.content.Context;
import android.content.Intent;
import android.os.Build;
import android.util.Log;
import android.view.Gravity;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.view.Window;
import android.widget.AdapterView;
import android.widget.ArrayAdapter;
import android.widget.Button;
import android.widget.ImageView;
import android.widget.ListAdapter;
import android.widget.ListView;
import android.widget.TextView;

import com.kakao.kakaolink.v2.KakaoLinkService;
import com.kakao.kakaolink.v2.KakaoLinkResponse;
import com.kakao.message.template.*;
import com.kakao.network.callback.*;
import com.kakao.auth.ApprovalType;
import com.kakao.auth.AuthType;
import com.kakao.auth.IApplicationConfig;
import com.kakao.auth.ISessionCallback;
import com.kakao.auth.ISessionConfig;
import com.kakao.auth.KakaoAdapter;
import com.kakao.auth.KakaoSDK;
import com.kakao.auth.Session;
import com.kakao.network.ErrorResult;
import com.kakao.usermgmt.UserManagement;
import com.kakao.usermgmt.callback.LogoutResponseCallback;
import com.kakao.usermgmt.callback.MeResponseCallback;
import com.kakao.usermgmt.callback.UnLinkResponseCallback;
import com.kakao.usermgmt.response.model.UserProfile;
import com.kakao.util.KakaoParameterException;
import com.kakao.util.exception.KakaoException;
import com.raccoondev85.plugin.kakao.KakaoResources;

import org.apache.cordova.CallbackContext;
import org.apache.cordova.CordovaInterface;
import org.apache.cordova.CordovaPlugin;
import org.apache.cordova.CordovaWebView;
import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.HashMap;
import java.util.Iterator;
import java.util.List;
import java.util.Map;

public class KakaoCordovaSDK extends CordovaPlugin {

    private static final String LOG_TAG = "KakaoCordovaSDK";
    private static volatile Activity currentActivity;
    private SessionCallback callback;
    private static AuthType[] customAuthTypes;

    public void initialize(CordovaInterface cordova, CordovaWebView webView) {
        Log.v(LOG_TAG, "kakao : initialize");
        super.initialize(cordova, webView);
        currentActivity = this.cordova.getActivity();
        try{
            KakaoSDK.init(new KakaoSDKAdapter());
            KakaoResources.initResources(cordova.getActivity().getApplication());
        }catch (Exception e){

        }

    }

    public boolean execute(final String action, JSONArray options, final CallbackContext callbackContext) throws JSONException {
        Log.v(LOG_TAG, "kakao : execute " + action);
        cordova.setActivityResultCallback(this);
        callback = new SessionCallback(callbackContext);
        Session.getCurrentSession().addCallback(callback);

        if (action.equals("login")) {
            this.login(callbackContext, options);
            return true;
        } else if (action.equals("logout")) {
            this.logout(callbackContext);
            return true;
	    } else if (action.equals("unlinkApp")) {
            this.unlinkApp(callbackContext);
            return true;
	    } else if (action.equals("getAccessToken")) {
	        this.getAccessToken(callbackContext);
	        return true;
        }
        return false;
    }

    private void login(final CallbackContext callbackContext, JSONArray options) {
        try {
            final JSONObject parameters = options.getJSONObject(0);
            if (parameters.has("authTypes")){
                JSONArray authTypes = new JSONArray(parameters.getString("authTypes"));
                setCustomAuthTypes(authTypes);
            }
        } catch(Exception e) {
            e.printStackTrace();
            callbackContext.error("Exception error : " + e);
        } finally {
            onClickLoginButton(getAuthTypes());
        }
    }

    private void logout(final CallbackContext callbackContext) {
        cordova.getThreadPool().execute(new Runnable() {
            @Override
            public void run() {
                UserManagement.getInstance().requestLogout(new LogoutResponseCallback() {
                    @Override
                    public void onCompleteLogout() {
                        Log.v(LOG_TAG, "kakao : onCompleteLogout");
                        callbackContext.success();
                    }
                });
            }
        });
    }

    private void unlinkApp(final CallbackContext callbackContext) {
        cordova.getThreadPool().execute(new Runnable() {
            @Override
            public void run() {
                UserManagement.getInstance().requestUnlink(new UnLinkResponseCallback() {
                    @Override
                    public void onFailure(ErrorResult errorResult) {
                        callbackContext.error("kakao : SessionCallback.onSessionOpened.requestUnlink.onFailure - " + errorResult);
                    }

                    @Override
                    public void onSessionClosed(ErrorResult errorResult) {
                        Log.v(LOG_TAG, "kakao : SessionCallback.onSessionOpened.requestUnlink.onSessionClosed - " + errorResult);
                        Session.getCurrentSession().checkAndImplicitOpen();
                    }

                    @Override
                    public void onSuccess(Long userId) {
                        callbackContext.success(Long.toString(userId));
                    }

                    @Override
                    public void onNotSignedUp() {
                        callbackContext.error("this user is not signed up");
                    }
                });
            }
        });
    }

    private void getAccessToken(CallbackContext callbackContext) {
        // this.login();
        String accessToken = Session.getCurrentSession().getTokenInfo().getAccessToken();
        callbackContext.success(accessToken);
    }

    public void onActivityResult(int requestCode, int resultCode, Intent intent) {
        Log.v(LOG_TAG, "kakao : onActivityResult : " + requestCode + ", code: " + resultCode);
        if (Session.getCurrentSession().handleActivityResult(requestCode, resultCode, intent)) {
            return;
        }
        super.onActivityResult(requestCode, resultCode, intent);
    }

    private JSONObject handleLoginResult(UserProfile userProfile, String accessToken) {
        Log.v(LOG_TAG, "kakao : handleLoginResult");
        JSONObject response = new JSONObject();
        try {
            Log.v(LOG_TAG, "kakao response: " + response);
            JSONObject userinfo = new JSONObject();

            userinfo.put("accessToken", accessToken);
            userinfo.put("id", userProfile.getId());
            userinfo.put("email", userProfile.getEmail());
            userinfo.put("emailVerified", userProfile.getEmailVerified());
            userinfo.put("nickname", userProfile.getNickname());
            userinfo.put("profileImagePath", userProfile.getProfileImagePath());
            userinfo.put("thumbnailImagePath", userProfile.getThumbnailImagePath());

            JSONObject prop = new JSONObject(userProfile.getProperties());
            JSONObject[] objs = new JSONObject[] { userinfo, prop };
            for (JSONObject obj : objs) {
                Iterator it = obj.keys();
                while (it.hasNext()) {
                    String key = (String)it.next();
                    response.put(key, obj.get(key));
                }
            }
        } catch (JSONException e) {
            Log.v(LOG_TAG, "kakao : handleResult error - " + e.toString());
        }
        return response;
    }

    private class SessionCallback implements ISessionCallback {

        private CallbackContext callbackContext;

        public SessionCallback(final CallbackContext callbackContext) {
            this.callbackContext = callbackContext;
        }

        @Override
        public void onSessionOpened() {
            Log.v(LOG_TAG, "kakao : SessionCallback.onSessionOpened");

            UserManagement.getInstance().requestMe(new MeResponseCallback() {
                @Override
                public void onFailure(ErrorResult errorResult) {
                    callbackContext.error("kakao : SessionCallback.onSessionOpened.requestMe.onFailure - " + errorResult);
                }

                @Override
                public void onSessionClosed(ErrorResult errorResult) {
                    Log.v(LOG_TAG, "kakao : SessionCallback.onSessionOpened.requestMe.onSessionClosed - " + errorResult);
                    Session.getCurrentSession().checkAndImplicitOpen();
                }

                @Override
                public void onSuccess(UserProfile userProfile) {
                    callbackContext.success(handleLoginResult(userProfile, Session.getCurrentSession().getTokenInfo().getAccessToken()));
                }

                @Override
                public void onNotSignedUp() {
                    callbackContext.error("this user is not signed up");
                }

            });
        }

        @Override
        public void onSessionOpenFailed(KakaoException exception) {
            if (exception != null) {
                Log.v(LOG_TAG, "kakao : onSessionOpenFailed" + exception.toString());
            }
        }
    }

    public static Activity getCurrentActivity() {
        return currentActivity;
    }

    public static void setCurrentActivity(Activity currentActivity) {
        currentActivity = currentActivity;
    }

    public static AuthType[] getCustomAuthTypes() {
        return customAuthTypes;
    }

    public static void setCustomAuthTypes(JSONArray _customAuthTypes) {
        if(_customAuthTypes == null){
            return;
        }
        try {
            Map<AuthType, MyAuthType> tempAuthTypes = new HashMap<AuthType, MyAuthType>();
            for(int i=0; i<_customAuthTypes.length(); i++){
//                Log.d(LOG_TAG, _customAuthTypes.get(i)+"");
                if(MyAuthType.AuthTypeTalk.getNumber() == Integer.parseInt(_customAuthTypes.get(i).toString())){
                    tempAuthTypes.put(AuthType.KAKAO_TALK, MyAuthType.AuthTypeTalk);
                } else if(MyAuthType.AuthTypeStory.getNumber() == Integer.parseInt(_customAuthTypes.get(i).toString())){
                    tempAuthTypes.put(AuthType.KAKAO_STORY, MyAuthType.AuthTypeStory);
                } else if(MyAuthType.AuthTypeAccout.getNumber() == Integer.parseInt(_customAuthTypes.get(i).toString())){
                    tempAuthTypes.put(AuthType.KAKAO_ACCOUNT, MyAuthType.AuthTypeAccout);
                }
            }
            AuthType[] types;
            if(tempAuthTypes.size() == 3){
                types = new AuthType[1];
                types[0] = AuthType.KAKAO_LOGIN_ALL;
            }else{
                types = new AuthType[tempAuthTypes.size()];
                int count = 0;
                for( AuthType key : tempAuthTypes.keySet() ){
                    types[count] = key;
                    count++;
                }

            }
//            Log.d(LOG_TAG, types.toString());
            customAuthTypes = types;
        }catch (Exception e){
            e.printStackTrace();
        }

    }



    /**
     * Class KakaoSDKAdapter
     */
    private static class KakaoSDKAdapter extends KakaoAdapter {

        @Override
        public ISessionConfig getSessionConfig() {
            return new ISessionConfig() {
                @Override
                public AuthType[] getAuthTypes() {
                    return new AuthType[]{AuthType.KAKAO_LOGIN_ALL};
                }

                @Override
                public boolean isUsingWebviewTimer() {
                    return false;
                }

                @Override
                public ApprovalType getApprovalType() {
                    return ApprovalType.INDIVIDUAL;
                }

                @Override
                public boolean isSecureMode() {
                    return false;
                }

                @Override
                public boolean isSaveFormData() {
                    return true;
                }
            };
        }

        @Override
        public IApplicationConfig getApplicationConfig() {
            return new IApplicationConfig() {
                @Override
                public Context getApplicationContext() {
                    return KakaoCordovaSDK.getCurrentActivity().getApplicationContext();
                }
            };
        }
    }


    private List<AuthType> getAuthTypes() {
        final List<AuthType> availableAuthTypes = new ArrayList();

        AuthType[] authTypes;

        if(getCustomAuthTypes() == null){
            authTypes = KakaoSDK.getAdapter().getSessionConfig().getAuthTypes();

            if (Session.getCurrentSession().getAuthCodeManager().isTalkLoginAvailable()) {
                availableAuthTypes.add(AuthType.KAKAO_TALK);
            }
            if (Session.getCurrentSession().getAuthCodeManager().isStoryLoginAvailable()) {
                availableAuthTypes.add(AuthType.KAKAO_STORY);
            }
            availableAuthTypes.add(AuthType.KAKAO_ACCOUNT);

        } else {
            authTypes = getCustomAuthTypes();
        }

        if (authTypes == null || authTypes.length == 0 || (authTypes.length == 1 && authTypes[0] == AuthType.KAKAO_LOGIN_ALL)) {
            authTypes = AuthType.values();
        }
        availableAuthTypes.retainAll(Arrays.asList(authTypes));

        // 개발자가 설정한 것과 available 한 타입이 없다면 직접계정 입력이 뜨도록 한다.
        if(availableAuthTypes.size() == 0){
            availableAuthTypes.add(AuthType.KAKAO_ACCOUNT);
        }
        return availableAuthTypes;
    }

    private void onClickLoginButton(final List<AuthType> authTypes){
       if (authTypes.size() == 1) {
           openSession(authTypes.get(0));

       } else {
            final Item[] authItems = createAuthItemArray(authTypes);
            ListAdapter adapter = createLoginAdapter(authItems);
            final Dialog dialog = createLoginDialog(authItems, adapter);
            dialog.show();
       }
    }

    /**
     * 가능한 AuhType들이 담겨 있는 리스트를 인자로 받아 로그인 어댑터의 data source로 사용될 Item array를 반환한다.
     * @param authTypes 가능한 AuthType들을 담고 있는 리스트
     * @return 실제로 로그인 방법 리스트에 사용될 Item array
     */
    private Item[] createAuthItemArray(final List<AuthType> authTypes) {
        final List<Item> itemList = new ArrayList<Item>();


        if(authTypes.contains(AuthType.KAKAO_TALK)) {
            itemList.add(new Item(KakaoResources.com_kakao_kakaotalk_account, KakaoResources.talk, KakaoResources.com_kakao_kakaotalk_account_tts, AuthType.KAKAO_TALK));
        }
        if(authTypes.contains(AuthType.KAKAO_STORY)) {
            itemList.add(new Item(KakaoResources.com_kakao_kakaostory_account, KakaoResources.story, KakaoResources.com_kakao_kakaostory_account_tts, AuthType.KAKAO_STORY));
        }
        if(authTypes.contains(AuthType.KAKAO_ACCOUNT)){
            itemList.add(new Item(KakaoResources.com_kakao_other_kakaoaccount, KakaoResources.account, KakaoResources.com_kakao_other_kakaoaccount_tts, AuthType.KAKAO_ACCOUNT));
        }

        return itemList.toArray(new Item[itemList.size()]);
    }


    @SuppressWarnings("deprecation")
    private ListAdapter createLoginAdapter(final Item[] authItems) {
        /*
          가능한 auth type들을 유저에게 보여주기 위한 준비.
         */
        return new ArrayAdapter<Item>(
                cordova.getActivity(),
                android.R.layout.select_dialog_item,
                android.R.id.text1, authItems){
            @Override
            public View getView(int position, View convertView, ViewGroup parent) {
                if (convertView == null) {

                    LayoutInflater inflater = (LayoutInflater) getContext()
                            .getSystemService(Context.LAYOUT_INFLATER_SERVICE);
                    convertView = inflater.inflate(KakaoResources.layout_login_item, parent, false);
                }

                ImageView imageView = convertView.findViewById(KakaoResources.login_method_icon);
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP) {
                    imageView.setImageDrawable(cordova.getActivity().getResources().getDrawable(authItems[position].icon, getContext().getTheme()));
                } else {
                    imageView.setImageDrawable(cordova.getActivity().getResources().getDrawable(authItems[position].icon));
                }
                TextView textView = convertView.findViewById(KakaoResources.login_method_text);
                textView.setText(authItems[position].textId);
                return convertView;
            }
        };
    }

    /**
     * 실제로 유저에게 보여질 dialog 객체를 생성한다.
     * @param authItems 가능한 AuthType들의 정보를 담고 있는 Item array
     * @param adapter Dialog의 list view에 쓰일 adapter
     * @return 로그인 방법들을 팝업으로 보여줄 dialog
     */
    private Dialog createLoginDialog(final Item[] authItems, final ListAdapter adapter) {

        final Dialog dialog = new Dialog(cordova.getActivity(), KakaoResources.LoginDialog);
        dialog.requestWindowFeature(Window.FEATURE_NO_TITLE);
        dialog.setContentView(KakaoResources.layout_login_dialog);
        if (dialog.getWindow() != null) {
            dialog.getWindow().setGravity(Gravity.CENTER);
        }

        ListView listView = dialog.findViewById(KakaoResources.login_list_view);
        listView.setAdapter(adapter);
        listView.setOnItemClickListener(new AdapterView.OnItemClickListener() {
            @Override
            public void onItemClick(AdapterView<?> parent, View view, int position, long id) {
                final AuthType authType = authItems[position].authType;
                if (authType != null) {
                    openSession(authType);
                }
                dialog.dismiss();
            }
        });

        Button closeButton = dialog.findViewById(KakaoResources.login_close_button);
        closeButton.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                dialog.dismiss();
            }
        });
        return dialog;
    }

    public void openSession(final AuthType authType) {
        cordova.getActivity().runOnUiThread(new Runnable() {
            @Override
            public void run() {
                Session.getCurrentSession().open(authType, cordova.getActivity());
            }
        });

    }

    /**
     * 각 로그인 방법들의 text, icon, 실제 AuthTYpe들을 담고 있는 container class.
     */
    private static class Item {
        final int textId;
        public final int icon;
        final int contentDescId;
        final AuthType authType;
        Item(final int textId, final Integer icon, final int contentDescId, final AuthType authType) {
            this.textId = textId;
            this.icon = icon;
            this.contentDescId = contentDescId;
            this.authType = authType;
        }
    }

    private enum MyAuthType {
        AuthTypeTalk(1),
        AuthTypeStory(2),
        AuthTypeAccout(3),
        AuthTypeAll(4);
        private final int number;

        MyAuthType(int i) {
            this.number = i;
        }

        public int getNumber() {
            return number;
        }

        public static MyAuthType valueOf(int number){
            if(number == AuthTypeTalk.getNumber()) {
                return AuthTypeTalk;
            } else if (number == AuthTypeStory.getNumber()) {
                return AuthTypeStory;
            } else if (number == AuthTypeAccout.getNumber()) {
                return AuthTypeAccout;
            }  else if (number == AuthTypeAll.getNumber()) {
                return AuthTypeAll;
            } else {
                return null;
            }
        }
    }
}
