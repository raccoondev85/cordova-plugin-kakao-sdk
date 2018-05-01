/**
 * Copyright 2015-2016 Kakao Corp.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *    http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

#import <Foundation/Foundation.h>


// more information : http://www.kakao.com/services/api/story_link

typedef NS_ENUM(NSInteger, ScrapType) {
    ScrapTypeNone = 0,
    ScrapTypeWebsite,
    ScrapTypeVideo,
    ScrapTypeMusic,
    ScrapTypeBook,
    ScrapTypeArticle,
    ScrapTypeProfile
};

@interface ScrapInfo : NSObject

@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *desc;
@property (nonatomic, copy) NSArray *imageURLs;
@property (nonatomic, assign) ScrapType type;

@end

@interface KakaoCordovaStoryLinkHelper : NSObject

+ (BOOL)canOpenStoryLink;

+ (NSString *)makeStoryLinkWithPostingText:(NSString *)postingText
                               appBundleID:(NSString *)appBundleID
                                appVersion:(NSString *)appVersion
                                   appName:(NSString *)appName
                                 scrapInfo:(ScrapInfo *)scrapInfo;

+ (BOOL)openStoryLinkWithPostingText:(NSString *)postingText
                         appBundleID:(NSString *)appBundleID
                          appVersion:(NSString *)appVersion
                             appName:(NSString *)appName
                           scrapInfo:(ScrapInfo *)scrapInfo;

+ (BOOL)openStoryLinkWithURLString:(NSString *)URLString;

@end
