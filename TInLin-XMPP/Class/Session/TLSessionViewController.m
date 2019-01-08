//
//  TLSessionViewController.m
//  TinLin-XMPP
//
//  Created by Mac on 2018/12/19.
//  Copyright © 2018 xinchenglong. All rights reserved.
//

#import "TLSessionViewController.h"
#import "TLMapViewController.h"
#import <KSPhotoBrowser.h>
#import <TZImagePickerController/TZImagePickerController.h>
#import <AVKit/AVPlayerViewController.h>

#import "TLMessageModel.h"
#import "TLMessageMediaModel.h"

#import "XMPPIncomingFileTransfer.h"
#import "XMPPOutgoingFileTransfer.h"

@interface TLSessionViewController ()<JSQMessagesComposerTextViewPasteDelegate,TLMessageDelegate>

//
@property (nonatomic, strong)TLMessageModel *model;
//
@property (nonatomic, assign)BOOL didShow;

@end

@implementation TLSessionViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self configure];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    if (!self.didShow) {
        self.didShow = YES;
        self.collectionView.collectionViewLayout.springinessEnabled = YES;
    }
}

- (void)dealloc {
    TLDealloc;
}

- (void)configure {
    // Sender ID 发送人ID
    self.senderId = [TLXMPPManager manager].xmppStream.myJID.bare;
    self.senderDisplayName = [TLXMPPManager manager].xmppStream.myJID.user;
    
    self.title = self.chatJID.user;
    
    self.inputToolbar.contentView.textView.pasteDelegate = self;
    self.inputToolbar.contentView.textView.placeHolder = @"输入";
    [self.inputToolbar.contentView.rightBarButtonItem setTitle:@"发送" forState:UIControlStateNormal];
    
    self.showLoadEarlierMessagesHeader = NO;

    [JSQMessagesCollectionViewCell registerMenuAction:@selector(customAction:)];
    [UIMenuController sharedMenuController].menuItems = @[ [[UIMenuItem alloc] initWithTitle:@"Custom Action"
                                                                                      action:@selector(customAction:)] ];
    [JSQMessagesCollectionViewCell registerMenuAction:@selector(delete:)];

    [TLXMPPManager manager].messageDelegate = self;
    
    [self _fetchChatHistory];
    
//    [[TLXMPPManager manager].xmppIncomingFileTransfer addDelegate:self delegateQueue:dispatch_get_main_queue()];
}

#pragma mark - Private

/** 查询聊天记录 */
- (void)_fetchChatHistory {
    NSArray *historys = [[TLXMPPManager manager] fetchChatHistoryWithBareJidStr:self.chatJID.bare];
    for (XMPPMessageArchiving_Message_CoreDataObject *message in historys) {
        NSString *subject = [[message.message elementForName:@"subject"] stringValue];
        TLMessageMediaType type = [subject integerValue];
        
        XMPPJID *jid = [TLXMPPManager manager].xmppStream.myJID;
        
        NSString *senderId = message.isOutgoing ? jid.bare : message.bareJidStr;
        NSString *displayName = message.isOutgoing ? jid.user : message.bareJid.user;
        NSDate *date = message.timestamp;
        NSString *body = message.body;
        
        JSQMessage *newMessage;
        
        switch (type) {
            case TLMessageMediaNone:
            {
                newMessage = [self _fetchJSQMessageWithSenderId:senderId
                                                    DisplayName:displayName
                                                           Date:date
                                                           Text:body];
            }
                break;
            default:
            {
                id model = [self _fetchMessageMedia:type
                                           SenderId:senderId
                                               Body:body];
                newMessage = [self _fetchJSQMessageWithSenderId:senderId
                                                    DisplayName:displayName
                                                           Date:date
                                                          Media:model];
            }
                break;
        }
        !newMessage ? : [self.model.messages addObject:newMessage];
    }
    [self.collectionView reloadData];
    [self finishReceivingMessageAnimated:YES];
}

- (JSQMessage *)_fetchJSQMessageWithSenderId:(NSString *)senderId
                         DisplayName:(NSString *)displayName
                                Date:(NSDate *)date
                                Text:(NSString *)text{
    return [[JSQMessage alloc] initWithSenderId:senderId
                              senderDisplayName:displayName
                                           date:date
                                           text:text];
}

- (JSQMessage *)_fetchJSQMessageWithSenderId:(NSString *)senderId
                                 DisplayName:(NSString *)displayName
                                        Date:(NSDate *)date
                                       Media:(id<JSQMessageMediaData>)media{
    return [[JSQMessage alloc] initWithSenderId:senderId
                              senderDisplayName:displayName
                                           date:date
                                          media:media];
}

