#import "KakaoCordovaSDK.h"
#import <Cordova/CDVPlugin.h>

@implementation KakaoCordovaSDK


@synthesize callbackId;


- (void)pluginInitialize {
    NSLog(@"Start KaKao plugin");
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_9_0
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(openURL:)
                                                 name:CDVPluginHandleOpenURLNotification object:nil];
#endif
#if __IPHONE_OS_VERSION_MAX_ALLOWED < __IPHONE_9_0
    // Add notification listener for handleOpenURL
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(openURL:)
                                                 name:CDVPluginHandleOpenURLWithAppSourceAndAnnotationNotification object:nil];
#endif
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
    } else if([authTypes count] >= 1) {
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
            [self requestMe:command];
            
        } else {
            // failed
            NSLog(@"login failed.");
            [self errorHandler:command.callbackId error:error errorCode:0 errorMessage:nil];
        }
        
        
    } authTypes:authTypes];
}

- (void)requestMe:(CDVInvokedUrlCommand*)command {
    [KOSessionTask userMeTaskWithCompletion:^(NSError *error, KOUserMe *me) {
        CDVPluginResult* pluginResult = nil;
        if (error) {
            // failed
            NSLog(@"login session failed.");
            [self errorHandler:command.callbackId error:error errorCode:0 errorMessage:nil];
            
        } else {
            // success
            
            NSMutableDictionary *userSession =  [NSMutableDictionary new];

            [userSession addEntriesFromDictionary: @{@"accessToken": [KOSession sharedSession].token.accessToken}];
            [userSession addEntriesFromDictionary: me.dictionary];

            NSLog(@"%@", userSession);

            pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:userSession];
            [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
        }
    }];
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
            [self errorHandler:command.callbackId error:error errorCode:0 errorMessage:nil];
            
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
            [self errorHandler:command.callbackId error:error errorCode:0 errorMessage:nil];
        }
    }];
}




- (void)getAccessToken: (CDVInvokedUrlCommand*)command
{
    CDVPluginResult* pluginResult = pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:[KOSession sharedSession].token.accessToken];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}


- (void)sendLinkFeed:(CDVInvokedUrlCommand*)command
{
    NSMutableDictionary *options = [[command.arguments lastObject] mutableCopy];
    NSLog(@"%@", options);
    
    // feed template
    KMTTemplate *template = [KMTFeedTemplate feedTemplateWithBuilderBlock:^(KMTFeedTemplateBuilder * _Nonnull feedTemplateBuilder) {
        
        // content
        KMTContentObject* feedContentObject = [self getKMTContentObject:options[@"content"]];
        if(feedContentObject == NULL){
            [self errorHandler:command.callbackId error:NULL errorCode:0 errorMessage:@"Either Content or Content.title/link/imageURL is null."];
            return;
        }
        feedTemplateBuilder.content = feedContentObject;
        
        // social
        KMTSocialObject* feedSocialObject = [self getKMTSocialObject:options[@"social"]];
        if(feedSocialObject != NULL){
            feedTemplateBuilder.social = feedSocialObject;
        }
        
        // buttons
        [self addButtonsArray:options[@"buttons"] templateBuilder:feedTemplateBuilder];
        
        // buttonTitle
        if(options[@"buttonTitle"] != NULL){
            feedTemplateBuilder.buttonTitle = options[@"buttonTitle"];
        }
        
    }];
    
    // 카카오링크 실행
    [self sendDefaultWithTemplate:template command:command];
}

