//
//  AppDelegate.m
//  CLPlayerDemo
//
//  Created by JmoVxia on 2016/11/1.
//  Copyright © 2016年 JmoVxia. All rights reserved.
//

#import "AppDelegate.h"
#import "RootViewController.h"

@interface AppDelegate ()
@property (strong,nonatomic)UIView*effectView;
@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    RootViewController *clView = [[RootViewController alloc] init];
    UINavigationController *navc =[[UINavigationController alloc] initWithRootViewController:clView];
    self.window.rootViewController = navc;
    [self.window makeKeyAndVisible];
    return YES;
}
- (UIView *)effectView {
    if (!_effectView) {
        // 毛玻璃view 视图
        _effectView = [[UIView alloc] init];
        // 设置模糊透明度
        _effectView.backgroundColor = [UIColor whiteColor];
        _effectView.frame = [UIScreen mainScreen].bounds;
    }
    
    return _effectView;
}
-(void) addBlurEffectWithUIVisualEffectView {
    [[[UIApplication sharedApplication] keyWindow] addSubview:self.effectView];
}
-(void) removeBlurEffectWithUIVisualEffectView {
    [UIView animateWithDuration:0.5 animations:^{
        [self.effectView removeFromSuperview];
    }];
}
- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    [self addBlurEffectWithUIVisualEffectView];
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
    [self removeBlurEffectWithUIVisualEffectView];
    
    RootViewController *clView = [[RootViewController alloc] init];
    self.window.rootViewController = nil;
    UINavigationController *navc =[[UINavigationController alloc] initWithRootViewController:clView];
    self.window.rootViewController = navc;
    [self.window makeKeyAndVisible];
}


- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}


@end