- (id<JSQMessageMediaData>)_fetchMessageMedia:(TLMessageMediaType)type
                                     SenderId:(NSString *)senderId
                                         Body:(NSString *)body{
    BOOL outgoing = ![senderId isEqualToString:self.chatJID.bare];
    return [TLMessageMediaModel fetchMediaItemWithType:type Outgoing:outgoing Body:body];
}

#pragma mark - over

- (void)didPressSendButton:(UIButton *)button
           withMessageText:(NSString *)text
                  senderId:(NSString *)senderId
         senderDisplayName:(NSString *)senderDisplayName
                      date:(NSDate *)date {
    
    [JSQSystemSoundPlayer jsq_playMessageSentSound];
    JSQMessage *message = [[JSQMessage alloc] initWithSenderId:senderId
                                             senderDisplayName:senderDisplayName
                                                          date:date
                                                          text:text];
    [self.model.messages addObject:message];
    
    XMPPMessage *XMPPmessage = [XMPPMessage messageWithType:@"chat" to:self.chatJID];
    [XMPPmessage addBody:text];
    [[TLXMPPManager manager].xmppStream sendElement:XMPPmessage];
    //显示发送信息
    [self finishSendingMessageAnimated:YES];
}

- (void)didPressAccessoryButton:(UIButton *)sender {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    @weakify(self);
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消"
                                                     style:UIAlertActionStyleCancel
                                                         handler:^(UIAlertAction * _Nonnull action) {
                                                             
                                                         }];
    
    UIAlertAction *sendPicAction = [UIAlertAction actionWithTitle:@"发送图片"
                                                           style:UIAlertActionStyleDefault
                                                         handler:^(UIAlertAction * _Nonnull action) {
                                                             @strongify(self);
                                                             [self _sendPicAction:action];
                                                         }];
    
    UIAlertAction *sendLocAction = [UIAlertAction actionWithTitle:@"发送位置"
                                                            style:UIAlertActionStyleDefault
                                                          handler:^(UIAlertAction * _Nonnull action) {
                                                              @strongify(self);
                                                              [self _sendLocAction:action];
                                                          }];
    
    UIAlertAction *sendVideoAction = [UIAlertAction actionWithTitle:@"发送视频"
                                                            style:UIAlertActionStyleDefault
                                                          handler:^(UIAlertAction * _Nonnull action) {
                                                              @strongify(self);
                                                              [self _sendVideoAction:action];
                                                          }];
    
    [alertController addAction:cancelAction];
    [alertController addAction:sendPicAction];
    [alertController addAction:sendLocAction];
    [alertController addAction:sendVideoAction];
    [self presentViewController:alertController animated:YES completion:nil];
}

#pragma mark - TLMessageDelegate

- (XMPPJID *)currentChatJID {
    return self.chatJID;
}

- (void)didReceiveMessage:(XMPPMessage *)message {
    NSString *msg = [[message elementForName:@"body"] stringValue];

    NSString *subject = [[message elementForName:@"subject"] stringValue];
    TLMessageMediaType type = [subject integerValue];
    
    if (!msg) return;
    
    JSQMessage *newMessage = nil;
    if (type == TLMessageMediaNone) {
        /// 普通消息
        newMessage = [JSQMessage messageWithSenderId:message.from.bare
                                         displayName:message.from.user
                                                text:msg];
    }
    else {
        /// 媒体消息
        id item = [self _fetchMessageMedia:type
                                  SenderId:message.from.bare
                                      Body:msg];
        newMessage = [self _fetchJSQMessageWithSenderId:message.from.bare
                                            DisplayName:message.from.user
                                                   Date:[NSDate date]
                                                  Media:item];
    }
    
    if (newMessage) {
        [self.model.messages addObject:newMessage];
        [self.collectionView reloadData];
        [self finishReceivingMessageAnimated:YES];
    }
}

#pragma mark - JSQMessages CollectionView DataSource

- (id<JSQMessageData>)collectionView:(JSQMessagesCollectionView *)collectionView messageDataForItemAtIndexPath:(NSIndexPath *)indexPath {
    return [self.model.messages objectAtIndex:indexPath.item];
}

- (id<JSQMessageBubbleImageDataSource>)collectionView:(JSQMessagesCollectionView *)collectionView messageBubbleImageDataForItemAtIndexPath:(NSIndexPath *)indexPath {
    /**
     *  You may return nil here if you do not want bubbles.
     *  In this case, you should set the background color of your collection view cell's textView.
     *
     *  Otherwise, return your previously created bubble image data objects.
     */
    
    JSQMessage *message = [self.model.messages objectAtIndex:indexPath.item];
    
    if ([message.senderId isEqualToString:self.senderId]) {
        return self.model.outgoingBubbleImageData;
    }
    return self.model.incomingBubbleImageData;
}


