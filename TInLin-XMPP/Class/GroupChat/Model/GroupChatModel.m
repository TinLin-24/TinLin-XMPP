//
//  GroupChatModel.m
//  TinLin-XMPP
//
//  Created by Mac on 2018/12/24.
//  Copyright © 2018 xinchenglong. All rights reserved.
//

#import "GroupChatModel.h"

#import "TLMessageMediaModel.h"

#import "XMPPOutgoingFileTransfer.h"

@interface GroupChatModel ()<XMPPRoomDelegate>

//
@property (nonatomic, strong, readwrite)XMPPRoom *xmppRoom;

//
@property (nonatomic, strong, readwrite)XMPPRoomCoreDataStorage *xmppRoomCoreDataStorage;

@property (nonatomic, strong, readwrite)JSQMessagesBubbleImage *outgoingBubbleImageData;
@property (nonatomic, strong, readwrite)JSQMessagesBubbleImage *incomingBubbleImageData;

@end

@implementation GroupChatModel

- (instancetype)initWithRoomJID:(XMPPJID *)roomJID {
    self = [super init];
    if (self) {
        _roomJID = roomJID;
        
        [self _setup];
    }
    return self;
}

- (void)_setup {
    _xmppRoom = [[XMPPRoom alloc] initWithRoomStorage:self.xmppRoomCoreDataStorage jid:self.roomJID];
    [_xmppRoom addDelegate:self delegateQueue:dispatch_get_main_queue()];
    [_xmppRoom activate:[TLXMPPManager manager].xmppStream];
    
    _xmppOutgoingFileTransfer = [[XMPPOutgoingFileTransfer alloc] initWithDispatchQueue:dispatch_get_global_queue(0, 0)];
    [_xmppOutgoingFileTransfer activate:[TLXMPPManager manager].xmppStream];
    [_xmppOutgoingFileTransfer addDelegate:self delegateQueue:dispatch_get_main_queue()];
    
    JSQMessagesBubbleImageFactory *bubbleFactory = [[JSQMessagesBubbleImageFactory alloc] init];
    
    self.outgoingBubbleImageData = [bubbleFactory outgoingMessagesBubbleImageWithColor:[UIColor jsq_messageBubbleLightGrayColor]];
    self.incomingBubbleImageData = [bubbleFactory incomingMessagesBubbleImageWithColor:[UIColor jsq_messageBubbleGreenColor]];
    
//    if (!self.xmppRoom.isJoined) {
//        [self.xmppRoom joinRoomUsingNickname:[TLXMPPManager manager].xmppStream.myJID.user history:nil];
//    }
}

#pragma mark - Public

- (XMPPRoom *)createRoomWithJID:(XMPPJID *)roomJID {
    XMPPRoom *xmppRoom = [[XMPPRoom alloc] initWithRoomStorage:self.xmppRoomCoreDataStorage jid:roomJID dispatchQueue:dispatch_get_main_queue()];
    
    [xmppRoom activate:[TLXMPPManager manager].xmppStream];
    [xmppRoom addDelegate:self delegateQueue:dispatch_get_main_queue()];
    
    XMPPJID *myJID = [TLXMPPManager manager].xmppStream.myJID;
    [xmppRoom joinRoomUsingNickname:myJID.user history:nil password:nil];
    return xmppRoom;
}

- (void)fetchGroupChatHistory {
    NSArray *historys = [[TLXMPPManager manager] fetchGroupChatHistoryWithRoomJidStr:self.roomJID.bare];
    for (XMPPRoomMessageCoreDataStorageObject *message in historys) {
        NSString *subject = [[message.message elementForName:@"subject"] stringValue];
        TLMessageMediaType type = [subject integerValue];
        
        XMPPJID *jid = [TLXMPPManager manager].xmppStream.myJID;
        
        NSString *senderId = message.isFromMe ? jid.bare : message.jidStr;
        NSString *displayName = message.isFromMe ? jid.user : message.jid.user;
        NSDate *date = message.localTimestamp;
        NSString *body = message.body;
        
        JSQMessage *newMessage;
        
        switch (type) {
            case TLMessageMediaNone:
            {
                newMessage = [self _fetchJSQMessageWithSenderId:senderId
                                                    DisplayName:displayName
                                                           Date:date
                                                           Text:body];
            }
                break;
            default:
            {
                id model = [self _fetchMessageMedia:type
                                           SenderId:senderId
                                               Body:body];
                newMessage = [self _fetchJSQMessageWithSenderId:senderId
                                                    DisplayName:displayName
                                                           Date:date
                                                          Media:model];
            }
                break;
        }
        !newMessage ? : [self.messages addObject:newMessage];
    }
}

