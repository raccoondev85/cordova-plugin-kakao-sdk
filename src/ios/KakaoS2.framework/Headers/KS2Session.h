/**
 * Copyright 2016-2017 Kakao Corp.
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
 @header KS2Session.h
 S2 이벤트 로깅 기능을 제공합니다.
 */

#import <Foundation/Foundation.h>

@class KS2Event;

/*
 @typedef   KS2PublishCompletion
 @abstract  S2 이벤트 전송 완료 시 호출되는 콜백 메소드.
 @param error   오류 정보.
 @param count   전송에 성공한 이벤트 개수.
 */
typedef void(^KS2PublishCompletion)(NSError *error, NSInteger count);

/*
 @class         KS2Session
 @abstract      S2 API 세션 관리 클래스.
 @discussion    S2 이벤트 로깅 기능을 제공합니다. 일괄전송방식을 지원합니다.
 */
@interface KS2Session : NSObject

/*
 @property  defaultPublishCompletion
 @abstract  현재 세션에서 공통으로 사용되는 이벤트 전송 완료 콜백.
 */
@property (copy, nonatomic) KS2PublishCompletion defaultPublishCompletion;

/*
 @abstract  현재 session 정보.
 */
+ (instancetype)sharedSession;

/*
 @abstract  현재 세션의 이벤트 큐에 이벤트를 추가한다. 일정시간이 지나면 큐에 있는 이벤트를 일괄전송 한다.
 @param event   이벤트 큐에 추가할 KS2Event 객체.
 @result YES    이벤트 추가 성공.
         NO     필수 파라미터가 nil 또는 빈 값일 경우 이벤트 추가에 실패 함.
 */
- (BOOL)addEvent:(KS2Event *)event;

/*
 @abstract  인자로 넘어온 이벤트의 from값에 상관없이 Adid를 대입하여 이벤트를 추가한다. 일정시간이 지나면 큐에 있는 이벤트를 일괄전송 한다.
 @param event   이벤트 큐에 추가할 KS2Event 객체.
 @result YES    이벤트 추가 성공.
         NO     필수 파라미터가 nil 또는 빈 값일 경우 이벤트 추가에 실패 함.
 */
- (BOOL)addAdidEvent:(KS2Event *)event;

/*
 @abstract  현재 큐에 쌓여있는 이벤트를 서버로 강제 전송한다. defaultPublishCompletion이 호출 됨.
 */
- (void)publish;

/*
 @abstract  현재 큐에 쌓여있는 이벤트를 서버로 강제 전송한다.
 @param completion  전송 완료 콜백.
 */
- (void)publishWithCompletion:(KS2PublishCompletion)completion;

@end
