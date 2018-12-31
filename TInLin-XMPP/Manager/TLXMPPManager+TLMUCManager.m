//
//  TLXMPPManager+TLMUCManager.m
//  TinLin-XMPP
//
//  Created by Mac on 2018/12/24.
//  Copyright © 2018 xinchenglong. All rights reserved.
//

#import "TLXMPPManager+TLMUCManager.h"

@implementation TLXMPPManager (TLMUCManager)

#pragma mark - Public

- (void)fetchMineRoom {
    NSXMLElement *queryElement= [NSXMLElement elementWithName:@"query" xmlns:XMPPDiscoItemsNamespace];
    NSXMLElement *iqElement = [NSXMLElement elementWithName:@"iq"];
    [iqElement addAttributeWithName:@"type" stringValue:@"get"];
    [iqElement addAttributeWithName:@"from" stringValue:[TLXMPPManager manager].xmppStream.myJID.bare];
    NSString *service = [NSString stringWithFormat:@"%@.%@",bXMPP_subdomain,bXMPP_domain];
    [iqElement addAttributeWithName:@"to" stringValue:service];
    [iqElement addAttributeWithName:@"id" stringValue:@"getMyRooms"];
    [iqElement addChild:queryElement];
    [[TLXMPPManager manager].xmppStream sendElement:iqElement];
}

#pragma mark - XMPPMUCDelegate

- (void)xmppMUC:(XMPPMUC *)sender didDiscoverServices:(NSArray *)services {
    TLLogFunc;
}

- (void)xmppMUC:(XMPPMUC *)sender roomJID:(XMPPJID *)roomJID didReceiveInvitation:(XMPPMessage *)message {
    TLLogFunc;
    DDXMLElement *invite = [[message elementForName:@"x"] elementForName:@"invite"];
    NSString *fromJIDStr = [[invite attributeForName:@"from"] stringValue];
    XMPPJID *fromJID = [XMPPJID jidWithString:fromJIDStr];
    
    NSString *title = [NSString stringWithFormat:@"%@想邀请你加入群聊",fromJID.user];
    NSString *messageStr = [[invite elementForName:@"reason"] stringValue];
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title message:messageStr preferredStyle:UIAlertControllerStyleAlert];
    
    [alertController tl_addActionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
    
    @weakify(self);
    [alertController tl_addActionWithTitle:@"加入" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        @strongify(self);
        XMPPRoomHybridStorage *roomStorage = [XMPPRoomHybridStorage sharedInstance];
        XMPPRoom *room = [[XMPPRoom alloc] initWithRoomStorage:roomStorage jid:roomJID];
        [room activate:self.xmppStream];
        [room joinRoomUsingNickname:self.xmppStream.myJID.user history:nil];
    }];
    
    [alertController tl_showWithViewController:nil animated:YES completion:nil];
}

- (void)xmppMUC:(XMPPMUC *)sender didDiscoverRooms:(NSArray *)rooms forServiceNamed:(NSString *)serviceName {
    TLLogFunc;
}

- (void)xmppMUC:(XMPPMUC *)sender roomJID:(XMPPJID *)roomJID didReceiveInvitationDecline:(XMPPMessage *)message {
    TLLogFunc;
}

- (void)xmppMUCFailedToDiscoverServices:(XMPPMUC *)sender withError:(NSError *)error {
    TLLogFunc;
}

- (void)xmppMUC:(XMPPMUC *)sender failedToDiscoverRoomsForServiceNamed:(NSString *)serviceName withError:(NSError *)error {
    TLLogFunc;
}

@end