/**
 *  获取头像
 */
- (id<JSQMessageAvatarImageDataSource>)collectionView:(JSQMessagesCollectionView *)collectionView avatarImageDataForItemAtIndexPath:(NSIndexPath *)indexPath {
    JSQMessage *message = [self.model.messages objectAtIndex:indexPath.item];
    
    id<JSQMessageAvatarImageDataSource> avatar = nil;
    avatar = [self.model.avatars objectForKey:message.senderId];

//    if ([message.senderId isEqualToString:self.senderId]) {
//        avatar = [self.model.avatars objectForKey:message.senderId];
//    }
//    else{
//        avatar = [self.model.avatars objectForKey:@"kang@appledeimac.local"];
//    }
    return avatar;
}

- (NSAttributedString *)collectionView:(JSQMessagesCollectionView *)collectionView attributedTextForCellTopLabelAtIndexPath:(NSIndexPath *)indexPath {
    JSQMessage *message = [self.model.messages objectAtIndex:indexPath.item];
    return [[JSQMessagesTimestampFormatter sharedFormatter] attributedTimestampForDate:message.date];
}

- (NSAttributedString *)collectionView:(JSQMessagesCollectionView *)collectionView attributedTextForMessageBubbleTopLabelAtIndexPath:(NSIndexPath *)indexPath {
    JSQMessage *message = [self.model.messages objectAtIndex:indexPath.item];
    return [[NSAttributedString alloc] initWithString:message.senderDisplayName];
}


- (NSAttributedString *)collectionView:(JSQMessagesCollectionView *)collectionView attributedTextForCellBottomLabelAtIndexPath:(NSIndexPath *)indexPath {
    return nil;
}

- (CGFloat)collectionView:(JSQMessagesCollectionView *)collectionView layout:(JSQMessagesCollectionViewFlowLayout *)collectionViewLayout heightForCellTopLabelAtIndexPath:(NSIndexPath *)indexPath {
    return kJSQMessagesCollectionViewCellLabelHeightDefault;
}

- (CGFloat)collectionView:(JSQMessagesCollectionView *)collectionView layout:(JSQMessagesCollectionViewFlowLayout *)collectionViewLayout heightForCellBottomLabelAtIndexPath:(NSIndexPath *)indexPath {
    return CGFLOAT_MIN;
}

- (CGFloat)collectionView:(JSQMessagesCollectionView *)collectionView
                   layout:(JSQMessagesCollectionViewFlowLayout *)collectionViewLayout heightForMessageBubbleTopLabelAtIndexPath:(NSIndexPath *)indexPath {
    JSQMessage *currentMessage = [self.model.messages objectAtIndex:indexPath.item];
    if ([[currentMessage senderId] isEqualToString:self.senderId]) {
        return 0.0f;
    }
    if (indexPath.item - 1 > 0) {
        JSQMessage *previousMessage = [self.model.messages objectAtIndex:indexPath.item - 1];
        if ([[previousMessage senderId] isEqualToString:[currentMessage senderId]]) {
            return 0.0f;
        }
    }
    return kJSQMessagesCollectionViewCellLabelHeightDefault;
}

#pragma mark - UICollectionView DataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [self.model.messages count];
}

