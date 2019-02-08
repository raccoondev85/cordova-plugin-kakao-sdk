# cordova-plugin-kakao-sdk
Kakao Cordova SDK Plugin (카카오 코르도바 SDK 플러그인)

Version is updated to 3.0.0 
  - cordova-android compatibility between 6.4.0 and ^7.0.0 fixed
  - android SDK version changed from 1.12.0 to 1.16.0 (Google Play warning: Your app contains a Cross-App Scripting Vulnerability issue fixed)
  - ios SDK version changed from 1.9.0 to 1.11.1
  - new functions added  updateScopes(targetScopes: any), checkScopeStatus(targetScopes: any), requestSendMemo(builder: any), addPlusFriend(params: any), chatPlusFriend(params: any), chatPlusFriendUrl(params: any)

*Kakao Official Documents

**Android:  
  - Login: https://developers.kakao.com/docs/android/user-management
  - Link: https://developers.kakao.com/docs/android/kakaotalk-link
  - Talk: https://developers.kakao.com/docs/android/kakaotalk-api
  - PlusFriend: https://developers.kakao.com/docs/android/plusfriend
  
**iOS:  
  - Login: https://developers.kakao.com/docs/ios/user-management
  - Link: https://developers.kakao.com/docs/ios/kakaotalk-link
  - Talk: https://developers.kakao.com/docs/ios/kakaotalk-api
  - PlusFriend: https://developers.kakao.com/docs/ios/plusfriend


## Development Environment and ETC
|type|version
|---|---
|ionic (Ionic CLI)|3.19.1
|cordova (Cordova CLI)|8.0.0
|Cordova Platforms Android|7.1.4
|Cordova Platforms IOS|4.5.4
|Ionic Framework|ionic-angular 3.9.2
|KakaoCommon.framework(ios)|1.11.1
|KakaoLink.framework(ios)|1.11.1
|KakaoMessageTemplate.framework(ios)|1.11.1
|KakaoOpenSDK.framework(ios)|1.11.1
|KakaoPlusFriend.framework(ios)|1.11.1
|KakaoS2.framework(ios)|1.11.1
|com.kakao.sdk:kakaotalk(android)|1.16.0
|com.kakao.sdk:kakaolink(android)|1.16.0
|com.kakao.sdk:plusfriend(android)|1.16.0

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

## IONIC 3 DEMO
Environment

|type|version
|---|---
|cordova-plugin-kakao-sdk|3.0.0
|kakao-sdk|3.0.0

Link:
https://github.com/raccoondev85/cordova-plugin-kakao-sdk-example



# Login
## Login Methods
### `login(loginOptions)`


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
~~There is an optional parameter you can pass in to give users to choose various login ways through:~~
now it is mandatory, if you send with null object, it will be same as default as follows:

|options|type|default|iOS|Android|description
|---|---|---|---|---|---
|`authTypes`|any[]|[AuthTypes.AuthTypeTalk, AuthTypes.AuthTypeStory, AuthTypes.AuthTypeAccount]|yes|yes|Types of Authentication: "AuthTypes.AuthTypeTalk", "AuthTypes.AuthTypeStory", "AuthTypes.AuthTypeAccount", multiple values in this option will show the popup window to choose among the login methods unless one of those apps are not yet installed in the device(except AuthTypeAccount)


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


### `requestMe()`
Get user's profile info
```
  constructor(public _kakaoCordovaSDK: KakaoCordovaSDK) {
  this._kakaoCordovaSDK
      .requestMe()
      .then(
        res => {
          console.log(res);
        },
        err => {
        }
      )
      .catch(err => {
      });
  }
```

### `checkScopeStatus(targetScopes)`
Get required scopes
```
  constructor(public _kakaoCordovaSDK: KakaoCordovaSDK) {
    let values = {
    targetScopes: ['account_email', 'age_range', 'gender'],
  };

  this._kakaoCordovaSDK
    .checkScopeStatus(values)
    .then(
      res => {
      },
      err => {
      }
    )
    .catch(err => {
    });
  }
```
Parameter is mandatory, if you send with null object, it will be same as default as follows:

