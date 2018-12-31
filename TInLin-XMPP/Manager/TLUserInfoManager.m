//
//  TLUserInfoManager.m
//  TinLin-XMPP
//
//  Created by Mac on 2018/12/19.
//  Copyright © 2018 xinchenglong. All rights reserved.
//

#import "TLUserInfoManager.h"

static TLUserInfoManager *_manager;

@implementation TLUserInfoManager

+ (instancetype)manager {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (!_manager) {
            _manager = [[TLUserInfoManager alloc] init];
        }
    });
    return _manager;
}

- (NSString *)pass {
    return @"1122";
}

@end
