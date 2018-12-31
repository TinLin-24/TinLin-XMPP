//
//  TLXMPPManager.h
//  TinLin-XMPP
//
//  Created by Mac on 2018/12/18.
//  Copyright © 2018 xinchenglong. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TLRosterDelegate.h"
#import "TLMessageDelegate.h"

@interface TLXMPPManager : NSObject

+ (instancetype)manager;

//
@property (nonatomic, strong)XMPPStream *xmppStream;

//
@property (nonatomic, weak, nullable) id <TLRosterDelegate> rosterDelegate;

//
@property (nonatomic, weak, nullable) id <TLMessageDelegate> messageDelegate;

//
@property (nonatomic, weak, nullable) id <TLMessageDelegate> groupMessageDelegate;

//头像
@property (nonatomic,strong)UIImage *avatarImage;

/* 模块 */

//
@property (nonatomic, strong)XMPPAutoPing *xmppAutoPing;

//
@property (nonatomic, strong)XMPPReconnect *xmppReconnect;

//
@property (nonatomic, strong)XMPPRosterMemoryStorage *xmppRosterMemoryStorage;
// 花名册
@property (nonatomic, strong)XMPPRoster *xmppRoster;
// 花名册存储类
@property (nonatomic, strong)XMPPRosterCoreDataStorage *xmppRosterStorage;
//
@property (nonatomic, strong)XMPPRoster *xmppCoreDataRoster;

//
@property (nonatomic, strong)XMPPMessageArchivingCoreDataStorage *xmppMessageArchivingCoreDataStorage;
// 
@property (nonatomic, strong)XMPPMessageArchiving *xmppMessageArchiving;

// 文件
@property (nonatomic, strong, nullable)XMPPJID *incomingFileFromJID;
//
@property (nonatomic, strong)XMPPIncomingFileTransfer *xmppIncomingFileTransfer;
//
@property (nonatomic, strong)XMPPOutgoingFileTransfer *xmppOutgoingFileTransfer;

// 群聊(MUC)
@property (nonatomic, strong)XMPPMUC *xmppMUC;
//
@property (nonatomic, strong)NSMutableDictionary *xmppRoomCoreDataStorageDict;

#pragma mark - Public

- (void)quit;

- (void)loginWithJID:(XMPPJID *)JID andPassword:(NSString *)password;

- (void)registerWithJID:(XMPPJID *)JID andPassword:(NSString *)password;

@end
