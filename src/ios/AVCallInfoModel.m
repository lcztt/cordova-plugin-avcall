//
//  AVCallInfoModel.m
//  Solution
//
//  Created by 仇啟飞 on 2018/9/4.
//  Copyright © 2018年 Solution. All rights reserved.
//

#import "AVCallInfoModel.h"

@implementation AVCallInfoModel

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.screen_interval = 60;
        self.heart_interval = 30;
    }
    return self;
}

- (BOOL)is_admin
{
    return self.self_uid != self.start_uid && self.receive_uid != self.self_uid;
}

- (BOOL)is_self_start
{
    return self.start_uid == self.self_uid;
}

- (NSInteger)local_uid
{
    if (self.is_admin) {
        return self.start_uid;
    } else {
        return self.self_uid;
    }
}

- (NSInteger)remote_uid
{
    if (self.is_admin) {
        return self.receive_uid;
    } else {
        if (self.start_uid == self.self_uid) {
            return self.receive_uid;
        } else {
            return self.start_uid;
        }
    }
}

@end
