//
//  AddFriendViewController.m
//  TinLin-XMPP
//
//  Created by Mac on 2018/12/21.
//  Copyright © 2018 xinchenglong. All rights reserved.
//

#import "AddFriendViewController.h"

@interface AddFriendViewController ()

//
@property (nonatomic, strong)UITextField *userNameTextField;
//
@property (nonatomic, strong)UIButton *addBtn;

@end

@implementation AddFriendViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)configure {
    [super configure];
    
    self.title = @"添加好友";
    
    [self _setupSubViews];
}

- (void)_setupSubViews {
    UITextField *userNameTextField = [[UITextField alloc] init];
    userNameTextField.font = TLFont(15.f, NO);
    userNameTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
    userNameTextField.layer.borderColor = BorderColor.CGColor;
    userNameTextField.layer.borderWidth = 1.f;
    userNameTextField.layer.cornerRadius = 6.f;
    userNameTextField.placeholder = @"用户名";
    [self.view addSubview:userNameTextField];
    self.userNameTextField = userNameTextField;
    
    UIButton *addBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [addBtn setTitle:@"添加" forState:UIControlStateNormal];
    [addBtn setBackgroundColor:MainColor];
    addBtn.layer.cornerRadius = 6.f;
    [self.view addSubview:addBtn];
    self.addBtn = addBtn;
    
    [userNameTextField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(100.f);
        make.left.equalTo(self.view).offset(20.f);
        make.right.equalTo(self.view).offset(-20.f);
        make.height.mas_equalTo(40.f);
    }];
    
    [addBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.height.equalTo(userNameTextField);
        make.top.equalTo(userNameTextField.mas_bottom).offset(15.f);
    }];
    
    [addBtn addTarget:self action:@selector(addBtnClick:) forControlEvents:UIControlEventTouchUpInside];
}

#pragma mark - Action

- (void)addBtnClick:(UIButton *)sender {
    if (TLStringIsEmpty(self.userNameTextField.text)) {
        [MBProgressHUD tl_showTips:@"输入用户名"];
        return;
    }
    XMPPJID *user = [XMPPJID jidWithUser:self.userNameTextField.text
                                  domain:bXMPP_domain
                                resource:bXMPP_resource];
    [[TLXMPPManager manager].xmppRoster addUser:user withNickname:@"好友"];
    [self.navigationController popViewControllerAnimated:YES];
}


@end
