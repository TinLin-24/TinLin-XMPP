//
//  RoomsViewController.m
//  TinLin-XMPP
//
//  Created by Mac on 2018/12/21.
//  Copyright © 2018 xinchenglong. All rights reserved.
//

#import "RoomsViewController.h"

#import "BaseTableViewCell.h"

#import "GroupChatViewController.h"
#import "TLSessionViewController.h"

@interface RoomsViewController ()<XMPPRoomDelegate>

@end

@implementation RoomsViewController

- (instancetype)init {
    self = [super init];
    if (self) {
        self.shouldPullDownToRefresh = YES;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)dealloc {
    [TLNotificationDefaultCenter removeObserver:self];
}

- (void)configure {
    [super configure];
    
    self.title = @"群聊";
    
    [self _setup];
    
    [self _fetchRooms];
    
    [TLNotificationDefaultCenter addObserver:self selector:@selector(_didFetchRooms:) name:kXMPP_GET_GROUPS object:nil];
}

- (void)_setup {
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"创建群聊" style:UIBarButtonItemStylePlain target:self action:@selector(_createRoom:)];
}

#pragma mark - Data

- (void)_fetchRooms {
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

#pragma mark - Action

- (void)_createRoom:(UIButton *)sender {
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyyMMddHHmmss"];
    NSString *currentTime = [formatter stringFromDate:[NSDate date]];
    NSString *roomId = [NSString stringWithFormat:@"%@@%@.%@",currentTime,bXMPP_subdomain,bXMPP_domain];
    
    XMPPJID *roomJID = [XMPPJID jidWithString:roomId];
    
    // 如果不需要使用自带的CoreData存储，则可以使用这个。
    //    XMPPRoomMemoryStorage *xmppRoomStorage = [[XMPPRoomMemoryStorage alloc] init];
    
    // 如果使用自带的CoreData存储，可以自己创建一个继承自XMPPCoreDataStorage，并且实现了XMPPRoomStorage协议的类
    // XMPPRoomHybridStorage在类注释中，写了这只是一个实现的示例，不太建议直接使用这个。
    XMPPRoomHybridStorage *xmppRoomStorage = [XMPPRoomHybridStorage sharedInstance];
    
    XMPPRoom *xmppRoom = [[XMPPRoom alloc] initWithRoomStorage:xmppRoomStorage jid:roomJID dispatchQueue:dispatch_get_main_queue()];
    
    [xmppRoom activate:[TLXMPPManager manager].xmppStream];
    [xmppRoom addDelegate:self delegateQueue:dispatch_get_main_queue()];
    
    [xmppRoom joinRoomUsingNickname:@"TinLin" history:nil password:nil];
}

- (void)_didFetchRooms:(NSNotification *)notification {
    [self.dataSource addObjectsFromArray:notification.object];
    [self reloadData];
    [self.tableView.mj_header endRefreshing];
}

#pragma mark - XMPPRoomDelegate

- (void)xmppRoomDidCreate:(XMPPRoom *)sender {
    TLLogFunc;
    [sender fetchConfigurationForm];
}

- (void)xmppRoomDidJoin:(XMPPRoom *)sender {
    [self _setupNewRoom:sender];
    NSString *message = [NSString stringWithFormat:@"群<%@>已创建完成",sender.roomJID.user];
    [MBProgressHUD tl_showTips:message];
    XMPPJID *jid = [XMPPJID jidWithUser:@"tinlin2" domain:bXMPP_domain resource:bXMPP_resource];
    [sender inviteUser:jid withMessage:@"正大光明"];
}

- (void)xmppRoomDidLeave:(XMPPRoom *)sender {
    TLLogFunc;
}

- (void)xmppRoomDidDestroy:(XMPPRoom *)sender {
    TLLogFunc;
}

- (void)xmppRoom:(XMPPRoom *)sender didFetchConfigurationForm:(NSXMLElement *)configForm {
    NSLog(@"configForm:%@",configForm);
}

// 收到禁止名单列表
- (void)xmppRoom:(XMPPRoom *)sender didFetchBanList:(NSArray *)items {
    TLLogFunc;
}

// 收到成员名单列表
- (void)xmppRoom:(XMPPRoom *)sender didFetchMembersList:(NSArray *)items {
    TLLogFunc;
}

// 收到主持人名单列表
- (void)xmppRoom:(XMPPRoom *)sender didFetchModeratorsList:(NSArray *)items {
    TLLogFunc;
}

- (void)xmppRoom:(XMPPRoom *)sender didNotFetchBanList:(XMPPIQ *)iqError {
    TLLogFunc;
}

- (void)xmppRoom:(XMPPRoom *)sender didNotFetchMembersList:(XMPPIQ *)iqError {
    TLLogFunc;
}

- (void)xmppRoom:(XMPPRoom *)sender didNotFetchModeratorsList:(XMPPIQ *)iqError {
    TLLogFunc;
}

#pragma mark - Private

- (void)_setupNewRoom:(XMPPRoom *)xmppRoom {
    //     <x xmlns='jabber:x:data' type='submit'>
    //       <field var='FORM_TYPE'>
    //         <value>http://jabber.org/protocol/muc#roomconfig</value>
    //       </field>
    //       <field var='muc#roomconfig_roomname'>
    //         <value>A Dark Cave</value>
    //       </field>
    //       <field var='muc#roomconfig_enablelogging'>
    //         <value>0</value>
    //       </field>
    //       ...
    //     </x>
    
    /*
    <x xmlns="jabber:x:data" type="submit">
     <field var="FORM_TYPE"><value>http://jabber.org/protocol/muc#roomconfig</value></field>
     <field var="muc#roomconfig_persistentroom"><value>1</value></field>
     <field var="muc#roomconfig_maxusers"><value>100</value></field>
     <field var="muc#roomconfig_changesubject"><value>1</value></field>
     <field var="muc#roomconfig_publicroom"><value>0</value></field>
     <field var="muc#roomconfig_allowinvites"><value>1</value></field>
     </x>
     */
    NSXMLElement *x = [NSXMLElement elementWithName:@"x"xmlns:@"jabber:x:data"];
    [x addAttributeWithName:@"type" stringValue:@"form"];

    NSXMLElement *p = [NSXMLElement elementWithName:@"field" ];
    [p addAttributeWithName:@"var" stringValue:@"FORM_TYPE"];
    [p addChild:[NSXMLElement elementWithName:@"value" stringValue:@"http://jabber.org/protocol/muc#roomconfig"]];
    [x addChild:p];
    
    p = [NSXMLElement elementWithName:@"field" ];
    [p addAttributeWithName:@"var"stringValue:@"muc#roomconfig_moderatedroom"];//
    [p addChild:[NSXMLElement elementWithName:@"value" stringValue:@"0"]];
    [x addChild:p];
    
    p = [NSXMLElement elementWithName:@"field" ];
    [p addAttributeWithName:@"var"stringValue:@"muc#roomconfig_publicroom"];//
    [p addChild:[NSXMLElement elementWithName:@"value" stringValue:@"0"]];
    [x addChild:p];
    
    p = [NSXMLElement elementWithName:@"field" ];
    [p addAttributeWithName:@"var"stringValue:@"muc#roomconfig_persistentroom"];//永久房间
    [p addChild:[NSXMLElement elementWithName:@"value" stringValue:@"1"]];
    [x addChild:p];
    
    p = [NSXMLElement elementWithName:@"field" ];
    [p addAttributeWithName:@"var"stringValue:@"muc#roomconfig_maxusers"];//最大用户
    [p addChild:[NSXMLElement elementWithName:@"value" stringValue:@"100"]];
    [x addChild:p];
    
    p = [NSXMLElement elementWithName:@"field" ];
    [p addAttributeWithName:@"var"stringValue:@"muc#roomconfig_changesubject"];//允许改变主题
    [p addChild:[NSXMLElement elementWithName:@"value" stringValue:@"1"]];
    [x addChild:p];
    
    p = [NSXMLElement elementWithName:@"field" ];
    [p addAttributeWithName:@"var"stringValue:@"muc#roomconfig_publicroom"];//公共房间
    [p addChild:[NSXMLElement elementWithName:@"value" stringValue:@"0"]];
    [x addChild:p];
    
    p = [NSXMLElement elementWithName:@"field" ];
    [p addAttributeWithName:@"var"stringValue:@"muc#roomconfig_allowinvites"];//允许邀请
    [p addChild:[NSXMLElement elementWithName:@"value" stringValue:@"1"]];
    [x addChild:p];
    
    [xmppRoom configureRoomUsingOptions:x];

}

#pragma mark - Cell

- (UITableViewCell *)tableView:(UITableView *)tableView dequeueReusableCellWithIdentifier:(NSString *)identifier forIndexPath:(NSIndexPath *)indexPath {
    return [BaseTableViewCell cellWithTableView:tableView reuseIdentifier:BaseTableViewCellID];
}

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath withObject:(id)object {
    DDXMLElement *item = (DDXMLElement *)object;
    NSString *text = [NSString stringWithFormat:@"房间名:%@",[item attributeForName:@"name"].stringValue];
    cell.textLabel.text = text;
    cell.detailTextLabel.text = [item attributeForName:@"jid"].stringValue;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    DDXMLElement *item = (DDXMLElement *)self.dataSource[indexPath.row];
    XMPPJID *roomJID = [XMPPJID jidWithString:[item attributeForName:@"jid"].stringValue];
    if (!roomJID) {
        return;
    }
//    TLSessionViewController *viewController = [[TLSessionViewController alloc] init];
//    viewController.hidesBottomBarWhenPushed = YES;
//    viewController.chatJID = roomJID;

    GroupChatViewController *viewController = [[GroupChatViewController alloc] init];
    viewController.hidesBottomBarWhenPushed = YES;
    viewController.roomJID = roomJID;
    [self.navigationController pushViewController:viewController animated:YES];
}

#pragma mark - Refresh

- (void)tableViewDidTriggerHeaderRefresh {
    [self.dataSource removeAllObjects];
    [self _fetchRooms];
}

#pragma mark - Mark-设置群组的信息

/**
 设置群组的信息
        参数                                类型            说明
 muc#roomconfig_roomname                text-single     群名称
 muc#roomconfig_roomdesc                text-single     群的简短描述
 muc#roomconfig_changesubject           boolean         是否允许群成员更改房间的主题
 muc#roomconfig_allowinvites            boolean         是否允许邀请其他人进群
 muc#roomconfig_maxusers                list-single     群成员的最大数量
 muc#roomconfig_presencebroadcast       list-multi      我也不知道干啥的
 muc#roomconfig_publicroom              boolean         群是否是公共的（在获取自己的群列表时，会获取到自己加入的群和公共的群）
 muc#roomconfig_persistentroom          boolean         群是否是永久的
 muc#roomconfig_moderatedroom           boolean         房间是适度的(我猜测是标识临时群)
 muc#roomconfig_membersonly             boolean         是否只对群成员开放
 muc#roomconfig_passwordprotectedroom   boolean         是否为群设置了密码，如果设置了密码，需要填写密码才能加群
 muc#roomconfig_roomsecret              text-private    群密码
 muc#roomconfig_whois                   list-single     谁可以看到成员Jid
 muc#roomconfig_roomadmins              jid-multi       设置哪些人为管理员
 muc#roomconfig_roomowners              jid-multi       设置哪些人为群拥有者（不知道干啥的）
 x-muc#roomconfig_canchangenick         boolean         是否允许群成员修改自己的群昵称
 x-muc#roomconfig_registration          boolean         是否允许用户注册到房间
 */

@end
