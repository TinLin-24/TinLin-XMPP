//
//  GroupChatViewController.m
//  TinLin-XMPP
//
//  Created by Mac on 2018/12/24.
//  Copyright © 2018 xinchenglong. All rights reserved.
//

#import "GroupChatViewController.h"

#import "GroupChatModel.h"
#import "TLMessageMediaModel.h"

#import "XMPPOutgoingFileTransfer.h"

#import <TZImagePickerController/TZImagePickerController.h>

@interface GroupChatViewController ()<JSQMessagesComposerTextViewPasteDelegate,TLMessageDelegate,XMPPOutgoingFileTransferDelegate,XMPPIncomingFileTransferDelegate>

//
@property (nonatomic, strong)GroupChatModel *model;
//
@property (nonatomic, strong)XMPPOutgoingFileTransfer *xmppOutgoingFileTransfer;

@end

@implementation GroupChatViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self configure];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    self.collectionView.collectionViewLayout.springinessEnabled = YES;
}

- (void)dealloc {
    TLDealloc;
}

- (void)configure {
    // Sender ID 发送人ID
    self.senderId = [TLXMPPManager manager].xmppStream.myJID.bare;
    self.senderDisplayName = [TLXMPPManager manager].xmppStream.myJID.user;
    
    self.title = self.roomJID.user;
    
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
    
    [[TLXMPPManager manager].xmppIncomingFileTransfer addDelegate:self delegateQueue:dispatch_get_main_queue()];
}

#pragma mark - Private

/** 查询聊天记录 */
- (void)_fetchChatHistory {
    [self.model fetchGroupChatHistory];
    [self.collectionView reloadData];
    [self finishReceivingMessageAnimated:YES];
}

#pragma mark - over

- (void)didPressSendButton:(UIButton *)button
           withMessageText:(NSString *)text
                  senderId:(NSString *)senderId
         senderDisplayName:(NSString *)senderDisplayName
                      date:(NSDate *)date {
    
    [JSQSystemSoundPlayer jsq_playMessageSentSound];
    [self.model sendGroupMessageWithMessageText:text
                                       senderId:senderId
                              senderDisplayName:senderDisplayName
                                           date:date];
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
    else if (type == TLMessageMediaLocation) {
        /// 位置消息
//        id item = [self _fetchMessageMedia:TLMessageMediaLocation
//                                  SenderId:message.from.bare
//                                      Body:msg];
//        newMessage = [self _fetchJSQMessageWithSenderId:message.from.bare
//                                            DisplayName:message.from.user
//                                                   Date:[NSDate date]
//                                                  Media:item];
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
//    avatar = [self.model.avatars objectForKey:message.senderId];
    
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
        NSLog(@"isMediaMessage");
    }
    
    return cell;
}

- (void)collectionView:(JSQMessagesCollectionView *)collectionView didDeleteMessageAtIndexPath:(NSIndexPath *)indexPath {
    [self.model.messages removeObjectAtIndex:indexPath.item];
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
        [self.model sendPicMessageWithImageData:imageData withCompletionHandler:^{
            @strongify(self);
            [JSQSystemSoundPlayer jsq_playMessageSentSound];
            [self finishSendingMessageAnimated:YES];
        }];
    };
    [self presentViewController:controller animated:YES completion:nil];
}

- (void)_sendLocAction:(UIAlertAction *)action {
    CLLocation *location = [[CLLocation alloc] initWithLatitude:37.795313 longitude:-122.393757];
    [JSQSystemSoundPlayer jsq_playMessageSentSound];
    @weakify(self);
    [self.model sendLocationMessageWithLocation:location withCompletionHandler:^{
        @strongify(self);
        [self finishSendingMessageAnimated:YES];
    }];
}

