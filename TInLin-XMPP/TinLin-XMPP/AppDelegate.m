//
//  AppDelegate.m
//  TinLin-XMPP
//
//  Created by Mac on 2018/12/18.
//  Copyright © 2018 xinchenglong. All rights reserved.
//

#import "AppDelegate.h"
#import "FriendViewController.h"
#import "LoginViewController.h"
#import "MessageViewController.h"
#import "RoomsViewController.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    NSLog(@"%@",TLDocumentDirectory);
//    [self _defaultRootViewController];
    [self _loginRootViewController];
    return YES;
}

- (void)changeRootViewController {
    @weakify(self);
    void (^animation)(void) = ^{
        @strongify(self);
        BOOL oldState = [UIView areAnimationsEnabled];
        [UIView setAnimationsEnabled:NO];
        self.window.rootViewController = [self _defaultRootViewController];
        [UIView setAnimationsEnabled:oldState];
    };
    [UIView transitionWithView:self.window
                      duration:.5
                       options:UIViewAnimationOptionTransitionFlipFromLeft
                    animations:animation
                    completion:nil];
}

- (void)_loginRootViewController {
    UIWindow *window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    self.window = window;
    window.rootViewController = [LoginViewController new];
    [window makeKeyAndVisible];
}

/**
 正常的页面
 */
- (UIViewController *)_defaultRootViewController {
    NSArray *titles = @[@"会话",
                        @"群聊",
                        @"好友"];
    NSArray *images = @[@"cc-chat",
                        @"-qunliaorukou-2",
                        @"friend"];
    NSArray *selectedImages = @[@"cc-chat-2",
                                @"-qunliaorukou",
                                @"friend-2"];
    NSArray *vcClassArr = @[[MessageViewController class],
                            [RoomsViewController class],
                            [FriendViewController class]];
    return [self _configureRootViewControllerWithTitles:titles
                                      ImageNames:images
                                  SelectedImages:selectedImages
                                         VCClass:vcClassArr];
}

/**
 配置 UITabBarController的页面
 @param titles tabBarItem的标题
 @param images tabBarItem的默认图片
 @param selectedImages tabBarItem的选中图片
 @param vcClassArr 对应的控制器类型
 @return UITabBarController
 */
- (UIViewController *)_configureRootViewControllerWithTitles:(NSArray *)titles
                                    ImageNames:(NSArray *)images
                                SelectedImages:(NSArray *)selectedImages
                                       VCClass:(NSArray *)vcClassArr {
    
    /// UITabBarController
    UITabBarController *tabBarController = [[UITabBarController alloc] init];
    tabBarController.tabBar.tintColor = MainColor;
    tabBarController.tabBar.backgroundImage = [UIImage imageWithColor:[UIColor whiteColor]];
    tabBarController.tabBar.shadowImage = [UIImage imageWithColor:TLHexColor(@"#e5e5e5")];
    
    for (int i=0; i<titles.count; i++) {
        
        NSString *title = titles[i];
        NSString *image = images[i];
        NSString *selectedImage = selectedImages[i];
        Class vcClass = vcClassArr[i];
        
        UIViewController *viewController = [[vcClass alloc] init];
        UIViewController *navigationController = [[UINavigationController alloc]
                                                  initWithRootViewController:viewController];
        navigationController.tabBarItem.title = title;
        navigationController.tabBarItem.image = TLImageNamed(image);
        navigationController.tabBarItem.selectedImage = TLImageNamed(selectedImage);
        [tabBarController addChildViewController:navigationController];
    }
    tabBarController.selectedIndex = 2;
    return tabBarController;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}


- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}


@end