|options|type|default|iOS|Android|description
|---|---|---|---|---|---
|`targetScopes`|any[]|["account_email", "phone_number", "is_kakaotalk_user","age_range","gender","birthday"]|yes|yes|it checks target scopes, then returns required scopes that user does not yet agreed with

### `updateScopes(targetScopes)`
Update target scopes unless it is agreed, then returns new user's profile info 
```
  constructor(public _kakaoCordovaSDK: KakaoCordovaSDK) {
    let values = {
    targetScopes: ['account_email', 'age_range', 'gender'],
  };

  this._kakaoCordovaSDK
    .updateScopes(values)
    .then(
      res => {
      },
      err => {
      }
    )
    .catch(err => {
    });
  }
```
Parameter is mandatory, if you send with null object, it will be same as default as follows:

|options|type|default|iOS|Android|description
|---|---|---|---|---|---
|`targetScopes`|any[]|["account_email", "phone_number", "is_kakaotalk_user","age_range","gender","birthday"]|yes|yes|if target scopes are not yet agreed with, then asks to users to agrees with them, then returns new user's profile info 


# KakaoTalk
## Talk API (for normal developers)
### `requestSendMemo(builder)`
Send templated message to ME (only ME!! not the other friends).
You need to set already the template message in the kakao developers' console, then use the template id and other arguments like custom link (names of arguments' keys might be different based on the template settings. just pass them as what you set. In the example, argument keys are "title", "description", and "like". These could be more or less)
```
  constructor(public _kakaoCordovaSDK: KakaoCordovaSDK) {
    //your template id and arguments
    let customTemplate: KLCustomTemplate = {
      templateId: '9570', 
      arguments: {
        title: 'title for test',
        description: 'description for description',
        like: '5000000',
      }, 
    };
    this._kakaoCordovaSDK
      .requestSendMemo(customTemplate)
      .then(
        res => {
        },
        err => {
        }
      )
      .catch(err => {
      });
  }
```


# PlusFriend
## PlusFriend API 
### `addPlusFriend(params)`
Opens "Add Plus Friend" in the browser(ios), then opens kakaoTalk in order to add. it requires plus-friend's id.
```
  constructor(public _kakaoCordovaSDK: KakaoCordovaSDK) {
      // your plus friend id
    let plusFriendTemplate = {
      plusFriendId: '_xcLqmC',
    };
    this._kakaoCordovaSDK
      .addPlusFriend(plusFriendTemplate)
      .then(
        res => {
        },
        err => {
        }
      )
      .catch(err => {
      });
  }
```

### `chatPlusFriend(params)`
Opens "1:1 chat Plus Friend" in the browser(ios), then open kakaoTalk to chat with. it requires plus-friend's id.
```
  constructor(public _kakaoCordovaSDK: KakaoCordovaSDK) {
      // your plus friend id
    let plusFriendTemplate = {
      plusFriendId: '_xcLqmC',
    };
    this._kakaoCordovaSDK
      .chatPlusFriend(plusFriendTemplate)
      .then(
        res => {
        },
        err => {
        }
      )
      .catch(err => {
      });
  }
```

### `chatPlusFriendUrl(params)`
Get plusFriend's URLs it requires plus-friend's id.
it returns object as follows:
```
{
  "addFriendUrl":"https://pf.kakao.com/_xcLqmC/friend?app_key=4f4cd4e8784c29e753fdf2b6b45e63ca&api_ver=1.0&kakao_agent=sdk%2F1.11.1%20os%2Fios-12.1.2%20lang%2Fko-KR%20res%2F414x736%20device%2FiPhone10%2C5%20origin%2Fcom.example.admin.accountintergration.test%20app_ver%2F1.0.0",
  "chatUrl":"https://pf.kakao.com/_xcLqmC/chat?app_key=4f4cd4e8784c29e753fdf2b6b45e63ca&api_ver=1.0&kakao_agent=sdk%2F1.11.1%20os%2Fios-12.1.2%20lang%2Fko-KR%20res%2F414x736%20device%2FiPhone10%2C5%20origin%2Fcom.example.admin.accountintergration.test%20app_ver%2F1.0.0"
}
```

