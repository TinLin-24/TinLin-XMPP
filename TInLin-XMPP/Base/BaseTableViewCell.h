//
//  BaseTableViewCell.h
//  Demo
//
//  Created by TinLin on 2018/7/4.
//  Copyright © 2018年 TinLin. All rights reserved.
//

#import <UIKit/UIKit.h>

static NSString *const BaseTableViewCellID = @"BaseTableViewCell";

@interface BaseTableViewCell : UITableViewCell

+ (instancetype)cellWithTableView:(UITableView *)tableView;

+ (instancetype)cellWithTableView:(UITableView *)tableView reuseIdentifier:(NSString *)reuseIdentifier;

+ (instancetype)cellWithTableView:(UITableView *)tableView Style:(UITableViewCellStyle)style;

+ (instancetype)cellWithTableView:(UITableView *)tableView reuseIdentifier:(NSString *)reuseIdentifier Style:(UITableViewCellStyle)style;

/* 测试 Cell 重用 */
+ (instancetype)cellWithTableView:(UITableView *)tableView indexPath:(NSInteger)row;

#pragma mark - 

/* 设置 */
- (void)_setup;
/* 设置子视图 */
- (void)_setupSubViews;
/* 布局子视图 */
- (void)_makeSubViewsConstraints;

#pragma mark -

+ (CGFloat)cellHeightWithModel:(id)model;

- (void)configText:(NSString *)text;

- (void)configModel:(id)model;

@end
