package com.raccoondev85.plugin.kakao;

import android.app.Application;
import android.content.res.Resources;

public class KakaoResources {

    public static int com_kakao_kakaotalk_account;
    public static int com_kakao_kakaostory_account;
    public static int com_kakao_other_kakaoaccount;
    public static int talk;
    public static int story;
    public static int account;
    public static int com_kakao_kakaotalk_account_tts;
    public static int com_kakao_kakaostory_account_tts;
    public static int com_kakao_other_kakaoaccount_tts;
    public static int layout_login_item;
    public static int login_method_icon;
    public static int login_method_text;
    public static int LoginDialog;
    public static int layout_login_dialog;
    public static int login_list_view;
    public static int login_close_button;
    public static int app_name;

    public static void initResources(Application _app){
        final Application app  = _app;
        final String package_name = app.getPackageName();
        final Resources resources = app.getResources();


        com_kakao_kakaotalk_account = resources.getIdentifier("com_kakao_kakaotalk_account", "string", package_name);
        com_kakao_kakaostory_account = resources.getIdentifier("com_kakao_kakaostory_account", "string", package_name);
        com_kakao_other_kakaoaccount = resources.getIdentifier("com_kakao_other_kakaoaccount", "string", package_name);

        talk = resources.getIdentifier("talk", "drawable", package_name);
        story = resources.getIdentifier("story", "drawable", package_name);
        account = resources.getIdentifier("account", "drawable", package_name);

        com_kakao_kakaotalk_account_tts = resources.getIdentifier("com_kakao_kakaotalk_account_tts", "string", package_name);
        com_kakao_kakaostory_account_tts = resources.getIdentifier("com_kakao_kakaostory_account_tts", "string", package_name);
        com_kakao_other_kakaoaccount_tts = resources.getIdentifier("com_kakao_other_kakaoaccount_tts", "string", package_name);

        layout_login_item = resources.getIdentifier("layout_login_item", "layout", package_name);
        login_method_icon = resources.getIdentifier("login_method_icon", "id", package_name);
        login_method_text = resources.getIdentifier("login_method_text", "id", package_name);

        LoginDialog = resources.getIdentifier("LoginDialog", "style", package_name);
        layout_login_dialog = resources.getIdentifier("layout_login_dialog", "layout", package_name);
        login_list_view = resources.getIdentifier("login_list_view", "id", package_name);
        login_close_button = resources.getIdentifier("login_close_button", "id", package_name);

        app_name = resources.getIdentifier("app_name", "string", package_name);
    }


}
