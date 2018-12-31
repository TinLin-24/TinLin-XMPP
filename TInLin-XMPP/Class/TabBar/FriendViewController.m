//
//  FriendViewController.m
//  TinLin-XMPP
//
//  Created by Mac on 2018/12/19.
//  Copyright © 2018 xinchenglong. All rights reserved.
//

#import "FriendViewController.h"
#import "AddFriendViewController.h"

#import "BaseTableViewCell.h"

@interface FriendViewController ()<TLRosterDelegate>

@end

@implementation FriendViewController

- (instancetype)init
{
    self = [super init];
    if (self) {
        [TLXMPPManager manager].rosterDelegate = self;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)configure {
    [super configure];
    
    self.title = @"好友";
    
    [self _setup];
    [self _setupSubViews];
}

- (void)_setup {
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:TLImageNamed(@"friendadd") style:UIBarButtonItemStylePlain target:self action:@selector(_addFriendAction:)];
}

- (void)_setupSubViews {
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
}

#pragma mark - Action

- (void)_addFriendAction:(UIBarButtonItem *)item {
    AddFriendViewController *viewController = [[AddFriendViewController alloc] init];
    viewController.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:viewController animated:YES];
}

#pragma mark - TLRosterDelegate

- (void)rosterDidChange {
    // 从存储器中取出我得好友数组，更新数据源
    [self.dataSource removeAllObjects];
    [self.dataSource addObjectsFromArray:[TLXMPPManager manager].xmppRosterMemoryStorage.sortedUsersByName];
    [self.tableView reloadData];
}

#pragma mark - Cell

- (UITableViewCell *)tableView:(UITableView *)tableView dequeueReusableCellWithIdentifier:(NSString *)identifier forIndexPath:(NSIndexPath *)indexPath {
    return [BaseTableViewCell cellWithTableView:tableView reuseIdentifier:BaseTableViewCellID];
}

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath withObject:(id)object {
    XMPPUserMemoryStorageObject *userMemoryStorageObject = self.dataSource[indexPath.row];
    cell.textLabel.text = userMemoryStorageObject.jid.user;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
}

@end