- (UICollectionViewCell *)collectionView:(JSQMessagesCollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {

    JSQMessagesCollectionViewCell *cell = (JSQMessagesCollectionViewCell *)[super collectionView:collectionView cellForItemAtIndexPath:indexPath];
    
    JSQMessage *msg = [self.model.messages objectAtIndex:indexPath.item];
    if (!msg.isMediaMessage) {
        if ([msg.senderId isEqualToString:self.senderId]) {
            cell.textView.textColor = [UIColor blackColor];
        }
        else {
            cell.textView.textColor = [UIColor whiteColor];
        }
        cell.textView.linkTextAttributes = @{ NSForegroundColorAttributeName : cell.textView.textColor,
                                              NSUnderlineStyleAttributeName : @(NSUnderlineStyleSingle | NSUnderlinePatternSolid) };
    }
    else {
        //NSLog(@"isMediaMessage");
    }
    
    return cell;
}

- (void)collectionView:(JSQMessagesCollectionView *)collectionView didDeleteMessageAtIndexPath:(NSIndexPath *)indexPath {
    [self.model.messages removeObjectAtIndex:indexPath.item];
}

#pragma mark - Collection view delegate flow layout

- (void)collectionView:(JSQMessagesCollectionView *)collectionView didTapAvatarImageView:(UIImageView *)avatarImageView atIndexPath:(NSIndexPath *)indexPath {
}

- (void)collectionView:(JSQMessagesCollectionView *)collectionView didTapMessageBubbleAtIndexPath:(NSIndexPath *)indexPath {
    JSQMessage *message = self.model.messages[indexPath.row];
    if (!message.media) {
        return;
    }
    if ([message.media isKindOfClass:[JSQPhotoMediaItem class]]) {
        [self collectionView:collectionView didTapPicMessageAtIndexPath:indexPath];
    }
    else if ([message.media isKindOfClass:[JSQAudioMediaItem class]]) {

    }
    else if ([message.media isKindOfClass:[JSQLocationMediaItem class]]) {
        [self collectionView:collectionView didTapLocationMessage:message];
    }
    else if ([message.media isKindOfClass:[JSQVideoMediaItem class]]) {
        [self collectionView:collectionView didTapVideoMessage:message];
    }
}

- (void)collectionView:(JSQMessagesCollectionView *)collectionView
 didTapCellAtIndexPath:(NSIndexPath *)indexPath
         touchLocation:(CGPoint)touchLocation {
    TLLogFunc;
}

#pragma mark - Tap Action

/**
 点击图片消息
 */
- (void)collectionView:(JSQMessagesCollectionView *)collectionView didTapPicMessageAtIndexPath:(NSIndexPath *)indexPath {

    NSMutableArray *items = [NSMutableArray array];
    __block KSPhotoItem *tapItem;
    
    [self.model.messages enumerateObjectsUsingBlock:^(JSQMessage *message, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([message.media isKindOfClass:[JSQPhotoMediaItem class]]) {
            UIImageView *imageView =  (UIImageView *)[message.media mediaView];
            KSPhotoItem *item = [KSPhotoItem itemWithSourceView:imageView image:imageView.image];
            [items addObject:item];
            if (idx == indexPath.row) {
                tapItem = item;
            }
        }
    }];
    
    NSInteger index = tapItem ? [items indexOfObject:tapItem] : 0;
    KSPhotoBrowser *browser = [KSPhotoBrowser browserWithPhotoItems:items selectedIndex:index];
    browser.dismissalStyle = KSPhotoBrowserInteractiveDismissalStyleSlide;
    browser.pageindicatorStyle = KSPhotoBrowserPageIndicatorStyleText;
    [browser showFromViewController:self];
}

/**
 点击位置消息
 */
- (void)collectionView:(JSQMessagesCollectionView *)collectionView didTapLocationMessage:(JSQMessage *)message {
    JSQLocationMediaItem *mediaItem = (JSQLocationMediaItem *)[message media];
    TLMapViewController *viewController = [TLMapViewController new];
    viewController.location = mediaItem.location;
    [self.navigationController pushViewController:viewController animated:YES];
}

/**
 点击视频消息
 */
- (void)collectionView:(JSQMessagesCollectionView *)collectionView didTapVideoMessage:(JSQMessage *)message {
    JSQVideoMediaItem *mediaItem = (JSQVideoMediaItem *)[message media];
    if ([[NSFileManager defaultManager] fileExistsAtPath:mediaItem.fileURL.path]) {
        AVPlayerViewController *viewController = [[AVPlayerViewController alloc] init];
        viewController.player = [AVPlayer playerWithURL:mediaItem.fileURL];
        viewController.allowsPictureInPicturePlayback = YES;
        [self presentViewController:viewController animated:YES completion:nil];
    }
    else {
        [MBProgressHUD tl_showTips:@"文件不存在！"];
    }
}

#pragma mark - Action

- (void)customAction:(id)sender {
    NSLog(@"Custom action received! Sender: %@", sender);
    [[[UIAlertView alloc] initWithTitle:@"Custom Action"
                                message:nil
                               delegate:nil
                      cancelButtonTitle:@"OK"
                      otherButtonTitles:nil]
     show];
}

- (void)_sendPicAction:(UIAlertAction *)action {
    TZImagePickerController *controller = [[TZImagePickerController alloc] init];
    controller.maxImagesCount = 1;
    controller.allowTakePicture = YES;
    controller.allowPickingGif = NO;
    controller.allowPickingVideo = NO;
    @weakify(self);
    controller.didFinishPickingPhotosHandle = ^(NSArray<UIImage *> *photos, NSArray *assets, BOOL isSelectOriginalPhoto) {
        @strongify(self);
        NSData *imageData = UIImageJPEGRepresentation(photos.firstObject, .8f);
        NSError *error;
        XMPPJID *recipient = [XMPPJID jidWithUser:self.chatJID.user domain:bXMPP_domain resource:bXMPP_resource];
        NSString *file = [NSString stringWithFormat:@"%@.png",[XMPPStream generateUUID]];
        [[TLXMPPManager manager] sendData:imageData named:file toRecipient:recipient description:@"tinlin" error:&error];
        if (!error) {
            [JSQSystemSoundPlayer jsq_playMessageSentSound];
        }
        else {
            NSString *tips = error.code == -1 ? @"有文件在发送中！" : error.userInfo[@"NSLocalizedDescription"];
            [MBProgressHUD tl_showTips:tips];
        }
    };
    [self presentViewController:controller animated:YES completion:nil];
}

- (void)_sendLocAction:(UIAlertAction *)action {
    CLLocation *location = [[CLLocation alloc] initWithLatitude:37.795313 longitude:-122.393757];
    NSString *text = [NSString stringWithFormat:@"%f,%f",location.coordinate.latitude,location.coordinate.longitude];
    
    [JSQSystemSoundPlayer jsq_playMessageSentSound];

    XMPPMessage *message = [XMPPMessage messageWithType:@"chat" to:self.chatJID];
    [message addSubject:[@(TLMessageMediaLocation) stringValue]];
    [message addBody:text];
    [[TLXMPPManager manager].xmppStream sendElement:message];
    //显示发送信息
    @weakify(self);
    [self.model addLocationMediaMessage:location Completion:^{
        @strongify(self);
        [self finishSendingMessage];
    }];
}

- (void)_sendVideoAction:(UIAlertAction *)action {
//    [MBProgressHUD tl_showTips:@"待开发"];
    TZImagePickerController *controller = [[TZImagePickerController alloc] init];
    controller.maxImagesCount = 1;
    controller.allowPickingImage = NO;
    controller.allowTakePicture = NO;
    controller.allowPickingGif = NO;
    controller.allowPickingVideo = YES;
    @weakify(self);
    controller.didFinishPickingVideoHandle = ^(UIImage *coverImage, PHAsset *asset) {
        @strongify(self);
        [self _fetchVideoData:asset];
    };
    [self presentViewController:controller animated:YES completion:nil];
}

- (void)_fetchVideoData:(PHAsset *)asset {
    @weakify(self);
    [[TZImageManager manager] getVideoWithAsset:asset completion:^(AVPlayerItem *playerItem, NSDictionary *info) {
        @strongify(self);
        NSString *path = [[info[@"PHImageFileSandboxExtensionTokenKey"] componentsSeparatedByString:@";"] lastObject];
        NSData *videoData = [NSData dataWithContentsOfFile:path];
        if (!videoData) {
            return ;
        }
        NSError *error;
        XMPPJID *recipient = [XMPPJID jidWithUser:self.chatJID.user domain:bXMPP_domain resource:bXMPP_resource];
        NSString *extension = [path pathExtension];
        NSString *fileName = [[XMPPStream generateUUID] stringByAppendingPathExtension:extension];
        [[TLXMPPManager manager] sendData:videoData named:fileName toRecipient:recipient description:@"tinlin" error:&error];
        if (!error) {
            [JSQSystemSoundPlayer jsq_playMessageSentSound];
        }
        else {
            [MBProgressHUD tl_showTips:[error description]];
        }
    }];
}

#pragma mark - JSQMessagesComposerTextViewPasteDelegate

- (BOOL)composerTextView:(JSQMessagesComposerTextView *)textView shouldPasteWithSender:(id)sender {
    if ([UIPasteboard generalPasteboard].image) {
        // If there's an image in the pasteboard, construct a media item with that image and `send` it.
        JSQPhotoMediaItem *item = [[JSQPhotoMediaItem alloc] initWithImage:[UIPasteboard generalPasteboard].image];
        JSQMessage *message = [[JSQMessage alloc] initWithSenderId:self.senderId
                                                 senderDisplayName:self.senderDisplayName
                                                              date:[NSDate date]
                                                             media:item];
        [self.model.messages addObject:message];
        [self finishSendingMessage];
        return NO;
    }
    return YES;
}

#pragma mark - Getter

- (TLMessageModel *)model {
    if (!_model) {
        _model = [[TLMessageModel alloc] initWithChatJID:self.chatJID];
    }
    return _model;
}

@end
