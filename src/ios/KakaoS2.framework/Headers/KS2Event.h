/**
 * Copyright 2016-2018 Kakao Corp.
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

/*!
 @header KS2Event.h
 @abstract 클라이언트의 이벤트(로그)를 담고 있는 S2 이벤트 구조체.
 */

#import <Foundation/Foundation.h>

/*!
 @class KS2Event
 @abstract 클라이언트의 이벤트(로그)를 담고 있는 S2 이벤트 구조체.
 */
@interface KS2Event : NSObject <NSCopying, NSCoding>

/*!
 @property time
 @abstract 이벤트 발생 시각.
 */
@property (strong, nonatomic) NSDate *time;

/*!
 @property action
 @abstract 이벤트 설명. 필수 입력.
 */
@property (strong, nonatomic) NSString *action;

/*!
 @property from
 @abstract 이벤트를 발생시킨 주체.
 */
@property (strong, nonatomic) NSString *from;

/*!
 @property to
 @abstract 이벤트 대상. 필수 입력.
 */
@property (strong, nonatomic) NSString *to;

/*!
 @property props
 @abstract 위의 필드 외에 추가하고자 하는 metadata.
 */
@property (strong, nonatomic) NSDictionary<NSString *, id> *props;

@end

@interface KS2Event (Constructor)

+ (instancetype)eventWithAction:(NSString *)action from:(NSString *)from to:(NSString *)to;
+ (instancetype)eventWithAction:(NSString *)action from:(NSString *)from to:(NSString *)to props:(NSDictionary<NSString *, id<NSCoding>> *)props;
+ (instancetype)eventWithAction:(NSString *)action from:(NSString *)from to:(NSString *)to props:(NSDictionary<NSString *, id<NSCoding>> *)props time:(NSDate *)time;
- (instancetype)initWithAction:(NSString *)action from:(NSString *)from to:(NSString *)to;
- (instancetype)initWithAction:(NSString *)action from:(NSString *)from to:(NSString *)to props:(NSDictionary<NSString *, id<NSCoding>> *)props;
- (instancetype)initWithAction:(NSString *)action from:(NSString *)from to:(NSString *)to props:(NSDictionary<NSString *, id<NSCoding>> *)props time:(NSDate *)time;

@end
