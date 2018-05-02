package com.raccoondev85.plugin.kakao;

import com.kakao.network.ErrorResult;

import org.apache.cordova.CallbackContext;
import org.json.JSONObject;

import java.net.HttpURLConnection;

public class KakaoCordovaErrorHandler {
    public static void errorHandler(CallbackContext callbackContext, ErrorResult errorResult){
        if(callbackContext == null){
            return;
        }
        try{
            JSONObject errorJson =  new JSONObject();
            errorJson.put("osType", "android");
            errorJson.put("errorCode", String.valueOf(errorResult.getErrorCode()));
            errorJson.put("errorMessage", String.valueOf(errorResult.getErrorMessage()));

            JSONObject extraErrorJson =  new JSONObject();
            extraErrorJson.put("httpStatus", String.valueOf(errorResult.getHttpStatus()));
            extraErrorJson.put("exception", (errorResult.getException() != null ? errorResult.getException().toString() : ""));

            errorJson.put("extra", extraErrorJson);

            callbackContext.error(errorJson);
        }catch (Exception e){
            callbackContext.error("Something went wrong. " + e.toString());
        }
    }

    public static void errorHandler(CallbackContext callbackContext, String errorMessage){
        if(callbackContext == null){
            return;
        }
        try{
            JSONObject errorJson =  new JSONObject();
            errorJson.put("osType", "android");
            errorJson.put("errorCode", String.valueOf(-777));
            errorJson.put("errorMessage", errorMessage);

            JSONObject extraErrorJson =  new JSONObject();
            extraErrorJson.put("httpStatus", HttpURLConnection.HTTP_INTERNAL_ERROR);
            extraErrorJson.put("exception", "");

            errorJson.put("extra", extraErrorJson);
            callbackContext.error(errorJson);
        }catch (Exception e){
            callbackContext.error("Something went wrong. " + e.toString());
        }
    }

    public static void errorHandler(CallbackContext callbackContext, int errorCode, String errorMessage){
        if(callbackContext == null){
            return;
        }
        try{
            JSONObject errorJson =  new JSONObject();
            errorJson.put("osType", "android");
            errorJson.put("errorCode", String.valueOf(errorCode));
            errorJson.put("errorMessage", errorMessage);
            JSONObject extraErrorJson =  new JSONObject();
            extraErrorJson.put("httpStatus", HttpURLConnection.HTTP_INTERNAL_ERROR);
            extraErrorJson.put("exception", "");

            errorJson.put("extra", extraErrorJson);
            callbackContext.error(errorJson);
        }catch (Exception e){
            callbackContext.error("Something went wrong. " + e.toString());
        }
    }

}