- (void)sendLinkList:(CDVInvokedUrlCommand*)command
{
    NSMutableDictionary *options = [[command.arguments lastObject] mutableCopy];
    NSLog(@"%@", options);
    
    
    // List 타입 템플릿 오브젝트 생성
    KMTTemplate *template = [KMTListTemplate listTemplateWithBuilderBlock:^(KMTListTemplateBuilder * _Nonnull listTemplateBuilder) {
        
        
        // 헤더 타이틀 및 링크
        if(options[@"headerTitle"] == NULL){
            [self errorHandler:command.callbackId error:NULL errorCode:0 errorMessage:@"headerTitle is null."];
            return;
        }
        listTemplateBuilder.headerTitle = options[@"headerTitle"];
        
        // headerLink
        KMTLinkObject* linkObject = [self getKMTLinkObject:options[@"headerLink"]];
        if(linkObject == NULL){
            [self errorHandler:command.callbackId error:NULL errorCode:0 errorMessage:@"headerLink is null."];
            return;
        }
        listTemplateBuilder.headerLink = linkObject;
        
        // 컨텐츠 목록
        if(FALSE == [self addContentsArray:options[@"contents"] templateBuilder:listTemplateBuilder]){
            [self errorHandler:command.callbackId error:NULL errorCode:0 errorMessage:@"Either Content or Content.title/link/imageURL is null."];
            return;
        }
        
        // buttons
        [self addButtonsArray:options[@"buttons"] templateBuilder:listTemplateBuilder];
        
        // buttonTitle
        if(options[@"buttonTitle"] != NULL){
            listTemplateBuilder.buttonTitle = options[@"buttonTitle"];
        }
    }];
    
    // 카카오링크 실행
    [self sendDefaultWithTemplate:template command:command];
    
}

- (void)sendLinkLocation:(CDVInvokedUrlCommand*)command
{
    NSMutableDictionary *options = [[command.arguments lastObject] mutableCopy];
    NSLog(@"%@", options);
    
    // Location 타입 템플릿 오브젝트 생성
    KMTTemplate *template = [KMTLocationTemplate locationTemplateWithBuilderBlock:^(KMTLocationTemplateBuilder * _Nonnull locationTemplateBuilder) {
        
        // 주소
        if(options[@"address"] == NULL){
            [self errorHandler:command.callbackId error:NULL errorCode:0 errorMessage:@"address is null."];
            return;
        }
        locationTemplateBuilder.address = options[@"address"];
        
        if(options[@"addressTitle"] != NULL){
            locationTemplateBuilder.addressTitle = options[@"addressTitle"];
        }
        
        // content
        KMTContentObject* locationContentObject = [self getKMTContentObject:options[@"content"]];
        if(locationContentObject == NULL){
            [self errorHandler:command.callbackId error:NULL errorCode:0 errorMessage:@"Either Content or Content.title/link/imageURL is null."];
            return;
        }
        locationTemplateBuilder.content = locationContentObject;
        
        // social
        KMTSocialObject* feedSocialObject = [self getKMTSocialObject:options[@"social"]];
        if(feedSocialObject != NULL){
            locationTemplateBuilder.social = feedSocialObject;
        }
        
        // buttons
        [self addButtonsArray:options[@"buttons"] templateBuilder:locationTemplateBuilder];
        
        // buttonTitle
        if(options[@"buttonTitle"] != NULL){
            locationTemplateBuilder.buttonTitle = options[@"buttonTitle"];
        }
    }];
    
    // 카카오링크 실행
    [self sendDefaultWithTemplate:template command:command];
}

- (void)sendLinkCommerce:(CDVInvokedUrlCommand*)command
{
    NSMutableDictionary *options = [[command.arguments lastObject] mutableCopy];
    NSLog(@"%@", options);
    
    // Commerce 타입 템플릿 오브젝트 생성
    KMTTemplate *template = [KMTCommerceTemplate commerceTemplateWithBuilderBlock:^(KMTCommerceTemplateBuilder * _Nonnull commerceTemplateBuilder) {
        
        // content
        KMTContentObject* commerceContentObject = [self getKMTContentObject:options[@"content"]];
        if(commerceContentObject == NULL){
            [self errorHandler:command.callbackId error:NULL errorCode:0 errorMessage:@"Either Content or Content.title/link/imageURL is null."];
            return;
        }
        commerceTemplateBuilder.content = commerceContentObject;
        
        // commerce
        KMTCommerceObject* feedCommerceObject = [self getKMTCommerceObject:options[@"commerce"]];
        if(feedCommerceObject == NULL){
            [self errorHandler:command.callbackId error:NULL errorCode:0 errorMessage:@"regularPrice is null."];
            return;
        }
        commerceTemplateBuilder.commerce = feedCommerceObject;
        
        // buttons
        [self addButtonsArray:options[@"buttons"] templateBuilder:commerceTemplateBuilder];
        
        // buttonTitle
        if(options[@"buttonTitle"] != NULL){
            commerceTemplateBuilder.buttonTitle = options[@"buttonTitle"];
        }
        
    }];
    
    // 카카오링크 실행
    [self sendDefaultWithTemplate:template command:command];
}


