//
//  TLMessageModel.h
//  TinLin-XMPP
//
//  Created by Mac on 2018/12/20.
//  Copyright © 2018 xinchenglong. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import <JSQMessages.h>

static NSString * const kJSQDemoAvatarDisplayNameSquires = @"cnbin";
static NSString * const kJSQDemoAvatarIdSquires = @"053496-4509-289";

@interface TLMessageModel : NSObject

@property (nonatomic, strong) NSMutableArray *messages;

@property (nonatomic, strong) NSDictionary *avatars;

@property (nonatomic, strong) JSQMessagesBubbleImage *outgoingBubbleImageData;

@property (nonatomic, strong) JSQMessagesBubbleImage *incomingBubbleImageData;

@property (nonatomic, strong) NSDictionary *users;

- (instancetype)initWithChatJID:(XMPPJID *)chatJID;

- (void)addPhotoMediaMessage:(UIImage *)image;

- (void)addLocationMediaMessage:(CLLocation *)location Completion:(JSQLocationMediaItemCompletionBlock)completion;

@end
