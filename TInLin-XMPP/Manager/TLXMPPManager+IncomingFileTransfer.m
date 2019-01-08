//
//  TLXMPPManager+IncomingFileTransfer.m
//  TinLin-XMPP
//
//  Created by Mac on 2018/12/25.
//  Copyright © 2018 xinchenglong. All rights reserved.
//

#import "TLXMPPManager+IncomingFileTransfer.h"

#import "TLMessageMediaModel.h"

static NSString *const kIncomingFilePath = @"file";

@implementation TLXMPPManager (IncomingFileTransfer)

#pragma mark - XMPPIncomingFileTransferDelegate

- (void)xmppIncomingFileTransfer:(XMPPIncomingFileTransfer *)sender didFailWithError:(NSError *)error {
    NSLog(@"%@",error);
}

- (void)xmppIncomingFileTransfer:(XMPPIncomingFileTransfer *)sender didReceiveSIOffer:(XMPPIQ *)offer {
    /// 允许接收
    [sender acceptSIOffer:offer];
    self.incomingFileFromJID = offer.from;
}

- (void)xmppIncomingFileTransfer:(XMPPIncomingFileTransfer *)sender didSucceedWithData:(NSData *)data named:(NSString *)name {
    TLLogFunc;
    NSString *extension = [name pathExtension];
    TLMessageMediaType type = [TLMessageMediaModel fetchMediaTypeWithExtension:extension];

    // 保存data
    NSString *path = TLDocumentDirectory;
    path = [path stringByAppendingPathComponent:name];
    [data writeToFile:path atomically:YES];
    
    XMPPJID *jid = sender.xmppStream.myJID;
    
    // 创建一个XMPPMessage对象,message必须要有from
    XMPPMessage *message = [XMPPMessage messageWithType:@"chat" to:jid];
    [message addAttributeWithName:@"from" stringValue:self.incomingFileFromJID.bare];
    [message addSubject:[@(type) stringValue]];
    [message addBody:path.lastPathComponent];

    // 保存消息记录
    XMPPMessageArchivingCoreDataStorage *xmppMessageArchivingCoreDataStorage = self.xmppMessageArchivingCoreDataStorage;
    
    // 这句 执行完毕会发送通知，然后更新相应的历史消息
    [xmppMessageArchivingCoreDataStorage archiveMessage:message outgoing:NO xmppStream:sender.xmppStream];
    
    if (self.messageDelegate &&
        [self.messageDelegate respondsToSelector:@selector(didReceiveMessage:)] &&
        [[self.messageDelegate currentChatJID] isEqualToJID:self.incomingFileFromJID options:XMPPJIDCompareBare]) {
        /// 当前是否在聊天界面
        [self.messageDelegate didReceiveMessage:message];
    }
}

@end
