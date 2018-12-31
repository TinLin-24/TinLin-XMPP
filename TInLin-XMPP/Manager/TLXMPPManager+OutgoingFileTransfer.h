//
//  TLXMPPManager+OutgoingFileTransfer.h
//  TinLin-XMPP
//
//  Created by Mac on 2018/12/25.
//  Copyright © 2018 xinchenglong. All rights reserved.
//

#import "TLXMPPManager.h"

@interface TLXMPPManager (OutgoingFileTransfer)

- (BOOL)sendData:(NSData *)data
           named:(NSString *)name
     toRecipient:(XMPPJID *)recipient
     description:(NSString *)description
           error:(NSError **)errPtr;

@end