- (void)leaveRoom {
    [self.xmppRoom leaveRoom];
}

- (void)destroyRoom {
    [self.xmppRoom destroyRoom];
}

- (void)sendGroupMessageWithMessageText:(NSString *)text
                               senderId:(NSString *)senderId
                      senderDisplayName:(NSString *)senderDisplayName
                                   date:(NSDate *)date {
    XMPPMessage *XMPPmessage = [XMPPMessage messageWithType:@"groupchat" to:self.roomJID];
    [XMPPmessage addBody:text];
    [self.xmppRoom sendMessage:XMPPmessage];
    
    JSQMessage *message = [[JSQMessage alloc] initWithSenderId:senderId
                                             senderDisplayName:senderDisplayName
                                                          date:date
                                                          text:text];
    [self.messages addObject:message];
}

- (void)sendPicMessageWithImageData:(NSData *)imageData
              withCompletionHandler:(JSQLocationMediaItemCompletionBlock)completion {
    XMPPJID *recipient = [XMPPJID jidWithUser:self.roomJID.user domain:bXMPP_domain resource:bXMPP_resource];
    NSError *error;
    [self.xmppOutgoingFileTransfer sendData:imageData named:@"TinLin" toRecipient:recipient description:@"image" error:&error];
    if (!error) {
        UIImage *image = [UIImage imageWithData:imageData];
        JSQPhotoMediaItem *photoItem = [[JSQPhotoMediaItem alloc] initWithImage:image];
        photoItem.appliesMediaViewMaskAsOutgoing = YES;
        JSQMessage *photoMessage = [JSQMessage messageWithSenderId:self.roomJID.bare
                                                       displayName:self.roomJID.user
                                                             media:photoItem];
        [self.messages addObject:photoMessage];
        !completion ? : completion();
    }
}

- (void)sendLocationMessageWithLocation:(CLLocation *)location
                  withCompletionHandler:(JSQLocationMediaItemCompletionBlock)completion {
    NSString *text = [NSString stringWithFormat:@"%f,%f",location.coordinate.latitude,location.coordinate.longitude];
    XMPPMessage *message = [XMPPMessage messageWithType:@"chat" to:self.roomJID];
    [message addSubject:[@(TLMessageMediaLocation) stringValue]];
    [message addBody:text];
    [self.xmppRoom sendMessage:message];
    
    JSQLocationMediaItem *locationItem = [[JSQLocationMediaItem alloc] init];
    [locationItem setLocation:location withCompletionHandler:completion];
    
    JSQMessage *locationMessage = [JSQMessage messageWithSenderId:self.roomJID.bare
                                                      displayName:self.roomJID.user
                                                            media:locationItem];
    [self.messages addObject:locationMessage];
}

- (void)sendVideoMessageWithFilePath:(NSURL *)path
               withCompletionHandler:(JSQLocationMediaItemCompletionBlock)completion {
    
    
    
}

#pragma mark - Private

- (JSQMessage *)_fetchJSQMessageWithSenderId:(NSString *)senderId
                                 DisplayName:(NSString *)displayName
                                        Date:(NSDate *)date
                                        Text:(NSString *)text{
    return [[JSQMessage alloc] initWithSenderId:senderId
                              senderDisplayName:displayName
                                           date:date
                                           text:text];
}

