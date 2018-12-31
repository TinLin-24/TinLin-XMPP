//
//  BaseTableViewCell.m
//  Demo
//
//  Created by TinLin on 2018/7/4.
//  Copyright © 2018年 TinLin. All rights reserved.
//

#import "BaseTableViewCell.h"

@interface BaseTableViewCell()

@end

@implementation BaseTableViewCell

/**
 调用这些类方法时是使用 子类调用
 */
+ (instancetype)cellWithTableView:(UITableView *)tableView{
    return [self cellWithTableView:tableView Style:UITableViewCellStyleDefault];
}

+ (instancetype)cellWithTableView:(UITableView *)tableView reuseIdentifier:(NSString *)reuseIdentifier{
    return [self cellWithTableView:tableView reuseIdentifier:reuseIdentifier Style:UITableViewCellStyleDefault];
}

+ (instancetype)cellWithTableView:(UITableView *)tableView Style:(UITableViewCellStyle)style{
    NSString *reuseIdentifier=NSStringFromClass(self);
    return [self cellWithTableView:tableView reuseIdentifier:reuseIdentifier Style:style];
}

+ (instancetype)cellWithTableView:(UITableView *)tableView reuseIdentifier:(NSString *)reuseIdentifier Style:(UITableViewCellStyle)style{
    BaseTableViewCell *cell=[tableView dequeueReusableCellWithIdentifier:reuseIdentifier];
    if (!cell) {
        cell=[[self alloc]initWithStyle:style reuseIdentifier:reuseIdentifier];
    }
    return cell;
}


/**
 测试 cell重用
 */
+ (instancetype)cellWithTableView:(UITableView *)tableView indexPath:(NSInteger)row{
    NSString *identifier=NSStringFromClass(self);
    BaseTableViewCell *cell=[tableView dequeueReusableCellWithIdentifier:identifier];
    if (!cell) {
        cell=[[self alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
        cell.textLabel.text=[NSString stringWithFormat:@" %@ row:%zd",identifier,row];
    }
    return cell;
}

#pragma mark -

/**
 父类统一初始化方法
 */
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self _setup];
        [self _setupSubViews];
        [self _makeSubViewsConstraints];
    }
    return self;
}

#pragma mark - 设置子控件

- (void)_setup{
    
}
- (void)_setupSubViews{
    
}
- (void)_makeSubViewsConstraints{
    
}

+(CGFloat)cellHeightWithModel:(id)model{
    return 44.f;
}

#pragma mark -

/**
 多态
 */
- (void)configText:(NSString *)text{
    //self.textLabel.text=@"BaseTableViewCell";
}

- (void)configModel:(id)model{
    
}

#pragma mark -

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

@end