- (void)sendLinkText:(CDVInvokedUrlCommand*)command
{
    NSMutableDictionary *options = [[command.arguments lastObject] mutableCopy];
    NSLog(@"%@", options);
    
    // feed template
    KMTTemplate *template = [KMTTextTemplate textTemplateWithBuilderBlock:^(KMTTextTemplateBuilder * _Nonnull textTemplateBuilder) {
        
        // text
        if(options[@"text"] == NULL){
            [self errorHandler:command.callbackId error:NULL errorCode:0 errorMessage:@"headerTitle is null."];
            return;
        }
        textTemplateBuilder.text = options[@"text"];
        
        // link
        KMTLinkObject* linkObject = [self getKMTLinkObject:options[@"link"]];
        if(linkObject == NULL){
            [self errorHandler:command.callbackId error:NULL errorCode:0 errorMessage:@"link is null."];
            return;
        }
        textTemplateBuilder.link = linkObject;
        
        
        // buttons
        [self addButtonsArray:options[@"buttons"] templateBuilder:textTemplateBuilder];
        
        // buttonTitle
        if(options[@"buttonTitle"] != NULL){
            textTemplateBuilder.buttonTitle = options[@"buttonTitle"];
        }
        
    }];
    
    // 카카오링크 실행
    [self sendDefaultWithTemplate:template command:command];
}

- (void)sendLinkScrap:(CDVInvokedUrlCommand*)command
{
    NSMutableDictionary *options = [[command.arguments lastObject] mutableCopy];
    NSLog(@"%@", options);
    
    // 스크랩할 웹페이지 URL
    if(options[@"url"] == NULL){
        [self errorHandler:command.callbackId error:NULL errorCode:0 errorMessage:@"url is null."];
        return;
    }
    NSURL *URL = [NSURL URLWithString:options[@"url"]];
    
    // 카카오링크 실행
    [[KLKTalkLinkCenter sharedCenter] sendScrapWithURL:URL success:^(NSDictionary<NSString *,NSString *> * _Nullable warningMsg, NSDictionary<NSString *,NSString *> * _Nullable argumentMsg) {
        
        // 성공
        NSLog(@"warning message: %@", warningMsg);
        NSLog(@"argument message: %@", argumentMsg);
        CDVPluginResult* pluginResult = pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:@"success!"];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
        
    } failure:^(NSError * _Nonnull error) {
        
        NSLog(@"error: %@", error);
        [self errorHandler:command.callbackId error:error errorCode:0 errorMessage:nil];
        
    }];
}

- (void)sendLinkCustom:(CDVInvokedUrlCommand*)command
{
    NSMutableDictionary *options = [[command.arguments lastObject] mutableCopy];
    NSLog(@"%@", options);
    // 템플릿 ID
    if(options[@"templateId"] == NULL){
        [self errorHandler:command.callbackId error:NULL errorCode:0 errorMessage:@"templateId is null."];
        return;
    }
    NSString *templateId = options[@"templateId"];
    
    // 템플릿 Arguments
    NSMutableDictionary *templateArgs =  [NSMutableDictionary new];
    if(options[@"title"] != NULL){
        [templateArgs setObject:options[@"title"] forKey:@"title"];
    }
    if(options[@"description"] != NULL){
        [templateArgs setObject:options[@"description"] forKey:@"description"];
    }
    
    // 카카오링크 실행
    [[KLKTalkLinkCenter sharedCenter] sendCustomWithTemplateId:templateId templateArgs:templateArgs success:^(NSDictionary<NSString *,NSString *> * _Nullable warningMsg, NSDictionary<NSString *,NSString *> * _Nullable argumentMsg) {
        
        // 성공
        NSLog(@"warning message: %@", warningMsg);
        NSLog(@"argument message: %@", argumentMsg);
        CDVPluginResult* pluginResult = pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:@"success!"];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
        
    } failure:^(NSError * _Nonnull error) {
        [self errorHandler:command.callbackId error:error errorCode:0 errorMessage:nil];
        
    }];
    
}

