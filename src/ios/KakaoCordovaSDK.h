#import <UIKit/UIKit.h>
#import <Cordova/CDVPlugin.h>
#import <KakaoOpenSDK/KakaoOpenSDK.h>
#import <KakaoLink/KakaoLink.h>
#import <KakaoMessageTemplate/KakaoMessageTemplate.h>
#import <KakaoS2/KakaoS2.h>
#import <KakaoPlusFriend/KakaoPlusFriend.h>
#import "KakaoCordovaStoryLinkHelper.h"
#import "AppDelegate.h"

@interface KakaoCordovaSDK : CDVPlugin <UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIScrollViewDelegate>

typedef NS_ENUM(NSInteger, MyAuthType) {
    MyAuthTypeTalk = 1,
    MyAuthTypeStory = 2,
    MyAuthTypeAccount = 3
};
- (void) login:(CDVInvokedUrlCommand*)command;
- (void) logout:(CDVInvokedUrlCommand*)command;
- (void) getAccessToken:(CDVInvokedUrlCommand*)command;
- (void) requestMe:(CDVInvokedUrlCommand*)command;
- (void) updateScopes:(CDVInvokedUrlCommand*)command;
- (void) checkScopeStatus:(CDVInvokedUrlCommand*)command;
- (void) requestSendMemo:(CDVInvokedUrlCommand*)command;
- (void) addPlusFriend:(CDVInvokedUrlCommand*)command;
- (void) chatPlusFriend:(CDVInvokedUrlCommand*)command;
- (void) chatPlusFriendUrl:(CDVInvokedUrlCommand*)command;
- (void) sendLinkFeed:(CDVInvokedUrlCommand*)command;
- (void) sendLinkList:(CDVInvokedUrlCommand*)command;
- (void) sendLinkLocation:(CDVInvokedUrlCommand*)command;
- (void) sendLinkCommerce:(CDVInvokedUrlCommand*)command;
- (void) sendLinkText:(CDVInvokedUrlCommand*)command;
- (void) sendLinkScrap:(CDVInvokedUrlCommand*)command;
- (void) sendLinkCustom:(CDVInvokedUrlCommand*)command;
- (void) uploadImage:(CDVInvokedUrlCommand*)command;
- (void) deleteUploadedImage:(CDVInvokedUrlCommand*)command;
- (void) postStory:(CDVInvokedUrlCommand*)command;
@end

