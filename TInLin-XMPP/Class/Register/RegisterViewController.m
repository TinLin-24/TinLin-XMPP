//
//  RegisterViewController.m
//  TinLin-XMPP
//
//  Created by Mac on 2018/12/19.
//  Copyright © 2018 xinchenglong. All rights reserved.
//

#import "RegisterViewController.h"

@interface RegisterViewController ()

//
@property (nonatomic, strong)UITextField *userNameTextField;
//
@property (nonatomic, strong)UITextField *passwordTextField;
//
@property (nonatomic, strong)UIButton *registerBtn;

@end

@implementation RegisterViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)dealloc {
    [TLNotificationDefaultCenter removeObserver:self];
}

- (void)configure {
    [super configure];
    
    [self _setupSubViews];
    
    [self _setup];
}

- (void)_setup {
    [TLNotificationDefaultCenter addObserver:self selector:@selector(_registerResult:) name:kREGIST_RESULT object:nil];
}

///
- (void)_setupSubViews {
    UIButton *backBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [backBtn setImage:TLImageNamed(@"back_black") forState:UIControlStateNormal];
    [self.view addSubview:backBtn];
    
    UITextField *userNameTextField = [[UITextField alloc] init];
    userNameTextField.font = TLFont(15.f, NO);
    userNameTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
    userNameTextField.layer.borderColor = BorderColor.CGColor;
    userNameTextField.layer.borderWidth = 1.f;
    userNameTextField.layer.cornerRadius = 6.f;
    userNameTextField.placeholder = @"用户名";
    [self.view addSubview:userNameTextField];
    self.userNameTextField = userNameTextField;
    
    UITextField *passwordTextField = [[UITextField alloc] init];
    passwordTextField.font = TLFont(15.f, NO);
    passwordTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
    passwordTextField.secureTextEntry = YES;
    passwordTextField.layer.borderColor = BorderColor.CGColor;
    passwordTextField.layer.borderWidth = 1.f;
    passwordTextField.layer.cornerRadius = 6.f;
    passwordTextField.placeholder = @"密码";
    [self.view addSubview:passwordTextField];
    self.passwordTextField = passwordTextField;
    
    UIButton *registerBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [registerBtn setTitle:@"立即注册" forState:UIControlStateNormal];
    [registerBtn setBackgroundColor:MainColor];
    registerBtn.layer.cornerRadius = 6.f;
    [self.view addSubview:registerBtn];
    self.registerBtn = registerBtn;
    
    [backBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(TLTopMargin(20.f));
        make.left.mas_equalTo(16.f);
        make.width.height.mas_equalTo(44.f);
    }];
    
    [userNameTextField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(175.f);
        make.left.equalTo(self.view).offset(20.f);
        make.right.equalTo(self.view).offset(-20.f);
        make.height.mas_equalTo(40.f);
    }];
    
    [passwordTextField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.height.equalTo(userNameTextField);
        make.top.equalTo(userNameTextField.mas_bottom).offset(10.f);
    }];
    
    [registerBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.height.equalTo(userNameTextField);
        make.top.equalTo(passwordTextField.mas_bottom).offset(15.f);
    }];
    
    [registerBtn addTarget:self action:@selector(registerBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    [backBtn addTarget:self action:@selector(backBtnClick:) forControlEvents:UIControlEventTouchUpInside];
}

#pragma mark - Action

- (void)backBtnClick:(UIButton *)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)registerBtnClick:(UIButton *)sender {
    NSString *user = self.userNameTextField.text;
    NSString *password = self.passwordTextField.text;
    if (TLStringIsEmpty(user) || TLStringIsEmpty(password)) {
        return;
    }
    XMPPJID *JID = [XMPPJID jidWithUser:user domain:bXMPP_domain resource:bXMPP_resource];
    [[TLXMPPManager manager] registerWithJID:JID andPassword:password];
}

- (void)_registerResult:(NSNotification *)notification {
    if (notification.object) {
        NSLog(@"%@",notification.object);
    }
    else {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

@end