- (void)sendDefaultWithTemplate:(KMTTemplate*)template command:(CDVInvokedUrlCommand*)command
{
    [[KLKTalkLinkCenter sharedCenter] sendDefaultWithTemplate:template success:^(NSDictionary<NSString *,NSString *> * _Nullable warningMsg, NSDictionary<NSString *,NSString *> * _Nullable argumentMsg) {
        
        // 성공
        NSLog(@"warning message: %@", warningMsg);
        NSLog(@"argument message: %@", argumentMsg);
        CDVPluginResult* pluginResult = pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:@"success!"];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
        
    } failure:^(NSError * _Nonnull error) {
        
        NSLog(@"error: %@", error);
        [self errorHandler:command.callbackId error:error errorCode:0 errorMessage:nil];
        
    }];
}

- (BOOL)addContentsArray:(NSDictionary *)object templateBuilder:(KMTListTemplateBuilder *)templateBuilder {
    if(object == NULL){
        return FALSE;
    }
    NSArray* contents = object;
    if([contents count] < 1){
        return FALSE;
    }
    
    for (int i=0; i<[contents count]; i++) {
        KMTContentObject* feedContentObject = [self getKMTContentObject:contents[i]];
        if(feedContentObject == NULL){
            return FALSE;
        }
        [templateBuilder addContent: feedContentObject];
    }
    return TRUE;
}

- (void)addButtonsArray:(NSDictionary *)object templateBuilder:(NSObject *)templateBuilder {
    if(object == NULL){
        return;
    }
    NSArray* buttons = object;
    if([buttons count] < 1){
        return;
    }
    
    for (int i=0; i<[buttons count]; i++) {
        KMTButtonObject* feedButtonObject = [self getKMTButtonObject:buttons[i]];
        if(feedButtonObject != NULL){
            if ([templateBuilder isKindOfClass:[KMTFeedTemplateBuilder class]]){
                [((KMTFeedTemplateBuilder*)templateBuilder) addButton: feedButtonObject];
            }else if ([templateBuilder isKindOfClass:[KMTListTemplateBuilder class]]){
                [((KMTListTemplateBuilder*)templateBuilder) addButton: feedButtonObject];
            }else if ([templateBuilder isKindOfClass:[KMTCommerceTemplateBuilder class]]){
                [((KMTCommerceTemplateBuilder*)templateBuilder) addButton: feedButtonObject];
            }else if ([templateBuilder isKindOfClass:[KMTLocationTemplateBuilder class]]){
                [((KMTLocationTemplateBuilder*)templateBuilder) addButton: feedButtonObject];
            }else if ([templateBuilder isKindOfClass:[KMTTextTemplateBuilder class]]){
                [((KMTTextTemplateBuilder*)templateBuilder) addButton: feedButtonObject];
            }
        }
    }
}

- (KMTContentObject *)getKMTContentObject:(NSDictionary *)object {
    if(object == NULL){
        return NULL;
    }
    KMTLinkObject* linkObject = [self getKMTLinkObject:object[@"link"]];
    if(object[@"title"] == NULL ||
       linkObject == NULL ||
       object[@"imageURL"] == NULL){
        return NULL;
    }
    return [KMTContentObject contentObjectWithBuilderBlock:^(KMTContentBuilder * _Nonnull contentBuilder) {
        contentBuilder.title = object[@"title"];
        contentBuilder.link = linkObject;
        contentBuilder.imageURL = [NSURL URLWithString:object[@"imageURL"]];
        
        NSString *desc = object[@"desc"];
        NSString *imageWidth = object[@"imageWidth"];
        NSString *imageHeight = object[@"imageHeight"];
        
        if(desc != NULL){
            contentBuilder.desc = desc;
        }
        if(imageWidth != NULL){
            contentBuilder.imageWidth = [NSNumber numberWithInt:[imageWidth intValue]];
        }
        if(imageHeight != NULL){
            contentBuilder.imageHeight = [NSNumber numberWithInt:[imageHeight intValue]];
        }
    }];
}