- (JSQMessage *)_fetchJSQMessageWithSenderId:(NSString *)senderId
                                 DisplayName:(NSString *)displayName
                                        Date:(NSDate *)date
                                       Media:(id<JSQMessageMediaData>)media{
    return [[JSQMessage alloc] initWithSenderId:senderId
                              senderDisplayName:displayName
                                           date:date
                                          media:media];
}

- (id<JSQMessageMediaData>)_fetchMessageMedia:(TLMessageMediaType)type
                                     SenderId:(NSString *)senderId
                                         Body:(NSString *)body{
    BOOL outgoing = ![senderId isEqualToString:self.roomJID.bare];
    return [TLMessageMediaModel fetchMediaItemWithType:type Outgoing:outgoing Body:body];
}

#pragma mark - XMPPOutgoingFileTransferDelegate

- (void)xmppOutgoingFileTransferIBBClosed:(XMPPOutgoingFileTransfer *)sender {
    TLLogFunc;
}

- (void)xmppOutgoingFileTransferDidSucceed:(XMPPOutgoingFileTransfer *)sender {
    TLLogFunc;
    // 保存data
    NSString *path = TLDocumentDirectory;
    path = [path stringByAppendingPathComponent:[XMPPStream generateUUID]];
    path = [path stringByAppendingPathExtension:@"png"];
    [sender.outgoingData writeToFile:path atomically:YES];
    
    // 这里将信息保存
    XMPPMessage *message = [XMPPMessage messageWithType:@"groupchat" to:self.roomJID];
    //将这个文件的发送者添加到message的from
    [message addAttributeWithName:@"from" stringValue:[TLXMPPManager manager].xmppStream.myJID.bare];
    [message addSubject:[@(TLMessageMediaPhoto) stringValue]];
    [message addBody:path.lastPathComponent];
    
    // 保存消息记录
    XMPPMessageArchivingCoreDataStorage *xmppMessageArchivingCoreDataStorage = [TLXMPPManager manager].xmppMessageArchivingCoreDataStorage;
    XMPPStream *xmppStream = [TLXMPPManager manager].xmppStream;
    [xmppMessageArchivingCoreDataStorage archiveMessage:message outgoing:YES xmppStream:xmppStream];
}

- (void)xmppOutgoingFileTransfer:(XMPPOutgoingFileTransfer *)sender didFailWithError:(NSError *)error {
    NSLog(@"%@",error);
}

#pragma mark - XMPPRoomDelegate

- (void)xmppRoomDidCreate:(XMPPRoom *)sender {
    TLLogFunc;
}

- (void)xmppRoomDidJoin:(XMPPRoom *)sender {
    [self _setupNewRoom:sender];
    NSString *message = [NSString stringWithFormat:@"群<%@>已创建完成",sender.roomJID.user];
    [MBProgressHUD tl_showTips:message];
    // 邀请
    XMPPJID *jid = [XMPPJID jidWithUser:@"tinlin2" domain:bXMPP_domain resource:bXMPP_resource];
    [sender inviteUser:jid withMessage:@"正大光明"];
}

- (void)xmppRoomDidLeave:(XMPPRoom *)sender {
    TLLogFunc;
}

- (void)xmppRoomDidDestroy:(XMPPRoom *)sender {
    TLLogFunc;
}

- (void)xmppRoom:(XMPPRoom *)sender didFetchConfigurationForm:(NSXMLElement *)configForm {
    NSLog(@"configForm:%@",configForm);
}

// 收到禁止名单列表
- (void)xmppRoom:(XMPPRoom *)sender didFetchBanList:(NSArray *)items {
    TLLogFunc;
}

// 收到成员名单列表
- (void)xmppRoom:(XMPPRoom *)sender didFetchMembersList:(NSArray *)items {
    TLLogFunc;
}

// 收到主持人名单列表
- (void)xmppRoom:(XMPPRoom *)sender didFetchModeratorsList:(NSArray *)items {
    TLLogFunc;
}

- (void)xmppRoom:(XMPPRoom *)sender didNotFetchBanList:(XMPPIQ *)iqError {
    TLLogFunc;
}

- (void)xmppRoom:(XMPPRoom *)sender didNotFetchMembersList:(XMPPIQ *)iqError {
    TLLogFunc;
}

