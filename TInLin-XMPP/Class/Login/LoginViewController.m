//
//  LoginViewController.m
//  TinLin-XMPP
//
//  Created by Mac on 2018/12/19.
//  Copyright © 2018 xinchenglong. All rights reserved.
//

#import "LoginViewController.h"
#import "RegisterViewController.h"
#import "AppDelegate.h"

@interface LoginViewController ()

//
@property (nonatomic, strong)UITextField *userNameTextField;
//
@property (nonatomic, strong)UITextField *passwordTextField;
//
@property (nonatomic, strong)UIButton *loginBtn;
//
@property (nonatomic, strong)UIButton *registerBtn;

@end

@implementation LoginViewController

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
    self.userNameTextField.text = @"tinlin2";
    self.passwordTextField.text = @"112233";
//    self.userNameTextField.text = @"tinlin";
//    self.passwordTextField.text = @"1122";
    [TLNotificationDefaultCenter addObserver:self selector:@selector(_loginResult:) name:kLOGIN_RESULT object:nil];
}

///
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
    
    UIButton *loginBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [loginBtn setTitle:@"登录" forState:UIControlStateNormal];
    [loginBtn setBackgroundColor:MainColor];
    loginBtn.layer.cornerRadius = 6.f;
    [self.view addSubview:loginBtn];
    self.loginBtn = loginBtn;
    
    UIButton *registerBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [registerBtn setTitle:@"立即注册" forState:UIControlStateNormal];
    [registerBtn setTitleColor:MainColor forState:UIControlStateNormal];
    registerBtn.titleLabel.font = TLFont(14.f, NO);
    [self.view addSubview:registerBtn];
    self.registerBtn = registerBtn;
    
    [userNameTextField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(self.view);
        make.left.equalTo(self.view).offset(20.f);
        make.right.equalTo(self.view).offset(-20.f);
        make.height.mas_equalTo(40.f);
    }];
    
    [passwordTextField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.height.equalTo(userNameTextField);
        make.top.equalTo(userNameTextField.mas_bottom).offset(10.f);
    }];
    
    [loginBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.height.equalTo(userNameTextField);
        make.top.equalTo(passwordTextField.mas_bottom).offset(15.f);
    }];
    
    [registerBtn sizeToFit];
    [registerBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(loginBtn);
        make.top.equalTo(loginBtn.mas_bottom).offset(15.f);
        make.height.mas_equalTo(30.f);
    }];
    
    [loginBtn addTarget:self action:@selector(loginBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    [registerBtn addTarget:self action:@selector(registerBtnClick:) forControlEvents:UIControlEventTouchUpInside];
}

#pragma mark - Action

- (void)loginBtnClick:(UIButton *)sender {
    NSString *user = self.userNameTextField.text;
    NSString *password = self.passwordTextField.text;
    if (TLStringIsEmpty(user) || TLStringIsEmpty(password)) {
        return;
    }
    XMPPJID *JID = [XMPPJID jidWithUser:user domain:bXMPP_domain resource:bXMPP_resource];
    [[TLXMPPManager manager] loginWithJID:JID andPassword:password];
}

- (void)registerBtnClick:(UIButton *)sender {
    RegisterViewController *viewController = [[RegisterViewController alloc] init];
    [self presentViewController:viewController animated:YES completion:nil];
}

- (void)_loginResult:(NSNotification *)notification {
    if (notification.object) {
        NSLog(@"");
    }
    else {
        [self _loginSuccess];
    }
}

- (void)_loginSuccess {
    AppDelegate *delegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    [delegate changeRootViewController];
}

@end
