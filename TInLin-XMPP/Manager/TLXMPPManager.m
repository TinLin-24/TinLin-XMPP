//
//  TLXMPPManager.m
//  TinLin-XMPP
//
//  Created by Mac on 2018/12/18.
//  Copyright © 2018 xinchenglong. All rights reserved.
//

#import "TLXMPPManager.h"

#import <JSQMessage.h>

static TLXMPPManager *_manager;

@interface TLXMPPManager()<XMPPStreamDelegate,XMPPRosterDelegate,XMPPRosterMemoryStorageDelegate,XMPPMUCDelegate,XMPPIncomingFileTransferDelegate,XMPPOutgoingFileTransferDelegate>

//
@property (nonatomic, assign)BOOL xmppNeedRegister;
//
@property (nonatomic, copy)NSString *password;

@end

@implementation TLXMPPManager

+ (instancetype)manager {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (!_manager) {
            _manager = [[TLXMPPManager alloc] init];
        }
    });
    return _manager;
}

#pragma mark - Public -> Login & Register & Quit

- (void)quit {
    //断开所有连接
    [_xmppStream disconnect];
    //发送一个下线请求给服务器
    XMPPPresence *presence = [XMPPPresence presenceWithType:@"unavailable"];
    [_xmppStream sendElement:presence];
}

- (void)loginWithJID:(XMPPJID *)JID andPassword:(NSString *)password {
    // 1.建立TCP连接
    // 2.把我自己的jid与这个TCP连接绑定起来
    // 3.认证（登录：验证jid与密码是否正确，加密方式 不可能以明文发送）--（出席：怎样告诉服务器我上线，以及我得上线状态
    //这句话会在xmppStream以后发送XML的时候加上 <message from="JID">
    [self.xmppStream setMyJID:JID];
    self.password = password;
    self.xmppNeedRegister = NO;
    if (self.xmppStream.isConnected) {
        [self.xmppStream authenticateWithPassword:password error:nil];
    } else {
        [self.xmppStream connectWithTimeout:XMPPStreamTimeoutNone error:nil];
    }
}

- (void)registerWithJID:(XMPPJID *)JID andPassword:(NSString *)password {
    //注册方法里没有调用auth方法
    [self.xmppStream setMyJID:JID];
    self.password = password;
    self.xmppNeedRegister = YES;
    if (self.xmppStream.isConnected) {
        NSError *error = nil;
        [self.xmppStream registerWithPassword:password error:&error];
        [[NSNotificationCenter defaultCenter] postNotificationName:kREGIST_RESULT object:error];
    } else {
        [self.xmppStream connectWithTimeout:XMPPStreamTimeoutNone error:nil];
    }
}

#pragma mark - XMPPStreamDelegate

// 连接建立成功的代理方法
- (void)xmppStream:(XMPPStream *)sender socketDidConnect:(GCDAsyncSocket *)socket {
    TLLogFunc;
}

// 这个是XML流初始化成功
- (void)xmppStreamDidConnect:(XMPPStream *)sender {
    NSString *password = self.password;
    if (self.xmppNeedRegister) {
        NSError *error = nil;
        [self.xmppStream registerWithPassword:password error:&error];
        [[NSNotificationCenter defaultCenter] postNotificationName:kREGIST_RESULT object:error];
    } else {
        [self.xmppStream authenticateWithPassword:password error:nil];
    }
}

// 与服务器断开连接
- (void)xmppStreamDidDisconnect:(XMPPStream *)sender withError:(NSError *)error {
    TLLogFunc;
}

// 授权(登录)成功的代理方法
- (void)xmppStreamDidAuthenticate:(XMPPStream *)sender {
    TLLogFunc;
    [TLNotificationDefaultCenter postNotificationName:kLOGIN_RESULT object:nil];

    // 发送一个<presence/> 默认值avaliable 在线 是指服务器收到空的presence 会认为是这个
    // status ---自定义的内容，可以是任何的。
    // show 是固定的，有几种类型 dnd、xa、away、chat，在方法XMPPPresence 的intShow中可以看到
    XMPPPresence *presence = [XMPPPresence presence];
    [presence addChild:[DDXMLNode elementWithName:@"status" stringValue:@"我现在很忙"]];
    //[presence addChild:[DDXMLNode elementWithName:@"show" stringValue:@"xa"]];
//    [presence addChild:[DDXMLNode elementWithName:@"show" stringValue:@"chat"]];
    [self.xmppStream sendElement:presence];
}

// 授权(登录)失败的代理方法
- (void)xmppStream:(XMPPStream *)sender didNotAuthenticate:(DDXMLElement *)error {
    TLLogFunc;
    [TLNotificationDefaultCenter postNotificationName:kLOGIN_RESULT object:error];
}

// 注册成功的代理方法
- (void)xmppStreamDidRegister:(XMPPStream *)sender {
    
}

// 注册失败的代理方法
- (void)xmppStream:(XMPPStream *)sender didNotRegister:(DDXMLElement *)error {
    
}

