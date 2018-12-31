//
//  TLXMPPManager+TLRosterManager.m
//  TinLin-XMPP
//
//  Created by Mac on 2018/12/25.
//  Copyright © 2018 xinchenglong. All rights reserved.
//

#import "TLXMPPManager+TLRosterManager.h"

@implementation TLXMPPManager (TLRosterManager)

#pragma mark - XMPPRosterDelegate

- (void)xmppRoster:(XMPPRoster *)sender didReceivePresenceSubscriptionRequest:(XMPPPresence *)presence {
    // 收到出席订阅请求（代表对方想添加自己为好友)
    // 添加好友一定会订阅对方，但是接受订阅不一定要添加对方为好友
    
    NSString *title = [NSString stringWithFormat:@"%@想加你为好友",presence.from.user];
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title message:@"" preferredStyle:UIAlertControllerStyleAlert];
    
    @weakify(self);
    [alertController tl_addActionWithTitle:@"拒绝" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
        @strongify(self);
        [self.xmppRoster rejectPresenceSubscriptionRequestFrom:presence.from];
    }];
    
    [alertController tl_addActionWithTitle:@"同意" style:UIAlertActionStyleDefault handler:^(UIAlertAction *  action) {
        @strongify(self);
        [self.xmppRoster acceptPresenceSubscriptionRequestFrom:presence.from andAddToRoster:YES];
    }];
    
    [alertController tl_showWithViewController:nil animated:YES completion:nil];
}

- (void)xmppRoster:(XMPPRoster *)sender didReceiveRosterPush:(XMPPIQ *)iq {
    // 收到对方取消定阅我的消息
    if ([iq.type isEqualToString:@"unsubscribe"]) {
        //从我的本地通讯录中将他移除
        [self.xmppRoster removeUser:iq.from];
    }
}

- (void)xmppRosterDidBeginPopulating:(XMPPRoster *)sender withVersion:(NSString *)version {
    // 开始同步服务器发送过来的自己的好友列表
}

- (void)xmppRosterDidEndPopulating:(XMPPRoster *)sender {
    // 同步结束
    // 收到好友列表IQ会进入的方法，并且已经存入我的存储器
    if (self.rosterDelegate && [self.rosterDelegate respondsToSelector:@selector(rosterDidChange)]) {
        [self.rosterDelegate rosterDidChange];
    }
}

- (void)xmppRoster:(XMPPRoster *)sender didReceiveRosterItem:(NSXMLElement *)item {
    // 收到每一个好友
}

#pragma mark - XMPPRosterMemoryStorageDelegate

- (void)xmppRosterDidChange:(XMPPRosterMemoryStorage *)sender {
    // 如果不是初始化同步来的roster,那么会自动存入我的好友存储器
    if (self.rosterDelegate && [self.rosterDelegate respondsToSelector:@selector(rosterDidChange)]) {
        [self.rosterDelegate rosterDidChange];
    }
}

- (void)xmppRosterDidPopulate:(XMPPRosterMemoryStorage *)sender {
    
}

- (void)xmppRoster:(XMPPRosterMemoryStorage *)sender didAddUser:(XMPPUserMemoryStorageObject *)user {
    
}
- (void)xmppRoster:(XMPPRosterMemoryStorage *)sender didUpdateUser:(XMPPUserMemoryStorageObject *)user {
    
}
- (void)xmppRoster:(XMPPRosterMemoryStorage *)sender didRemoveUser:(XMPPUserMemoryStorageObject *)user {
    
}

- (void)xmppRoster:(XMPPRosterMemoryStorage *)sender
    didAddResource:(XMPPResourceMemoryStorageObject *)resource
          withUser:(XMPPUserMemoryStorageObject *)user {
    
}

- (void)xmppRoster:(XMPPRosterMemoryStorage *)sender
 didUpdateResource:(XMPPResourceMemoryStorageObject *)resource
          withUser:(XMPPUserMemoryStorageObject *)user {
    
}

- (void)xmppRoster:(XMPPRosterMemoryStorage *)sender
 didRemoveResource:(XMPPResourceMemoryStorageObject *)resource
          withUser:(XMPPUserMemoryStorageObject *)user {
    
}

@end
