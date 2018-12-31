//
//
//  MBProgressHUD+TLExtension.m
//
//  Created by apple on 16/5/10.
//  Copyright © 2016年 TinLin. All rights reserved.
//

#import <MBProgressHUD/MBProgressHUD.h>

@interface MBProgressHUD (TLExtension)

/// in window
/// 提示信息
+ (MBProgressHUD *)tl_showTips:(NSString *)tipStr;

/// 提示错误
+ (MBProgressHUD *)tl_showErrorTips:(NSError *)error;

/// 进度view
+ (MBProgressHUD *)tl_showProgressHUD:(NSString *)titleStr;

/// 隐藏hud
+ (void)tl_hideHUD;



/// in special view
/// 提示信息
+ (MBProgressHUD *)tl_showTips:(NSString *)tipStr addedToView:(UIView *)view;
/// 提示错误
+ (MBProgressHUD *)tl_showErrorTips:(NSError *)error addedToView:(UIView *)view;
/// 进度view
+ (MBProgressHUD *)tl_showProgressHUD:(NSString *)titleStr addedToView:(UIView *)view;

/// 隐藏hud
+ (void)tl_hideHUDForView:(UIView *)view;


@end
