#import <UIKit/UIKit.h>
#import <Cordova/CDVPlugin.h>
@interface KakaoCordovaSDK : CDVPlugin
typedef NS_ENUM(NSInteger, MyAuthType) {
    MyAuthTypeTalk = 1,
    MyAuthTypeStory = 2,
    MyAuthTypeAccount = 3
};
- (void) login:(CDVInvokedUrlCommand*)command;
- (void) logout:(CDVInvokedUrlCommand*)command;
- (void) getAccessToken:(CDVInvokedUrlCommand*)command;
@end