- (void)_sendVideoAction:(UIAlertAction *)action {
    [MBProgressHUD tl_showTips:@"待开发"];
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

#pragma mark - XMPPIncomingFileTransferDelegate

- (void)xmppIncomingFileTransfer:(XMPPIncomingFileTransfer *)sender didFailWithError:(NSError *)error {
    NSLog(@"%@",error);
}

//- (void)xmppIncomingFileTransfer:(XMPPIncomingFileTransfer *)sender didReceiveSIOffer:(XMPPIQ *)offer {
//    /// 允许接收
//    [self.xmppIncomingFileTransfer acceptSIOffer:offer];
//}

- (void)xmppIncomingFileTransfer:(XMPPIncomingFileTransfer *)sender didSucceedWithData:(NSData *)data named:(NSString *)name {
    //在这个方法里面，我们通过带外来传输的文件
    //因此我们的消息同步器，不会帮我们自动生成Message,因此我们需要手动存储message
    //根据文件后缀名，判断文件我们是否能够处理，如果不能处理则直接显示。
    //图片 音频 （.wav,.mp3,.mp4)
    TLLogFunc;
    //    NSString *extension = [name pathExtension];
    //    if (![@"wav" isEqualToString:extension]) {
    //        return;
    //    }
    
    // 保存data
    NSString *path = TLDocumentDirectory;
    path = [path stringByAppendingPathComponent:[XMPPStream generateUUID]];
    path = [path stringByAppendingPathExtension:@"png"];
    [data writeToFile:path atomically:YES];
    
    XMPPJID *jid = [TLXMPPManager manager].xmppStream.myJID;
    
    // 创建一个XMPPMessage对象,message必须要有from
    XMPPMessage *message = [XMPPMessage messageWithType:@"chat" to:jid];
    [message addAttributeWithName:@"from" stringValue:self.roomJID.bare];
    [message addSubject:[@(TLMessageMediaPhoto) stringValue]];
    [message addBody:path.lastPathComponent];
    
    // 保存消息记录
    XMPPMessageArchivingCoreDataStorage *xmppMessageArchivingCoreDataStorage = [TLXMPPManager manager].xmppMessageArchivingCoreDataStorage;
    XMPPStream *xmppStream = [TLXMPPManager manager].xmppStream;
    
    // 这句 执行完毕会发送通知，然后更新相应的历史消息
    [xmppMessageArchivingCoreDataStorage archiveMessage:message outgoing:NO xmppStream:xmppStream];
    
//    /// 添加Cell
//    id item = [self _fetchMessageMedia:TLMessageMediaPhoto
//                              SenderId:message.from.bare
//                                  Body:path];
//    JSQMessage *newMessage = [self _fetchJSQMessageWithSenderId:message.from.bare
//                                                    DisplayName:message.from.user
//                                                           Date:[NSDate date]
//                                                          Media:item];
//    [self.model.messages addObject:newMessage];
//    [self.collectionView reloadData];
//    [self finishReceivingMessageAnimated:YES];
}

#pragma mark - XMPPOutgoingFileTransferDelegate

- (void)xmppOutgoingFileTransferIBBClosed:(XMPPOutgoingFileTransfer *)sender {
    TLLogFunc;
}

- (void)xmppOutgoingFileTransferDidSucceed:(XMPPOutgoingFileTransfer *)sender {
    TLLogFunc;
    
    // 保存data
    NSString *path = TLDocumentDirectory;
    path = [path stringByAppendingPathComponent:[XMPPStream generateUUID]];
    path = [path stringByAppendingPathExtension:@"png"];
    [sender.outgoingData writeToFile:path atomically:YES];
    
    
    // 这里将信息保存
    XMPPMessage *message = [XMPPMessage messageWithType:@"chat" to:self.roomJID];
    //将这个文件的发送者添加到message的from
    [message addAttributeWithName:@"from" stringValue:[TLXMPPManager manager].xmppStream.myJID.bare];
    [message addSubject:[@(TLMessageMediaPhoto) stringValue]];
    [message addBody:path.lastPathComponent];
    
    // 保存消息记录
    XMPPMessageArchivingCoreDataStorage *xmppMessageArchivingCoreDataStorage = [TLXMPPManager manager].xmppMessageArchivingCoreDataStorage;
    XMPPStream *xmppStream = [TLXMPPManager manager].xmppStream;
    [xmppMessageArchivingCoreDataStorage archiveMessage:message outgoing:YES xmppStream:xmppStream];
}

- (void)xmppOutgoingFileTransfer:(XMPPOutgoingFileTransfer *)sender didFailWithError:(NSError *)error {
    NSLog(@"%@",error);
}

#pragma mark - Getter

- (GroupChatModel *)model {
    if (!_model) {
        _model = [[GroupChatModel alloc] initWithRoomJID:self.roomJID];
    }
    return _model;
}

- (XMPPOutgoingFileTransfer *)xmppOutgoingFileTransfer {
    if (!_xmppOutgoingFileTransfer) {
        _xmppOutgoingFileTransfer = [[XMPPOutgoingFileTransfer alloc] initWithDispatchQueue:dispatch_get_global_queue(0, 0)];
        [_xmppOutgoingFileTransfer activate:[TLXMPPManager manager].xmppStream];
        [_xmppOutgoingFileTransfer addDelegate:self delegateQueue:dispatch_get_main_queue()];
    }
    return _xmppOutgoingFileTransfer;
}

@end