```
  constructor(public _kakaoCordovaSDK: KakaoCordovaSDK) {
      // your plus friend id
    let plusFriendTemplate = {
      plusFriendId: '_xcLqmC',
    };
    this._kakaoCordovaSDK
      .chatPlusFriendUrl(plusFriendTemplate)
      .then(
        res => {
        },
        err => {
        }
      )
      .catch(err => {
      });
  }
```

# Link
## Link Parameters
All the url properties(webURL or mobileWebURL) must be set in the domatin section in the Kakao developer console in order to work as expected.

### Objects
#### `KLContentObject`
|name|type|required
|---|---|---
|title|string|mandatory
|link|KLLinkObject|mandatory
|imageURL|string|mandatory
|desc|string|optional
|imageWidth|string|optional
|imageHeight|string|optional

#### `KLLinkObject`
|name|type|required
|---|---|---
|webURL|string|optional
|mobileWebURL|string|optional
|androidExecutionParams|string|optional
|iosExecutionParams|string|optional

#### `KLSocialObject`
|name|type|required
|---|---|---
|likeCount|number|optional
|commentCount|number|optional
|sharedCount|number|optional
|viewCount|number|optional
|subscriberCount|number|optional

#### `KLCommerceObject`
|name|type|required
|---|---|---
|regularPrice|number|mandatory
|discountPrice|number|optional
|discountRate|number|optional
|fixedDiscountPrice|number|optional

#### `KLButtonObject`
|name|type|required
|---|---|---    
|title|string|mandatory
|link|KLLinkObject|mandatory


### Templates
#### `KLFeedTemplate`
|name|type|required
|---|---|---    
|content|KLContentObject|mandatory
|social|KLSocialObject|optional
|buttonTitle|string|optional
|buttons|KLButtonObject[]|optional

#### `KLListTemplate`
|name|type|required
|---|---|---   
|headerTitle|string|mandatory
|headerLink|KLLinkObject|mandatory
|contents|KLContentObject[]|mandatory
|buttonTitle|string|optional
|buttons|KLButtonObject[]|optional

#### `KLLocationTemplate`
|name|type|required
|---|---|---   
|address|string|mandatory
|content|KLContentObject|mandatory
|addressTitle|string|optional
|social|KLSocialObject|optional
|buttonTitle|string|optional
|buttons|KLButtonObject[]|optional

#### `KLCommerceTemplate`
|name|type|required
|---|---|---   
|content|KLContentObject|mandatory
|commerce|KLCommerceObject|mandatory
|buttonTitle|string|optional
|buttons|KLButtonObject[]|optional

#### `KLTextTemplate`
|name|type|required
|---|---|---  
|text|string|mandatory
|link|KLLinkObject|mandatory
|buttonTitlestring|optional
|buttonsKLButtonObject[]|optional

#### `KLScrapTemplate`
|name|type|required
|---|---|---  
|url|string|mandatory

#### `KLCustomTemplate`
|name|type|required
|---|---|---  
|templateId|string|mandatory
|title|string|optional
|description|string|optional


### Configs
#### `KLUploadImageConfig`
|name|type|required
|---|---|---  
|fileOrUrl|'file' or 'url'|mandatory
|url|string|optional(in case fileOrUrl property is 'url')

#### `KLDeleteImageConfig`
|name|type|required
|---|---|---  
|url|string|mandatory

#### `KLPostStoryConfig`
|name|type|required
|---|---|---  
|post|string|mandatory
|appver|string|mandatory
|appid|string|optional
|appname|string|optional
|urlinfo|KLPostStoryUrlInfo|optional

#### `KLPostStoryUrlInfo`
|name|type|required
|---|---|---  
|title|string|mandatory
|desc|string|optional
|imageURLs|string[]|optional
|type|ScrapType|optional

