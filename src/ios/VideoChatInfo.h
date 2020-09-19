//
//  VideoChatInfo.h
//  Solution
//
//  Created by 仇啟飞 on 2018/9/4.
//  Copyright © 2018年 Solution. All rights reserved.
//

#import "AVCallDefines.h"


@interface VideoChatInfo : NSObject

// 声网APPID
@property (nonatomic, copy) NSString *app_id;
@property (nonatomic, copy) NSString *token;
@property (nonatomic, assign) NSInteger room_id;

@property (nonatomic, assign) AVCallType call_type;
/// 默认60秒间隔
@property (nonatomic, assign) NSInteger screen_interval;
/// 默认30秒间隔
@property (nonatomic, assign) NSInteger heart_interval;

@property (nonatomic, assign) NSInteger start_uid;
@property (nonatomic, assign) NSInteger receive_uid;
@property (nonatomic, assign) NSInteger self_uid;

@property (nonatomic, assign, readonly) BOOL is_admin;
@property (nonatomic, assign, readonly) BOOL is_self_start;
@property (nonatomic, assign, readonly) NSInteger local_uid;
@property (nonatomic, assign, readonly) NSInteger remote_uid;

@property (nonatomic, assign) BOOL hidden_view;

@end
