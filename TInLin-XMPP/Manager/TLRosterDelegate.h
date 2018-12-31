//
//  TLRosterDelegate.h
//  TinLin-XMPP
//
//  Created by Mac on 2018/12/19.
//  Copyright © 2018 xinchenglong. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol TLRosterDelegate <NSObject>

- (void)rosterDidChange;

@end