#### `ScrapType`
|name|value
|---|--- 
|ScrapTypeNone|0
|ScrapTypeWebsite|1
|ScrapTypeVideo|2
|ScrapTypeMusic|3
|ScrapTypeBook|4
|ScrapTypeArticle|5
|ScrapTypeProfile|6




## Link Methods
### `sendLinkFeed(feedTemplate: KLFeedTemplate)`
Send a default feed template to kakao talk
```
  constructor(public _kakaoCordovaSDK: KakaoCordovaSDK) {
    let feedLink: KLLinkObject = {
      webURL: 'url that registered in the domain section in kakao developer console',
    };

    let feedSocial: KLSocialObject = {
      likeCount: 50,
    };

    let feedButtons1: KLButtonObject = {
      title: 'button1',
      link: {
        mobileWebURL: 'url that registered in the domain section in kakao developer console',
      },
    };

    let feedButtons2: KLButtonObject = {
      title: 'button2',
      link: {
        iosExecutionParams: 'param1=value1&param2=value2',
        androidExecutionParams: 'param1=value1&param2=value2',
      },
    };

    let feedContent: KLContentObject = {
      title: 'title',
      link: feedLink,
      imageURL: 'http://mud-kage.kakao.co.kr/dn/Q2iNx/btqgeRgV54P/VLdBs9cvyn8BJXB3o7N8UK/kakaolink40_original.png'
    };


    let feedTemplate: KLFeedTemplate = {
      content: feedContent,
      social: feedSocial,
      buttons: [feedButtons1, feedButtons2]
    };


    this._kakaoCordovaSDK
      .sendLinkFeed(feedTemplate)
      .then(
        res => {
          console.log(res);
          
        },
        err => {
          console.log(err);
        }
      )
      .catch(err => {
        console.log(err);
      });
  }
```


### `sendLinkList(listTemplate: KLListTemplate)`
Send a default list template to kakao talk
```
  constructor(public _kakaoCordovaSDK: KakaoCordovaSDK) {

    let listHeaderLink: KLLinkObject = {
      webURL: 'url that registered in the domain section in kakao developer console',
      mobileWebURL: 'url that registered in the domain section in kakao developer console',
    };

    let listContent1: KLContentObject = {
      title: '자전거 라이더를 위한 공간',
      desc: '매거진',
      link: listHeaderLink,
      imageURL: 'http://mud-kage.kakao.co.kr/dn/QNvGY/btqfD0SKT9m/k4KUlb1m0dKPHxGV8WbIK1/openlink_640x640s.jpg'
    };

    let listContent2: KLContentObject = {
      title: '비쥬얼이 끝내주는 오레오 카푸치노',
      desc: '매거진',
      link: listHeaderLink,
      imageURL: 'http://mud-kage.kakao.co.kr/dn/boVWEm/btqfFGlOpJB/mKsq9z6U2Xpms3NztZgiD1/openlink_640x640s.jpg'
    };

    let listContent3: KLContentObject = {
      title: '감성이 가득한 분위기',
      desc: '매거진',
      link: listHeaderLink,
      imageURL: 'http://mud-kage.kakao.co.kr/dn/NTmhS/btqfEUdFAUf/FjKzkZsnoeE4o19klTOVI1/openlink_640x640s.jpg'
    };

    let listButtons1: KLButtonObject = {
      title: 'button1',
      link: {
        mobileWebURL: 'https://www.naver.com',
      },
    };

    let listButtons2: KLButtonObject = {
      title: 'button2',
      link: {
        iosExecutionParams: 'param1=value1&param2=value2',
        androidExecutionParams: 'param1=value1&param2=value2',
      },
    };

    let listTemplate: KLListTemplate = {
      headerTitle: 'List Template Test',
      headerLink: listHeaderLink,
      contents: [listContent1, listContent2, listContent3],
      buttonTitle: '',
      buttons: [listButtons1, listButtons2]
    };

    this._kakaoCordovaSDK
    .sendLinkList(listTemplate)
    .then(
      res => {
        console.log(res);
        
      },
      err => {
        console.log(err);
      }
    )
    .catch(err => {
      console.log(err);
    });
  }
```