#pragma mark - Getter

- (XMPPStream *)xmppStream {
    if (!_xmppStream) {
        _xmppStream = [[XMPPStream alloc] init];
        
        // socket 连接的时候 要知道host port 然后connect
        [_xmppStream setHostName:kXMPP_HOST];
        [_xmppStream setHostPort:kXMPP_PORT];
        
        // 为什么是addDelegate? 因为XMPPFramework 大量使用了多播代理multicast-delegate ,代理一般是1对1的，但是这个多播代理是一对多得，而且可以在任意时候添加或者删除
        [_xmppStream addDelegate:self delegateQueue:dispatch_get_main_queue()];
        
        /* 添加功能模块 */
        
        // 1.autoPing 发送的时一个stream:ping 对方如果想表示自己是活跃的，应该返回一个pong
        _xmppAutoPing = [[XMPPAutoPing alloc] init];
        //所有的Module模块，都要激活active
        [_xmppAutoPing activate:_xmppStream];
        //autoPing由于它会定时发送ping,要求对方返回pong,因此这个时间我们需要设置
        [_xmppAutoPing setPingInterval:1000];
        //不仅仅是服务器来得响应;如果是普通的用户，一样会响应
        [_xmppAutoPing setRespondsToQueries:YES];
        //这个过程是C---->S  ;观察 S--->C(需要在服务器设置）
        
        // 2.autoReconnect 自动重连，当我们被断开了，自动重新连接上去，并且将上一次的信息自动加上去
        _xmppReconnect = [[XMPPReconnect alloc] init];
        [_xmppReconnect activate:_xmppStream];
        [_xmppReconnect setAutoReconnect:YES];
        
        // 3.好友模块 支持我们管理、同步、申请、删除好友
        _xmppRosterMemoryStorage = [[XMPPRosterMemoryStorage alloc] init];
        _xmppRoster = [[XMPPRoster alloc] initWithRosterStorage:_xmppRosterMemoryStorage];
        [_xmppRoster activate:_xmppStream];
        // 同时给_xmppRosterMemoryStorage 和 _xmppRoster都添加了代理
        [_xmppRoster addDelegate:self delegateQueue:dispatch_get_main_queue()];
        // 设置好友同步策略,XMPP一旦连接成功，同步好友到本地
        [_xmppRoster setAutoFetchRoster:YES]; //自动同步，从服务器取出好友
        // 关掉自动接收好友请求，默认开启自动同意
        [_xmppRoster setAutoAcceptKnownPresenceSubscriptionRequests:NO];
        
        _xmppRosterStorage = [[XMPPRosterCoreDataStorage alloc] init];
        _xmppCoreDataRoster = [[XMPPRoster alloc] initWithRosterStorage:_xmppRosterStorage];
        _xmppCoreDataRoster.autoFetchRoster = YES;
        _xmppCoreDataRoster.autoAcceptKnownPresenceSubscriptionRequests = YES;
        [_xmppCoreDataRoster activate:_xmppStream];
        
        // 4.消息模块，这里用单例，不能切换账号登录，否则会出现数据问题。
        _xmppMessageArchivingCoreDataStorage = [XMPPMessageArchivingCoreDataStorage sharedInstance];
        _xmppMessageArchiving = [[XMPPMessageArchiving alloc] initWithMessageArchivingStorage:_xmppMessageArchivingCoreDataStorage dispatchQueue:dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 9)];
        [_xmppMessageArchiving activate:_xmppStream];
        
        // 5、文件接收
        _xmppIncomingFileTransfer = [[XMPPIncomingFileTransfer alloc] initWithDispatchQueue:dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0)];
        [_xmppIncomingFileTransfer activate:_xmppStream];
        [_xmppIncomingFileTransfer addDelegate:self delegateQueue:dispatch_get_main_queue()];
        [_xmppIncomingFileTransfer setAutoAcceptFileTransfers:NO];
        
        _xmppOutgoingFileTransfer = [[XMPPOutgoingFileTransfer alloc] initWithDispatchQueue:dispatch_get_global_queue(0, 0)];
        [_xmppOutgoingFileTransfer activate:_xmppStream];
        [_xmppOutgoingFileTransfer addDelegate:self delegateQueue:dispatch_get_main_queue()];
        
        // 6、聊天室
        _xmppMUC = [[XMPPMUC alloc] init];
        [_xmppMUC addDelegate:self delegateQueue:dispatch_get_main_queue()];
        [_xmppMUC activate:_xmppStream];
    }
    return _xmppStream;
}

/// TinLin

- (UIImage *)avatarImage {
    if (_avatarImage) {
        return _avatarImage;
    }
    return [UIImage imageNamed:@"demo_avatar"];
}

- (NSMutableDictionary *)xmppRoomCoreDataStorageDict {
    if (!_xmppRoomCoreDataStorageDict) {
        _xmppRoomCoreDataStorageDict = [NSMutableDictionary dictionary];
    }
    return _xmppRoomCoreDataStorageDict;
}

@end