- (KMTCommerceObject *)getKMTCommerceObject:(NSDictionary *)object {
    if(object == NULL){
        return NULL;
    }
    NSString *regularPrice = object[@"regularPrice"];
    if(regularPrice == NULL){
        return NULL;
    }
    return [KMTCommerceObject commerceObjectWithBuilderBlock:^(KMTCommerceBuilder * _Nonnull commerceBuilder) {
        NSString *discountPrice = object[@"discountPrice"];
        NSString *discountRate = object[@"discountRate"];
        NSString *fixedDiscountPrice = object[@"fixedDiscountPrice"];
        
        commerceBuilder.regularPrice = [NSNumber numberWithInt:[regularPrice intValue]];
        
        if(discountPrice != NULL){
            commerceBuilder.discountPrice = [NSNumber numberWithInt:[discountPrice intValue]];
        }
        if(discountRate != NULL){
            commerceBuilder.discountRate = [NSNumber numberWithInt:[discountRate intValue]];
        }
        if(fixedDiscountPrice != NULL){
            commerceBuilder.fixedDiscountPrice = [NSNumber numberWithInt:[fixedDiscountPrice intValue]];
        }
    }];
}

- (KMTSocialObject *)getKMTSocialObject:(NSDictionary *)object {
    if(object == NULL){
        return NULL;
    }
    return [KMTSocialObject socialObjectWithBuilderBlock:^(KMTSocialBuilder * _Nonnull socialBuilder) {
        NSString *likeCount = object[@"likeCount"];
        NSString *commnentCount = object[@"commnentCount"];
        NSString *sharedCount = object[@"sharedCount"];
        NSString *viewCount = object[@"viewCount"];
        NSString *subscriberCount = object[@"subscriberCount"];
        if(likeCount != NULL){
            socialBuilder.likeCount = [NSNumber numberWithInt:[likeCount intValue]];
        }
        if(commnentCount != NULL){
            socialBuilder.commnentCount = [NSNumber numberWithInt:[commnentCount intValue]];
        }
        if(sharedCount != NULL){
            socialBuilder.sharedCount = [NSNumber numberWithInt:[sharedCount intValue]];
        }
        if(viewCount != NULL){
            socialBuilder.viewCount = [NSNumber numberWithInt:[viewCount intValue]];
        }
        if(subscriberCount != NULL){
            socialBuilder.subscriberCount = [NSNumber numberWithInt:[subscriberCount intValue]];
        }
    }];
}


- (KMTButtonObject *)getKMTButtonObject:(NSDictionary *)object {
    if(object == NULL){
        return NULL;
    }
    return [KMTButtonObject buttonObjectWithBuilderBlock:^(KMTButtonBuilder * _Nonnull buttonBuilder) {
        buttonBuilder.title = object[@"title"];
        KMTLinkObject* linkObject = [self getKMTLinkObject:object[@"link"]];
        if(linkObject != NULL){
            buttonBuilder.link = linkObject;
        }
    }];
}

- (KMTLinkObject *)getKMTLinkObject:(NSDictionary *)object {
    if(object == NULL){
        return NULL;
    }
    return [KMTLinkObject linkObjectWithBuilderBlock:^(KMTLinkBuilder * _Nonnull linkBuilder) {
        NSString *webURL = object[@"webURL"];
        NSString *mobileWebURL = object[@"mobileWebURL"];
        NSString *androidExecutionParams = object[@"androidExecutionParams"];
        NSString *iosExecutionParams = object[@"iosExecutionParams"];
        if(webURL != NULL){
            linkBuilder.webURL = [NSURL URLWithString:webURL];
        }
        if(mobileWebURL != NULL){
            linkBuilder.mobileWebURL = [NSURL URLWithString:mobileWebURL];
        }
        if(androidExecutionParams != NULL){
            linkBuilder.androidExecutionParams = androidExecutionParams;
        }
        if(iosExecutionParams != NULL){
            linkBuilder.iosExecutionParams = iosExecutionParams;
        }
    }];
}

