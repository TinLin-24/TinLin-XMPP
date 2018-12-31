//
//  TLXMPPManager+TLMUCManager.h
//  TinLin-XMPP
//
//  Created by Mac on 2018/12/24.
//  Copyright © 2018 xinchenglong. All rights reserved.
//

#import "TLXMPPManager.h"

@interface TLXMPPManager (TLMUCManager)

/**
 获取我的群聊
 NSNotificationDefaultCenter监听kXMPP_GET_GROUPS
 */
- (void)fetchMineRoom;

@end
