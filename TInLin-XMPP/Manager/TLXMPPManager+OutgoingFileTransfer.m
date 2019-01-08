//
//  TLXMPPManager+OutgoingFileTransfer.m
//  TinLin-XMPP
//
//  Created by Mac on 2018/12/25.
//  Copyright © 2018 xinchenglong. All rights reserved.
//

#import "TLXMPPManager+OutgoingFileTransfer.h"

#import "TLMessageMediaModel.h"

@implementation TLXMPPManager (OutgoingFileTransfer)

#pragma mark - Public

- (BOOL)sendData:(NSData *)data named:(NSString *)name toRecipient:(XMPPJID *)recipient description:(NSString *)description error:(NSError *__autoreleasing *)errPtr {
    BOOL result = [self.xmppOutgoingFileTransfer sendData:data
                                                    named:name
                                              toRecipient:recipient
                                              description:description
                                                    error:errPtr];
    return result;
}

#pragma mark - XMPPOutgoingFileTransferDelegate

- (void)xmppOutgoingFileTransferIBBClosed:(XMPPOutgoingFileTransfer *)sender {
    TLLogFunc;
}

- (void)xmppOutgoingFileTransferDidSucceed:(XMPPOutgoingFileTransfer *)sender {
    TLLogFunc;
    NSString *extension = [[sender outgoingFileName] pathExtension];
    TLMessageMediaType type = [TLMessageMediaModel fetchMediaTypeWithExtension:extension];
    
    // 保存data
    NSString *path = TLDocumentDirectory;
    path = [path stringByAppendingPathComponent:[sender outgoingFileName]];
    [sender.outgoingData writeToFile:path atomically:YES];
    
    // 这里将信息保存
    XMPPMessage *message = [XMPPMessage messageWithType:@"chat" to:sender.recipientJID];
    //将这个文件的发送者添加到message的from
    [message addAttributeWithName:@"from" stringValue:sender.xmppStream.myJID.bare];
    [message addSubject:[@(type) stringValue]];
    [message addBody:path.lastPathComponent];
    
    // 保存消息记录
    XMPPMessageArchivingCoreDataStorage *xmppMessageArchivingCoreDataStorage = self.xmppMessageArchivingCoreDataStorage;
    [xmppMessageArchivingCoreDataStorage archiveMessage:message outgoing:YES xmppStream:sender.xmppStream];
    
    if (self.messageDelegate &&
        [self.messageDelegate respondsToSelector:@selector(didReceiveMessage:)] &&
        [sender.recipientJID isEqualToJID:[self.messageDelegate currentChatJID] options:XMPPJIDCompareBare]){
        /// 当前是否在聊天界面
        [self.messageDelegate didReceiveMessage:message];
    }
}

- (void)xmppOutgoingFileTransfer:(XMPPOutgoingFileTransfer *)sender didFailWithError:(NSError *)error {
    NSLog(@"%@",error);
    if (error.code == 503) {
        // 用户离线
        
    }
}

@end