### `sendLinkLocation(locationTemplate: KLLocationTemplate)`
Send a default location template to kakao talk
```
  constructor(public _kakaoCordovaSDK: KakaoCordovaSDK) {

    let locationContent: KLContentObject = {
      title: '카카오 판교오피스',
      desc: '카카오 판교오피스 위치입니다.',
      link: {
        mobileWebURL: 'url that registered in the domain section in kakao developer console'
      },
      imageURL: 'http://mud-kage.kakao.co.kr/dn/bSbH9w/btqgegaEDfW/vD9KKV0hEintg6bZT4v4WK/kakaolink40_original.png'
    };

    let locationSocial: KLSocialObject = {
      likeCount: 50,
      sharedCount: 1234
    };

    let locationTemplate: KLLocationTemplate = {
      content: locationContent,
      address: '성남시 분당구 판교역로 235',
      addressTitle: '"카카오 판교오피스',
      social: locationSocial,
      buttonTitle: '웹으로 보자'
    }

    this._kakaoCordovaSDK
    .sendLinkLocation(locationTemplate)
    .then(
      res => {
        console.log(res);
        
      },
      err => {
        console.log(err);
      }
    )
    .catch(err => {
      console.log(err);
    });
  }
```


### `sendLinkCommerce(commerceTemplate: KLCommerceTemplate)`
Send a default commerce template to kakao talk
```
  constructor(public _kakaoCordovaSDK: KakaoCordovaSDK) {
    let commerceContent: KLContentObject = {
      title: 'Ivory long dress (4 Color)',
      link: {
        mobileWebURL: 'url that registered in the domain section in kakao developer console'
      },
      imageURL: 'http://mud-kage.kakao.co.kr/dn/RY8ZN/btqgOGzITp3/uCM1x2xu7GNfr7NS9QvEs0/kakaolink40_original.png'
    };

    let commerceCommerce: KLCommerceObject = {
      regularPrice: 208800,
      discountPrice: 146160,
      discountRate: 30
    };

    let commerceButtons1: KLButtonObject = {
      title: '구매하기',
      link: {
        mobileWebURL: 'url that registered in the domain section in kakao developer console',
      },
    };

    let commerceButtons2: KLButtonObject = {
      title: '공유하기',
      link: {
        iosExecutionParams: 'param1=value1&param2=value2',
        androidExecutionParams: 'param1=value1&param2=value2',
      },
    };

    let commerceTemplate: KLCommerceTemplate = {
      content: commerceContent,
      commerce: commerceCommerce,
      buttons: [commerceButtons1, commerceButtons2],
      buttonTitle: '웹으로 보자'
    }

    this._kakaoCordovaSDK
    .sendLinkCommerce(commerceTemplate)
    .then(
      res => {
        console.log(res);
      },
      err => {
        console.log(err);
      }
    )
    .catch(err => {
      console.log(err);
    });
  }
```


### `sendLinkText(textTemplate: KLTextTemplate)`
Send a default text template to kakao talk
```
  constructor(public _kakaoCordovaSDK: KakaoCordovaSDK) {
    let textLink: KLLinkObject = {
      webURL: 'url that registered in the domain section in kakao developer console',
      mobileWebURL: 'url that registered in the domain section in kakao developer console',
    };
    let textButtons1: KLButtonObject = {
      title: 'button1',
      link: {
        mobileWebURL: 'url that registered in the domain section in kakao developer console',
      },
    };

    let textButtons2: KLButtonObject = {
      title: 'button2',
      link: {
        iosExecutionParams: 'param1=value1&param2=value2',
        androidExecutionParams: 'param1=value1&param2=value2',
      },
    };

    let textTemplate: KLTextTemplate = {
      text: 'Text Template Test',
      link: textLink,
      buttonTitle: '',
      buttons: [textButtons1, textButtons2]
    };

    this._kakaoCordovaSDK
    .sendLinkText(textTemplate)
    .then(
      res => {
        console.log(res);
      },
      err => {
        console.log(err);
      }
    )
    .catch(err => {
      console.log(err);
    });
  }
```


