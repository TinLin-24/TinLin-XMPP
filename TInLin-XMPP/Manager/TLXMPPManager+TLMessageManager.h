//
//  TLXMPPManager+TLMessageManager.h
//  TinLin-XMPP
//
//  Created by Mac on 2018/12/25.
//  Copyright © 2018 xinchenglong. All rights reserved.
//

#import "TLXMPPManager.h"

@class XMPPMessageArchiving_Message_CoreDataObject;

@class XMPPRoomMessageCoreDataStorageObject;

@interface TLXMPPManager (TLMessageManager)

- (NSArray<XMPPMessageArchiving_Message_CoreDataObject *> *)fetchChatHistoryWithBareJidStr:(NSString *)bareJidStr;

- (NSArray<XMPPRoomMessageCoreDataStorageObject *> *)fetchGroupChatHistoryWithRoomJidStr:(NSString *)roomJidStr;

@end
