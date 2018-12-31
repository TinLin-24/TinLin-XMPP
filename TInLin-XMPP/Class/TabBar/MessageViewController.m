//
//  MessageViewController.m
//  TinLin-XMPP
//
//  Created by Mac on 2018/12/19.
//  Copyright © 2018 xinchenglong. All rights reserved.
//

#import "MessageViewController.h"
#import "TLSessionViewController.h"

#import "BaseTableViewCell.h"

@interface MessageViewController ()<NSFetchedResultsControllerDelegate>

@end

@implementation MessageViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)configure {
    [super configure];
    
    [self _setup];
    
    [self _fetchRosterStorage];
}

- (void)_setup {
    self.title = @"会话";
    
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
}

#pragma mark - Data

- (void)_fetchRosterStorage {
    // 1.上下文 关联XMPPRoster.sqlite文件
    NSManagedObjectContext *rosterContext = [TLXMPPManager manager].xmppRosterStorage.mainThreadManagedObjectContext;
    // 2.Request 请求查询哪张表
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"XMPPUserCoreDataStorageObject"];
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc]
                                        initWithKey:@"jidStr" ascending:NO];
    NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor,nil];
    [request setSortDescriptors:sortDescriptors];
    //这里你可以给request添加其他条件
    // 3.执行请求
    NSFetchedResultsController *resultsContr = [[NSFetchedResultsController alloc] initWithFetchRequest:request managedObjectContext:rosterContext sectionNameKeyPath:nil cacheName:nil];
    resultsContr.delegate = self;
    NSError *err = nil;
    // 3.2执行
    [resultsContr performFetch:&err];
    
    [self.dataSource addObjectsFromArray:resultsContr.fetchedObjects];
}

#pragma mark - Cell

- (UITableViewCell *)tableView:(UITableView *)tableView dequeueReusableCellWithIdentifier:(NSString *)identifier forIndexPath:(NSIndexPath *)indexPath {
    BaseTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:BaseTableViewCellID];
    if (cell == nil) {
        cell = [[BaseTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:BaseTableViewCellID];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    return cell;
}

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath withObject:(id)object {
    BaseTableViewCell *listCell = (BaseTableViewCell *)cell;
    XMPPUserCoreDataStorageObject *obj = (XMPPUserCoreDataStorageObject *)object;
    listCell.textLabel.text = obj.jid.user;
    listCell.detailTextLabel.text = obj.isOnline ? @"在线" : @"离线";
    if (obj.unreadMessages > 0) {
        NSLog(@"unreadMessages:%@条",obj.unreadMessages);
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 70.f;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    XMPPUserCoreDataStorageObject *obj = self.dataSource[indexPath.row];
    if (!obj) {
        return;
    }
    TLSessionViewController *vc = [[TLSessionViewController alloc] init];
    vc.hidesBottomBarWhenPushed = YES;
    vc.chatJID = obj.jid;
    [self.navigationController pushViewController:vc animated:YES];
}

@end
