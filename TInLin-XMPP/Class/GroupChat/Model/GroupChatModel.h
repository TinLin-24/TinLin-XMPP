//
//  GroupChatModel.h
//  TinLin-XMPP
//
//  Created by Mac on 2018/12/24.
//  Copyright © 2018 xinchenglong. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import <JSQMessages.h>

@class XMPPOutgoingFileTransfer;

@interface GroupChatModel : NSObject

//
@property (nonatomic, strong)NSMutableArray *messages;

//
@property (nonatomic, strong, readonly)XMPPJID *roomJID;

//
@property (nonatomic, strong, readonly)XMPPRoom *xmppRoom;

//
@property (nonatomic, strong, readonly)XMPPRoomCoreDataStorage *xmppRoomCoreDataStorage;

//
@property (nonatomic, strong)XMPPOutgoingFileTransfer *xmppOutgoingFileTransfer;

@property (nonatomic, strong, readonly)JSQMessagesBubbleImage *outgoingBubbleImageData;

@property (nonatomic, strong, readonly)JSQMessagesBubbleImage *incomingBubbleImageData;


- (instancetype)initWithRoomJID:(XMPPJID *)roomJID;

- (XMPPRoom *)createRoomWithJID:(XMPPJID *)roomJID;

- (void)leaveRoom;

- (void)destroyRoom;

- (void)fetchGroupChatHistory;

#pragma mark - 发送消息

- (void)sendGroupMessageWithMessageText:(NSString *)text
                               senderId:(NSString *)senderId
                      senderDisplayName:(NSString *)senderDisplayName
                                   date:(NSDate *)date;

- (void)sendPicMessageWithImageData:(NSData *)imageData
              withCompletionHandler:(JSQLocationMediaItemCompletionBlock)completion;

- (void)sendLocationMessageWithLocation:(CLLocation *)location
                  withCompletionHandler:(JSQLocationMediaItemCompletionBlock)completion;

- (void)sendVideoMessageWithFilePath:(NSURL *)path
               withCompletionHandler:(JSQLocationMediaItemCompletionBlock)completion;



@end
