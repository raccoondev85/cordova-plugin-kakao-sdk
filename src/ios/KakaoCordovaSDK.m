/**
 * Copyright 2015-2018 Kakao Corp.
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

#import "UserMgmtViewController.h"
#import "UIAlertController+Addition.h"
#import "UserMgmtTableViewCell.h"
#import "IconTableViewCell.h"
#import "ProfileImageViewController.h"
#import <KakaoOpenSDK/KakaoOpenSDK.h>

@interface UserMgmtViewController () <UITableViewDelegate, UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (assign, nonatomic) BOOL doneSignup;
@property (strong, nonatomic) KOUserMe *me;

@end

@implementation UserMgmtViewController {
    NSArray *_menu;
    NSArray *_menuBeforeSignup;
    UITapGestureRecognizer *_singleTapGesture;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _menu = @[@"me", @"업데이트 프로필", @"Unlink", @"톡 프로필 보기"];
    _menuBeforeSignup = @[@"Signup"];
    
    _singleTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(profileImageTapped:)];
    _singleTapGesture.numberOfTapsRequired = 1;
    _singleTapGesture.numberOfTouchesRequired = 1;
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.tableFooterView = [[UIView alloc] init];
    
    UINib *nib = [UINib nibWithNibName:@"UserMgmtTableViewCell" bundle:nil];
    [self.tableView registerNib:nib forCellReuseIdentifier:@"UserMgmtTableViewCell"];
    
    [self requestMe:NO];
}

- (void)requestMe:(BOOL)displayResult {
    
    // 사용자 정보 요청
    [KOSessionTask userMeTaskWithCompletion:^(NSError *error, KOUserMe *me) {
        if (error) {
            [UIAlertController showMessage:error.description];
            
        } else {
            if (displayResult) {
                
                
                // 결과 보여주기
                NSMutableString *message = [NSMutableString string];
                
                [message appendString:@"아이디: "];
                [message appendString:me.ID ? me.ID : @"없음 (signup 필요)"];
                
                if (me.account) {
                    [message appendString:@"\n\n== 카카오계정 정보 =="];
                    
                    [message appendString:@"\n이메일: "];
                    if (me.account.email) {
                        [message appendString:me.account.email];
                    } else if (me.account.hasEmail == KOOptionalBooleanTrue) {
                        [message appendString:@"있음 (사용자 동의가 필요함)"];
                    } else {
                        [message appendString:@"없음"];
                    }
                    
                    [message appendString:@"\n전화번호: "];
                    if (me.account.phoneNumber) {
                        [message appendString:me.account.phoneNumber];
                    } else if (me.account.hasPhoneNumber == KOOptionalBooleanTrue) {
                        [message appendString:@"있음 (사용자 동의가 필요함)"];
                    } else if (me.account.hasPhoneNumber == KOOptionalBooleanFalse) {
                        [message appendString:@"없음"];
                    } else if (me.account.hasPhoneNumber == KOOptionalBooleanNull) {
                        [message appendString:@"없음 (앱 권한이 필요함)"];
                    }
                    
                    [message appendString:@"\n\n연령대: "];
                    switch (me.account.ageRange) {
                        case KOUserAgeRangeNull:
                            if (me.account.hasAgeRange == KOOptionalBooleanTrue) {
                                [message appendString:@"없음 (사용자 동의가 필요함)"];
                            } else {
                                [message appendString:@"없음"];
                            }
                            break;
                        case KOUserAgeRangeType15:  [message appendString:@"15세~19세"];   break;
                        case KOUserAgeRangeType20:  [message appendString:@"20세~29세"];   break;
                        case KOUserAgeRangeType30:  [message appendString:@"30세~39세"];   break;
                        case KOUserAgeRangeType40:  [message appendString:@"40세~49세"];   break;
                        case KOUserAgeRangeType50:  [message appendString:@"50세~59세"];   break;
                        case KOUserAgeRangeType60:  [message appendString:@"60세~69세"];   break;
                        case KOUserAgeRangeType70:  [message appendString:@"70세~79세"];   break;
                        case KOUserAgeRangeType80:  [message appendString:@"80세~89세"];   break;
                        case KOUserAgeRangeType90:  [message appendString:@"90세 이상"];   break;
                    }
                    
                    [message appendString:@"\n생일: "];
                    if (me.account.birthday) {
                        [message appendString:me.account.birthday];
                    } else if (me.account.hasBirthday == KOOptionalBooleanTrue) {
                        [message appendString:@"없음 (사용자 동의가 필요함)"];
                    } else {
                        [message appendString:@"없음"];
                    }
                    
                    [message appendString:@"\n성별: "];
                    switch (me.account.gender) {
                        case KOUserGenderNull:
                            if (me.account.hasGender == KOOptionalBooleanTrue) {
                                [message appendString:@"없음 (사용자 동의가 필요함)"];
                            } else {
                                [message appendString:@"없음"];
                            }
                            break;
                        case KOUserGenderMale:      [message appendString:@"남자"];    break;
                        case KOUserGenderFemale:    [message appendString:@"여자"];    break;
                    }
                }
                
                if (me.properties) {
                    [message appendFormat:@"\n\n== 사용자 속성 ==\n%@", me.properties];
                }
                
                
                
                // 사용자 동의를 받지 않은 개인정보 확인
                // 필요한 경우에 동의를 받고 재요청하여 정보를 획득
                // 개발자사이트 사용자관리 설정 페이지에서 획득하고자 하는 개인정보에 해당하는 동의항목을 사용하도록 설정해야 함
                NSMutableArray *needsAllScopes = [NSMutableArray array];
                NSMutableArray *actions = [NSMutableArray array];
                
                if ([me.account needsScopeAccountEmail]) {
                    [needsAllScopes addObject:@"account_email"];
                    [actions addObject:[UIAlertAction actionWithTitle:@"이메일 제공 동의 받기" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                        [self updateScopesAndRetryWithScopes:@[@"account_email"]];
                    }]];
                }
                
                if ([me.account needsScopePhoneNumber]) {
                    [needsAllScopes addObject:@"phone_number"];
                    [actions addObject:[UIAlertAction actionWithTitle:@"전화번호 제공 동의 받기" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                        [self updateScopesAndRetryWithScopes:@[@"phone_number"]];
                    }]];
                }
                
                if ([me.account needsScopeAgeRange]) {
                    [needsAllScopes addObject:@"age_range"];
                    [actions addObject:[UIAlertAction actionWithTitle:@"연령대 제공 동의 받기" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                        [self updateScopesAndRetryWithScopes:@[@"age_range"]];
                    }]];
                }
                
                if ([me.account needsScopeBirthday]) {
                    [needsAllScopes addObject:@"birthday"];
                    [actions addObject:[UIAlertAction actionWithTitle:@"생일 제공 동의 받기" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                        [self updateScopesAndRetryWithScopes:@[@"birthday"]];
                    }]];
                }
                
                if ([me.account needsScopeGender]) {
                    [needsAllScopes addObject:@"gender"];
                    [actions addObject:[UIAlertAction actionWithTitle:@"성별 제공 동의 받기" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                        [self updateScopesAndRetryWithScopes:@[@"gender"]];
                    }]];
                }
                
                if (needsAllScopes.count >= 2) {
                    // 필요한 동의항목 한번에 요청
                    [actions addObject:[UIAlertAction actionWithTitle:@"모두 동의 받기" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                        [self updateScopesAndRetryWithScopes:needsAllScopes];
                    }]];
                }
                
                [actions addObject:[UIAlertAction actionWithTitle:@"확인" style:UIAlertActionStyleCancel handler:nil]];
                [UIAlertController showAlertWithTitle:@"" message:message actions:actions];
            }
            
            self.doneSignup = me.hasSignedUp != KOOptionalBooleanFalse;
            
            self.me = me;
            [self.tableView reloadData];
        }
    }];
}

- (void)updateScopesAndRetryWithScopes:(NSArray *)scopes {
    [[KOSession sharedSession] updateScopes:scopes completionHandler:^(NSError *error) {
        if (error) {
            if (error.code != KOErrorCancelled) {
                [UIAlertController showMessage:error.description];
            }
        } else {
            [self requestMe:YES];
        }
    }];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        return 1;
    } else {
        if (_doneSignup) {
            return _menu.count;
        } else {
            return _menuBeforeSignup.count;
        }
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        UserMgmtTableViewCell *userCell = [tableView dequeueReusableCellWithIdentifier:@"UserMgmtTableViewCell"];
        [userCell setMe:self.me];
        
        BOOL hasGesture = NO;
        for (UIGestureRecognizer *gesture in [userCell.thumbnail gestureRecognizers]) {
            if (gesture == _singleTapGesture) {
                hasGesture = YES;
                break;
            }
        }
        
        if (!hasGesture) {
            [userCell.thumbnail addGestureRecognizer:_singleTapGesture];
            userCell.thumbnail.userInteractionEnabled = YES;
        }
        
        return userCell;
    }
    
    UITableViewCell *normalCell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    if (normalCell == nil) {
        normalCell = [[IconTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Cell"];
    }
    
    normalCell.imageView.image = [UIImage imageNamed:[NSString stringWithFormat:@"UserMenuIcon%d", (int) indexPath.row]];
    if (_doneSignup) {
        normalCell.textLabel.text = _menu[indexPath.row];
    } else {
        normalCell.textLabel.text = _menuBeforeSignup[indexPath.row];
    }
    
    return normalCell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        return 397;
    }
    return 48;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (indexPath.section == 0) {
        return;
    }
    
    if (!_doneSignup) {
        switch (indexPath.row) {
            case 0:
                [KOSessionTask signupTaskWithProperties:[self userFormData] completionHandler:^(BOOL success, NSError *error) {
                    if (error) {
                        [UIAlertController showMessage:error.description];
                    } else {
                        [self requestMe:NO];
                    }
                }];
                break;
        }
    } else {
        switch (indexPath.row) {
            case 0: {
                [self requestMe:YES];
            }
                break;
                
            case 1: {
                [KOSessionTask profileUpdateTaskWithProperties:[self userFormData] completionHandler:^(BOOL success, NSError *error) {
                    if (error) {
                        [UIAlertController showMessage:error.description];
                    } else {
                        [UIAlertController showMessage:@"프로필 업데이트에 성공하셨습니다."];
                    }
                }];
            }
                break;
                
            case 2: {
                [KOSessionTask unlinkTaskWithCompletionHandler:^(BOOL success, NSError *error) {
                    if (error) {
                        [UIAlertController showMessage:error.description];
                    } else {
                        NSLog(@"User unlink is successfully completed!");
                        [self.navigationController popViewControllerAnimated:YES];
                    }
                }];
            }
                break;
                
            case 3: {
                [self performSegueWithIdentifier:@"TalkProfile" sender:self];
            }
                break;
        }
    }
}

- (NSDictionary *)userFormData {
    UserMgmtTableViewCell *userCell = (UserMgmtTableViewCell *) [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
    return [userCell userDictionary];
}

- (void)profileImageTapped:(UITapGestureRecognizer *)recognizer {
    if (!self.me || !self.me.properties[@"profile_image"]) {
        return;
    }
    
    NSString *profileImage = self.me.properties[@"profile_image"];
    if (profileImage.length == 0) {
        return;
    }
    
    [self performSegueWithIdentifier:@"ProfileImage" sender:profileImage];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqualToString:@"ProfileImage"]) {
        ProfileImageViewController *viewController = segue.destinationViewController;
        viewController.profileImageUrlString = sender;
    }
}

@end
