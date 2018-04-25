# cordova-plugin-kakao-sdk
Kakao Cordova SDK Plugin (카카오 코르도바 SDK 플러그인)

## Development Environment and ETC
|type|version
|---|---
|ionic (Ionic CLI)|3.19.1
|cordova (Cordova CLI)|8.0.0
|Cordova Platforms Android|6.4.0
|Cordova Platforms IOS|4.5.4
|Ionic Framework|ionic-angular 3.9.2
|KakaoOpenSDK.framework(ios)|1.7.0
|com.kakao.sdk:kakaotalk(android)|1.10.1
|com.kakao.sdk:kakaolink(android)|1.10.1


## How to install
install cordova plugin
```
// KAKAO_APP_KEY: the app key that you got assigned as a native key in the kakao development console
$ cordova plugin add cordova-plugin-kakao-sdk --variable KAKAO_APP_KEY=YOUR_KAKAO_APP_KEY
```

install wrapper for kakao cordova sdk plugin to interface
```
$ npm install --save kakao-sdk
```

then import __KakaoCordovaSDK__ module into app.module.ts
```
import { KakaoCordovaSDK } from 'kakao-sdk';

@NgModule({
  providers: [
    KakaoCordovaSDK
  ]
})
```

## Methods
### `login()`


```
import { KakaoCordovaSDK, AuthTypes } from 'kakao-sdk';

  constructor(public _kakaoCordovaSDK: KakaoCordovaSDK) {
    let loginOptions = {};
    loginOptions['authTypes'] = [
                                  AuthTypes.AuthTypeTalk, 
                                  AuthTypes.AuthTypeStory,
                                  AuthTypes.AuthTypeAccount
                                ];
    
    this._kakaoCordovaSDK.login(loginOptions).then((res) => {
        console.log(res);
      }
    );
  }
```
There is an optional parameter you can pass in to give users to choose various login ways through:

|options|type|default|iOS|Android|description
|---|---|---|---|---|---
|`authTypes`|any[]|[AuthTypes.AuthTypeTalk,AuthTypes.AuthTypeStory,AuthTypes.AuthTypeAccount]|yes|yes|Types of Authentication: "AuthTypes.AuthTypeTalk", "AuthTypes.AuthTypeStory", "AuthTypes.AuthTypeAccount", multiple values in this option will show the popup window to choose among the login methods unless one of those apps are not yet installed in the device(except AuthTypeAccount)


Return values are "id", "accessToken", "email", "emailVerified", "nickname", "profileImagePath", "thumbnailImagePath", and etc(basically everthing that SDK gives but it might be slightly different  depending on OS, AuthType, or user's setting, for example "profileImagePath" or "thumbnailImagePath" not be given if user doesn't set up, or "email" might not exist if you did not set up as mandatory parameter in the kakao development console )

### `logout()`
```
  constructor(public _kakaoCordovaSDK: KakaoCordovaSDK) {
    this._kakaoCordovaSDK.logout().then(() => {
        //do your logout proccess for your app
      }
    );
  }
```
return null

### `unlinkApp()`
Unregister app for your app service. 
```
  constructor(public _kakaoCordovaSDK: KakaoCordovaSDK) {
    this._kakaoCordovaSDK.unlinkApp().then(() => {
        //do your unregister proccess for your app
      }
    );
  }
```

### `getAccessToken()`
Get current access token.
```
  constructor(public _kakaoCordovaSDK: KakaoCordovaSDK) {
    this._kakaoCordovaSDK.getAccessToken().then((res) => {
        console.log(res);
      }
    );
  }
```
it returns the current access token.


