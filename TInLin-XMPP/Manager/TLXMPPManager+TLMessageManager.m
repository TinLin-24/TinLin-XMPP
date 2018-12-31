//
//  TLXMPPManager+TLMessageManager.m
//  TinLin-XMPP
//
//  Created by Mac on 2018/12/25.
//  Copyright © 2018 xinchenglong. All rights reserved.
//

#import "TLXMPPManager+TLMessageManager.h"

@implementation TLXMPPManager (TLMessageManager)

#pragma mark - Public

- (NSArray<XMPPMessageArchiving_Message_CoreDataObject *> *)fetchChatHistoryWithBareJidStr:(NSString *)bareJidStr {
    XMPPMessageArchivingCoreDataStorage *storage = self.xmppMessageArchivingCoreDataStorage;
    // 查询的时候要给上下文
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:storage.messageEntityName inManagedObjectContext:storage.mainThreadManagedObjectContext];
    [fetchRequest setEntity:entity];

    NSString *streamBareJidStr = self.xmppStream.myJID.bare;
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"bareJidStr == %@ AND streamBareJidStr == %@",
                              bareJidStr, streamBareJidStr];
    
    [fetchRequest setPredicate:predicate];
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"timestamp"
                                                                   ascending:YES];
    [fetchRequest setSortDescriptors:[NSArray arrayWithObjects:sortDescriptor, nil]];
    
    NSError *error = nil;
    NSArray *fetchedObjects = [storage.mainThreadManagedObjectContext executeFetchRequest:fetchRequest error:&error];

    if (error) {
        NSLog(@"%s-error:%@",__func__,[error description]);
        return @[];
    }
    
    return fetchedObjects == nil ? @[] : fetchedObjects;
}

- (NSArray<XMPPRoomMessageCoreDataStorageObject *> *)fetchGroupChatHistoryWithRoomJidStr:(NSString *)roomJidStr {
    
    XMPPRoomCoreDataStorage *storage = [XMPPRoomCoreDataStorage sharedInstance];;
    // 查询的时候要给上下文
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:storage.messageEntityName inManagedObjectContext:storage.mainThreadManagedObjectContext];
    [fetchRequest setEntity:entity];
    /// 查询语句
    NSString *streamBareJidStr = [TLXMPPManager manager].xmppStream.myJID.bare;
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"roomJIDStr == %@ AND streamBareJidStr == %@",
                              roomJidStr, streamBareJidStr];
    
    [fetchRequest setPredicate:predicate];
    /// 排序
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"localTimestamp"
                                                                   ascending:YES];
    [fetchRequest setSortDescriptors:[NSArray arrayWithObjects:sortDescriptor, nil]];
    
    NSError *error = nil;
    NSArray *fetchedObjects = [storage.mainThreadManagedObjectContext executeFetchRequest:fetchRequest error:&error];
    
    if (error) {
        NSLog(@"%s-error:%@",__func__,[error description]);
        return @[];
    }
    
    return fetchedObjects == nil ? @[] : fetchedObjects;
}

#pragma mark - Message

- (void)xmppStream:(XMPPStream *)sender didReceiveMessage:(XMPPMessage *)message {
    NSString *type = [[message attributeForName:@"type"] stringValue];
    NSLog(@"type:%@",type);
    if (message.isGroupChatMessage) {
        /// 群聊消息
        if (self.groupMessageDelegate && [self.groupMessageDelegate respondsToSelector:@selector(didReceiveMessage:)]) {
            [self.groupMessageDelegate didReceiveMessage:message];
        }
        else {
            
        }
    }
    else {
        if (self.messageDelegate && [self.messageDelegate respondsToSelector:@selector(didReceiveMessage:)]) {
            [self.messageDelegate didReceiveMessage:message];
        }
        else {
            
        }
    }
}

- (BOOL)xmppStream:(XMPPStream *)sender didReceiveIQ:(XMPPIQ *)iq {
    // 以下两个判断其实只需要有一个就够了
    NSString *elementID = iq.elementID;
    if (![elementID isEqualToString:@"getMyRooms"]) {
        return YES;
    }
    
    NSArray *results = [iq elementsForXmlns:XMPPDiscoItemsNamespace];
    if (results.count < 1) {
        return YES;
    }
    
    NSMutableArray *array = [NSMutableArray array];
    for (DDXMLElement *element in iq.children) {
        if ([element.name isEqualToString:@"query"]) {
            for (DDXMLElement *item in element.children) {
                if ([item.name isEqualToString:@"item"]) {
                    [array addObject:item];          //array  就是你的群列表
                    
                }
            }
        }
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:kXMPP_GET_GROUPS object:array];
    return YES;
}

@end
