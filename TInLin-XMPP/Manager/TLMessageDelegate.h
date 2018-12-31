//
//  TLMessageDelegate.h
//  TinLin-XMPP
//
//  Created by Mac on 2018/12/20.
//  Copyright © 2018 xinchenglong. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol TLMessageDelegate <NSObject>

- (XMPPJID *)currentChatJID;

- (void)didReceiveMessage:(XMPPMessage *)message;

@end
