//
//  TLMessageModel.m
//  TinLin-XMPP
//
//  Created by Mac on 2018/12/20.
//  Copyright © 2018 xinchenglong. All rights reserved.
//

#import "TLMessageModel.h"

@interface TLMessageModel ()

@property (nonatomic, strong, readwrite) XMPPJID *jid;

@property (nonatomic, strong, readwrite) XMPPJID *chatJID;

@end

@implementation TLMessageModel

- (instancetype)initWithChatJID:(XMPPJID *)chatJID
{
    self = [super init];
    if (self) {
        _chatJID = chatJID;
        
        self.messages = [NSMutableArray new];
        
        JSQMessagesAvatarImage *Image = [JSQMessagesAvatarImageFactory avatarImageWithImage:TLImageNamed(@"demo_avatar") diameter:kJSQMessagesCollectionViewAvatarSizeDefault];
        
        /// 自己的头像
        JSQMessagesAvatarImage *userImage = [JSQMessagesAvatarImageFactory avatarImageWithImage:[TLXMPPManager manager].avatarImage
                                                                                       diameter:kJSQMessagesCollectionViewAvatarSizeDefault];
        self.avatars = @{ self.chatJID.bare:Image,
                          [TLXMPPManager manager].xmppStream.myJID.bare:userImage};
        
        self.users = @{ kJSQDemoAvatarIdSquires : kJSQDemoAvatarDisplayNameSquires,
                        @"kang@appledeimac.local":@"header"
                        };

        JSQMessagesBubbleImageFactory *bubbleFactory = [[JSQMessagesBubbleImageFactory alloc] init];
        
        self.outgoingBubbleImageData = [bubbleFactory outgoingMessagesBubbleImageWithColor:[UIColor jsq_messageBubbleLightGrayColor]];
        self.incomingBubbleImageData = [bubbleFactory incomingMessagesBubbleImageWithColor:[UIColor jsq_messageBubbleGreenColor]];
    }
    
    return self;
}


- (void)addPhotoMediaMessage:(UIImage *)image
{
    JSQPhotoMediaItem *photoItem = [[JSQPhotoMediaItem alloc] initWithImage:image];
    photoItem.appliesMediaViewMaskAsOutgoing = YES;
    JSQMessage *photoMessage = [JSQMessage messageWithSenderId:self.jid.bare
                                                   displayName:self.jid.user
                                                         media:photoItem];
    
    [self.messages addObject:photoMessage];
}

- (void)addLocationMediaMessage:(CLLocation *)location Completion:(JSQLocationMediaItemCompletionBlock)completion
{
    JSQLocationMediaItem *locationItem = [[JSQLocationMediaItem alloc] init];
    [locationItem setLocation:location withCompletionHandler:completion];
    
    JSQMessage *locationMessage = [JSQMessage messageWithSenderId:self.jid.bare
                                                      displayName:self.jid.user
                                                            media:locationItem];
    [self.messages addObject:locationMessage];
}

- (void)addVideoMediaMessage
{
    // don't have a real video, just pretending
    NSURL *videoURL = [NSURL URLWithString:@"file://"];
    
    JSQVideoMediaItem *videoItem = [[JSQVideoMediaItem alloc] initWithFileURL:videoURL isReadyToPlay:YES];
    JSQMessage *videoMessage = [JSQMessage messageWithSenderId:self.jid.bare
                                                   displayName:self.jid.user
                                                         media:videoItem];
    [self.messages addObject:videoMessage];
}

- (XMPPJID *)jid {
    if (!_jid) {
        _jid = [TLXMPPManager manager].xmppStream.myJID;
    }
    return _jid;
}

@end