### `sendLinkScrap(scrapTemplate: KLScrapTemplate)`
Send a scrap template to kakao talk
```
  constructor(public _kakaoCordovaSDK: KakaoCordovaSDK) {
    let scrapTemplate: KLScrapTemplate = {
      url: 'url that registered in the domain section in kakao developer console'
    };

    this._kakaoCordovaSDK
    .sendLinkScrap(scrapTemplate)
    .then(
      res => {
        console.log(res);
      },
      err => {
        console.log(err);
      }
    )
    .catch(err => {
      console.log(err);
    });
  }
```


### `sendLinkCustom(scrapTemplate: KLCustomTemplate)`
~~Send a custom template to kakao talk.
You need to make a template in the kakao developer console in order to get templateId.
and if you would like to change title and description dynamically, 
it is also required to put `${title}` and `${description}` as value in the template~~
See above "requestSendMemo()". same parameter.
```
  constructor(public _kakaoCordovaSDK: KakaoCordovaSDK) {
    //your template id and arguments
    let customTemplate: KLCustomTemplate = {
      templateId: '9570', 
      arguments: {
        title: 'title for test',
        description: 'description for description',
        like: '5000000',
      }, 
    };


    this._kakaoCordovaSDK
    .sendLinkCustom(customTemplate)
    .then(
      res => {
        console.log(res);
      },
      err => {
        console.log(err);
      }
    )
    .catch(err => {
      console.log(err);
    });
  }
```


### `uploadImage(uploadImageConfig: KLUploadImageConfig)`
While Kakao doesn't allow you to upload image files themselves, Kakao supports to generate a new url, which saved in kakao server for 20 days, so that you could use in the templates as url values.
```
  constructor(public _kakaoCordovaSDK: KakaoCordovaSDK) {
    let uploadImageConfig: KLUploadImageConfig = {
      fileOrUrl: fileOrUrl?fileOrUrl:'file',
      url: url?url:''
    }
    this._kakaoCordovaSDK
    .uploadImage(uploadImageConfig)
    .then(
      res => {
        console.log(res);
      },
      err => {
        console.log(err);
      }
    )
    .catch(err => {
      console.log(err);
    });
  }
```


### `deleteUploadedImage(deleteImageConfig: KLDeleteImageConfig)`
Delete the uploaded image from kakao server.
```
  constructor(public _kakaoCordovaSDK: KakaoCordovaSDK) {
    let deleteImageConfig: KLDeleteImageConfig = {
      url: 'uploadImageUrl',

    }
    this._kakaoCordovaSDK
    .deleteUploadedImage(deleteImageConfig)
    .then(
      res => {
        console.log(res);
      },
      err => {
        console.log(err);
      }
    )
    .catch(err => {
      console.log(err);
    });
  }
```

### `postStory(postStoryConfig: KLPostStoryConfig)`
post contents on Kakao Story
```
  constructor(public _kakaoCordovaSDK: KakaoCordovaSDK) {
    let postStoryUrlInfo: KLPostStoryUrlInfo = {
      title: 'Sample',
      desc: 'Sample 입니다.',
      imageURLs: ['http://mud-kage.kakao.co.kr/dn/RY8ZN/btqgOGzITp3/uCM1x2xu7GNfr7NS9QvEs0/kakaolink40_original.png']
      type: ScrapType.ScrapTypeVideo
    }
    let postStoryConfig: KLPostStoryConfig = {
      post: 'Sample Story Posting https://www.youtube.com/watch?v=XUX1jtTKkKs',
      appver: '1.0',
      urlinfo: postStoryUrlInfo
    }
    this._kakaoCordovaSDK
    .postStory(postStoryConfig)
    .then(
      res => {
        console.log(res);
      },
      err => {
        console.log(err);
      }
    )
    .catch(err => {
      console.log(err);
    });
  }
```