- (void)uploadImage:(CDVInvokedUrlCommand*)command
{
    NSMutableDictionary *options = [[command.arguments lastObject] mutableCopy];
    NSLog(@"%@", options);
    self.callbackId = command.callbackId;
    if(options[@"fileOrUrl"] == NULL){
        [self uploadLocalImage];
        return;
    }
    if([options[@"fileOrUrl"] isEqualToString:@"file"]){
        [self uploadLocalImage];
    }else if([options[@"fileOrUrl"] isEqualToString:@"url"]){
        if(options[@"url"] == NULL){
            [self errorHandler:command.callbackId error:NULL errorCode:0 errorMessage:@"url is null."];
            return;
        }
        [self scrapRemoteImage:options[@"url"]];
        
    }else{
        [self uploadLocalImage];
    }
    
}

- (void)deleteUploadedImage:(CDVInvokedUrlCommand*)command
{
    NSMutableDictionary *options = [[command.arguments lastObject] mutableCopy];
    NSLog(@"%@", options);
    
    if(options[@"url"] == NULL){
        [self errorHandler:command.callbackId error:NULL errorCode:0 errorMessage:@"url is null."];
        return;
    }
    if([[options[@"url"] stringByTrimmingCharactersInSet:
         [NSCharacterSet whitespaceAndNewlineCharacterSet]] isEqualToString:@""]){
        [self errorHandler:command.callbackId error:NULL errorCode:0 errorMessage:@"url is null."];
        return;
    }
    NSURL *imageURL = [NSURL URLWithString:options[@"url"]];
    [[KLKImageStorage sharedStorage] deleteWithImageURL:imageURL success:^{
        // 삭제 성공
        CDVPluginResult* pluginResult = pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:@"success!"];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    } failure:^(NSError * _Nonnull error) {
        // 삭제 실패
        [self errorHandler:command.callbackId error:error errorCode:0 errorMessage:nil];
        
    }];
    
    
}

- (void)uploadLocalImage
{
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.delegate = self;
    picker.sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
    [self.viewController presentViewController:picker animated:YES completion:nil];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info {
    [picker dismissViewControllerAnimated:YES completion:nil];
    
    // 업로드할 이미지
    UIImage *sourceImage = info[UIImagePickerControllerOriginalImage];
    
    [[KLKImageStorage sharedStorage] uploadWithImage:sourceImage success:^(KLKImageInfo * _Nonnull original) {
        
        CDVPluginResult* pluginResult = pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:[original.URL absoluteString]];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:self.callbackId];
    } failure:^(NSError * _Nonnull error) {
        [self errorHandler:self.callbackId error:error errorCode:0 errorMessage:nil];
        
    }];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [picker dismissViewControllerAnimated:YES completion:nil];
}

- (void)scrapRemoteImage:(NSString*)url
{
    
    // 원격지 이미지 URL
    NSURL *imageURL = [NSURL URLWithString:url];
    
    [[KLKImageStorage sharedStorage] scrapWithImageURL:imageURL success:^(KLKImageInfo * _Nonnull original) {
        
        CDVPluginResult* pluginResult = pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:[original.URL absoluteString]];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:self.callbackId];
    } failure:^(NSError * _Nonnull error) {
        [self errorHandler:self.callbackId error:error errorCode:0 errorMessage:nil];
        
    }];
}