- (void)xmppRoom:(XMPPRoom *)sender didNotFetchModeratorsList:(XMPPIQ *)iqError {
    TLLogFunc;
}

- (void)xmppRoom:(XMPPRoom *)sender didReceiveMessage:(XMPPMessage *)message fromOccupant:(XMPPJID *)occupantJID {
    // 此处为 sender 聊天室内的会话消息
    NSLog(@"");
}

#pragma mark - Private

- (void)_setupNewRoom:(XMPPRoom *)xmppRoom {
    //     <x xmlns='jabber:x:data' type='submit'>
    //       <field var='FORM_TYPE'>
    //         <value>http://jabber.org/protocol/muc#roomconfig</value>
    //       </field>
    //       <field var='muc#roomconfig_roomname'>
    //         <value>A Dark Cave</value>
    //       </field>
    //       <field var='muc#roomconfig_enablelogging'>
    //         <value>0</value>
    //       </field>
    //       ...
    //     </x>
    NSXMLElement *x = [NSXMLElement elementWithName:@"x"xmlns:@"jabber:x:data"];
    [x addAttributeWithName:@"type" stringValue:@"submit"];
    
    NSXMLElement *p = [NSXMLElement elementWithName:@"field" ];
    [p addAttributeWithName:@"var" stringValue:@"FORM_TYPE"];
    [p addChild:[NSXMLElement elementWithName:@"value" stringValue:@"http://jabber.org/protocol/muc#roomconfig"]];
    [x addChild:p];
    
    p = [NSXMLElement elementWithName:@"field"];
    [p addAttributeWithName:@"var"stringValue:@"muc#roomconfig_persistentroom"];//永久房间
    [p addChild:[NSXMLElement elementWithName:@"value" stringValue:@"1"]];
    [x addChild:p];
    
    p = [NSXMLElement elementWithName:@"field"];
    [p addAttributeWithName:@"var"stringValue:@"muc#roomconfig_maxusers"];//最大用户
    [p addChild:[NSXMLElement elementWithName:@"value" stringValue:@"100"]];
    [x addChild:p];
    
    p = [NSXMLElement elementWithName:@"field"];
    [p addAttributeWithName:@"var"stringValue:@"muc#roomconfig_changesubject"];//允许改变主题
    [p addChild:[NSXMLElement elementWithName:@"value" stringValue:@"1"]];
    [x addChild:p];
    
    p = [NSXMLElement elementWithName:@"field"];
    [p addAttributeWithName:@"var"stringValue:@"muc#roomconfig_publicroom"];//公共房间
    [p addChild:[NSXMLElement elementWithName:@"value" stringValue:@"0"]];
    [x addChild:p];
    
    p = [NSXMLElement elementWithName:@"field" ];
    [p addAttributeWithName:@"var"stringValue:@"muc#roomconfig_allowinvites"];//允许邀请
    [p addChild:[NSXMLElement elementWithName:@"value" stringValue:@"1"]];
    [x addChild:p];
    
    [xmppRoom configureRoomUsingOptions:x];
}

#pragma mark - Getter

- (XMPPRoomCoreDataStorage *)xmppRoomCoreDataStorage {
    if (!_xmppRoomCoreDataStorage) {
        NSString *fileName = [NSString stringWithFormat:@"%@.sqlite",self.roomJID.bare];
        NSMutableDictionary *dict = [TLXMPPManager manager].xmppRoomCoreDataStorageDict;
        if ([[dict allKeys] containsObject:fileName]) {
            _xmppRoomCoreDataStorage = [dict valueForKey:fileName];
        }
        else {
            _xmppRoomCoreDataStorage = [[XMPPRoomCoreDataStorage alloc] initWithDatabaseFilename:fileName storeOptions:nil];
            [dict setValue:_xmppRoomCoreDataStorage forKey:fileName];
        }
    }
    return _xmppRoomCoreDataStorage;
}

- (NSMutableArray *)messages {
    if (!_messages) {
        _messages = [NSMutableArray array];
    }
    return _messages;
}

@end
