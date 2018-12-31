//
//
//  MBProgressHUD+tlExtension.m
//
//  Created by apple on 16/5/10.
//  Copyright © 2016年 TinLin. All rights reserved.
//

#import "MBProgressHUD+TLExtension.h"

@implementation MBProgressHUD (TLExtension)

#pragma mark - Added To  window
/// 提示信息
+ (MBProgressHUD *)tl_showTips:(NSString *)tipStr
{
    return [self tl_showTips:tipStr addedToView:nil];
}

/// 提示错误
+ (MBProgressHUD *)tl_showErrorTips:(NSError *)error
{
    return [self tl_showErrorTips:error addedToView:nil];
}

/// 进度view
+ (MBProgressHUD *)tl_showProgressHUD:(NSString *)titleStr
{
    return [self tl_showProgressHUD:titleStr addedToView:nil];
}

/// hide hud
+ (void)tl_hideHUD
{
    [self tl_hideHUDForView:nil];
}


#pragma mark - Added To Special View
/// 提示信息
+ (MBProgressHUD *)tl_showTips:(NSString *)tipStr addedToView:(UIView *)view
{
    return [self _showHUDWithTips:tipStr isAutomaticHide:YES addedToView:view];
}

/// 提示错误
+ (MBProgressHUD *)tl_showErrorTips:(NSError *)error addedToView:(UIView *)view
{
    return [self _showHUDWithTips:[self _fetchTipsFromError:error] isAutomaticHide:YES addedToView:view];
}


/// 进度view
+ (MBProgressHUD *)tl_showProgressHUD:(NSString *)titleStr addedToView:(UIView *)view
{
    return [self _showHUDWithTips:titleStr isAutomaticHide:NO addedToView:view];
}

// 隐藏HUD
+ (void)tl_hideHUDForView:(UIView *)view
{
    [self hideHUDForView:[self _willShowingToViewWithSourceView:view] animated:YES];
}

#pragma mark - 辅助方法
/// 获取将要显示的view
+ (UIView *)_willShowingToViewWithSourceView:(UIView *)sourceView
{
    if (sourceView) return sourceView;
    
    sourceView =  [[UIApplication sharedApplication].delegate window];
    if (!sourceView) sourceView = [[[UIApplication sharedApplication] windows] lastObject];
    
    return sourceView;
}

+ (instancetype )_showHUDWithTips:(NSString *)tipStr isAutomaticHide:(BOOL) isAutomaticHide addedToView:(UIView *)view
{
    view = [self _willShowingToViewWithSourceView:view];
    
    /// 也可以show之前 hid掉之前的
    [self tl_hideHUDForView:view];
    
    MBProgressHUD *HUD = [MBProgressHUD showHUDAddedTo:view animated:YES];
    HUD.mode = isAutomaticHide?MBProgressHUDModeText:MBProgressHUDModeIndeterminate;
    HUD.animationType = MBProgressHUDAnimationZoom;
    HUD.label.font = isAutomaticHide?TLFont(17.f, NO):TLFont(14.f, NO);
    HUD.label.textColor = [UIColor whiteColor];
    HUD.contentColor = [UIColor whiteColor];
    HUD.label.text = tipStr;
    HUD.bezelView.layer.cornerRadius = 8.0f;
    HUD.bezelView.layer.masksToBounds = YES;
    HUD.bezelView.color = TLAlphaColor(0, 0, 0, .6f);
    HUD.bezelView.style = MBProgressHUDBackgroundStyleSolidColor;
    HUD.minSize =isAutomaticHide?CGSizeMake([UIScreen mainScreen].bounds.size.width-96.0f, 60):CGSizeMake(120, 120);
    HUD.margin = 18.2f;
    HUD.removeFromSuperViewOnHide = YES;
    if (isAutomaticHide) [HUD hideAnimated:YES afterDelay:1.0f];
    return HUD;
}


+ (NSString *)_fetchTipsFromError:(NSError *)error {
    NSString *info;
    if ([error.userInfo.allKeys containsObject:@"NSLocalizedDescription"]) {
        info=[error.userInfo objectForKey:@"NSLocalizedDescription"];
    }else {
        info=error.domain;
    }
    if([info isEqualToString:@"NSCocoaErrorDomain"]){
        info = @"找不到服务器!";
    }
    return info;
}

@end
