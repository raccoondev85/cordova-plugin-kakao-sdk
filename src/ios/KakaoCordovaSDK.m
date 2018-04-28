#import "KakaoCordovaSDK.h"
#import <Cordova/CDVPlugin.h>
#import <KakaoOpenSDK/KakaoOpenSDK.h>


@implementation KakaoCordovaSDK

- (void)pluginInitialize {
    NSLog(@"Start KaKao plugin");
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(openURL:)
                                                 name:CDVPluginHandleOpenURLNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(applicationDidBecomeActive)
                                                 name:UIApplicationDidBecomeActiveNotification object:nil];
}

- (void) login:(CDVInvokedUrlCommand*) command
{
    NSArray *defaultAuthTypes = @[@((KOAuthType)KOAuthTypeTalk),
                            @((KOAuthType)KOAuthTypeStory),
                            @((KOAuthType)KOAuthTypeAccount)];
    NSMutableDictionary *loginOptions = [[command.arguments lastObject] mutableCopy];
    NSArray* authTypes = loginOptions[@"authTypes"];
    NSLog(@"%@", authTypes);
    if(authTypes == nil || [authTypes count] < 1){
        authTypes = [defaultAuthTypes copy];
        NSLog(@"%@", authTypes);
    } else if([authTypes count] > 1) {
        NSMutableArray* tmpAuthTypes = [[NSMutableArray alloc] init];
        for (NSNumber* element in authTypes) {
            NSLog(@"%@", element);
            
            if([element integerValue] == (MyAuthType)MyAuthTypeTalk){
                [tmpAuthTypes addObject:[NSNumber numberWithInt:((KOAuthType)KOAuthTypeTalk)]];
            } else if([element integerValue] == (MyAuthType)MyAuthTypeStory){
                [tmpAuthTypes addObject:[NSNumber numberWithInt:((KOAuthType)KOAuthTypeStory)]];
            } else if([element integerValue] == (MyAuthType)MyAuthTypeAccount){
                [tmpAuthTypes addObject:[NSNumber numberWithInt:((KOAuthType)KOAuthTypeAccount)]];
            }
        }
        authTypes = [tmpAuthTypes copy];
    }
    [[KOSession sharedSession] close];
    
    [[KOSession sharedSession] openWithCompletionHandler:^(NSError *error) {
        
        if ([[KOSession sharedSession] isOpen]) {
            // login success
            NSLog(@"login succeeded.");
            [KOSessionTask meTaskWithCompletionHandler:^(KOUser* result, NSError *error) {
                CDVPluginResult* pluginResult = nil;
                if (result) {
                    // success
                    
                    NSLog(@"%@", result);
                    NSMutableDictionary *userSession =  [NSMutableDictionary new];
                    NSDictionary *userIdAndEmail = @{
                                                        @"accessToken": [KOSession sharedSession].accessToken,
                                                        @"id": result.ID, 
                                                        @"email": result.email, 
                                                        @"isVerifiedEmail": @(result.isVerifiedEmail)};
                    NSDictionary *userProperties = result.properties;
                    NSDictionary *userExtras = result.extras;
                    [userSession addEntriesFromDictionary: userIdAndEmail];
                    [userSession addEntriesFromDictionary: userProperties];
                    [userSession addEntriesFromDictionary: userExtras];
                    pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:userSession];
                } else {
                    // failed
                    NSLog(@"login session failed.");
                    pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:[error localizedDescription]];
                }
                [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
            }];
        } else {
            // failed
            NSLog(@"login failed.");
            CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:[error localizedDescription]];
            [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
        }
        
        
    } authTypes:authTypes];
}

- (void)logout:(CDVInvokedUrlCommand*)command
{
    [[KOSession sharedSession] logoutAndCloseWithCompletionHandler:^(BOOL success, NSError *error) {
        if (success) {
            // logout success.
            NSLog(@"Successful logout.");
            CDVPluginResult* pluginResult = pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
            [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
        } else {
            // failed
            NSLog(@"failed to logout.");
             CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:[error localizedDescription]];
            [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
        }
    }];
    
}


- (void)unlinkApp:(CDVInvokedUrlCommand*)command
{
    [KOSessionTask unlinkTaskWithCompletionHandler:^(BOOL success, NSError *error) {
        if (success) {
            // logout success.
            NSLog(@"Successful unlink.");
            CDVPluginResult* pluginResult = pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
            [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId]; 
        } else {
            // failed
            NSLog(@"failed to unlink.");
            CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:[error localizedDescription]];
            [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
        }
    }];

    
}


- (void)getAccessToken: (CDVInvokedUrlCommand*)command
{
    CDVPluginResult* pluginResult = pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:[KOSession sharedSession].accessToken];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

- (void)openURL:(NSNotification *)notification {
    NSLog(@"handle url1: %@", [notification object]);
    NSURL *url = [notification object];
    
    if (![url isKindOfClass:[NSURL class]]) {
        return;
    }
    if ([KOSession isKakaoAccountLoginCallback:url]){
     [KOSession handleOpenURL:url];
    }
}

- (void)applicationDidBecomeActive {
    [KOSession handleDidBecomeActive];
    
}

@end