- (void)postStory:(CDVInvokedUrlCommand*)command
{
    
    NSMutableDictionary *options = [[command.arguments lastObject] mutableCopy];
    NSLog(@"%@", options);
    
    if (![KakaoCordovaStoryLinkHelper canOpenStoryLink]) {
        NSLog(@"Cannot open kakao story.");
        [self errorHandler:command.callbackId error:NULL errorCode:0 errorMessage:@"Cannot open kakao story."];
        return;
    }
    if(options[@"post"] == NULL || options[@"appver"] == NULL ){
        [self errorHandler:command.callbackId error:NULL errorCode:0 errorMessage:@"post or appver is null."];
        return;
    }
    NSString* post = options[@"post"];
    NSString* appver = options[@"appver"];
    NSBundle *bundle = [NSBundle mainBundle];
    NSString* appid = [bundle bundleIdentifier];
    if(options[@"appid"] != NULL){
        appid = options[@"appid"] ;
    }
    NSString* appname = [bundle objectForInfoDictionaryKey:@"CFBundleName"];
    if(options[@"appname"] != NULL){
        appname = options[@"appname"] ;
    }
    ScrapInfo *scrapInfo = nil;
    if(options[@"urlinfo"] != NULL){
        scrapInfo = [[ScrapInfo alloc] init];
        NSString* title = (options[@"urlinfo"])[@"title"];
        NSString* desc = (options[@"urlinfo"])[@"desc"];
        NSArray* imageURLs = (options[@"urlinfo"])[@"imageURLs"];
        NSString* type = (options[@"urlinfo"])[@"type"];
        
        if(title == NULL){
            [self errorHandler:command.callbackId error:NULL errorCode:0 errorMessage:@"title in urlinfo is null."];
            return;
        }
        scrapInfo.title = title;
        if(desc != NULL){
            scrapInfo.desc = desc;
        }
        if(imageURLs != NULL){
            scrapInfo.imageURLs = imageURLs;
        }
        if(type != NULL){
            switch ([type intValue]) {
                case 2:
                    scrapInfo.type = ScrapTypeVideo;
                    break;
                case 3:
                    scrapInfo.type = ScrapTypeMusic;
                    break;
                case 4:
                    scrapInfo.type = ScrapTypeBook;
                    break;
                case 5:
                    scrapInfo.type = ScrapTypeArticle;
                    break;
                case 6:
                    scrapInfo.type = ScrapTypeProfile;
                    break;
                default:
                    scrapInfo.type = ScrapTypeWebsite;
                    break;
            }
            
        }
    }
    
    
    NSString *storyLinkURLString = [KakaoCordovaStoryLinkHelper makeStoryLinkWithPostingText:post
                                                                                 appBundleID:appid
                                                                                  appVersion:appver
                                                                                     appName:appname
                                                                                   scrapInfo:scrapInfo];
    if([KakaoCordovaStoryLinkHelper openStoryLinkWithURLString:storyLinkURLString]){
        CDVPluginResult* pluginResult = pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:@"success!"];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    }else{
        [self errorHandler:command.callbackId error:NULL errorCode:0 errorMessage:@"something went wrong."];
    }
}


- (void)errorHandler:(NSString*)callbackId error:(NSError*)error errorCode:(NSInteger)errorCode errorMessage:(NSString*)errorMessage {
    
    NSInteger _errorCode = -777;
    NSString* _errorMessage = @"";
    NSString* _domain = @"";
    
    if(error == NULL){
        if(errorCode != 0){
            _errorCode = errorCode;
        }
        _errorMessage = errorMessage;
    }else{
        _errorCode = [error code];
        _errorMessage = [error localizedDescription];
        _domain = [error domain];
    }
    
    NSDictionary *extraErrorDic = @{@"domain": _domain};
    NSDictionary *errorDic = @{@"osType": @"ios",
                               @"errorCode": @(_errorCode),
                               @"errorMessage": _errorMessage,
                               @"extra":extraErrorDic
                               };
    
    CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsDictionary:errorDic];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:callbackId];
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
    
    if ([[KLKTalkLinkCenter sharedCenter] isTalkLinkCallback:url]) {
        NSString *params = url.query;
        NSLog(@"%@", params);
    }
}

- (void)applicationDidBecomeActive {
    [KOSession handleDidBecomeActive];
}

@end




