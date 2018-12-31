//
//  MainViewController.m
//  TinLin-XMPP
//
//  Created by Mac on 2018/12/19.
//  Copyright © 2018 xinchenglong. All rights reserved.
//

#import "MainViewController.h"

@interface MainViewController ()

@end

@implementation MainViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    [[TLXMPPManager manager] loginWithJID:nil andPassword:nil];
}

- (void)configure {
    [super configure];
    
    [self _setupSubViews];
}

///
- (void)_setupSubViews {
    
}

@end
