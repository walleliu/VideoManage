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
    NSLog(@"程序挂起");
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    NSLog(@"程序进入后台");
    RootViewController *clView = [[RootViewController alloc] init];
    self.window.rootViewController = nil;
    UINavigationController *navc =[[UINavigationController alloc] initWithRootViewController:clView];
    self.window.rootViewController = navc;
    [self.window makeKeyAndVisible];
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    NSLog(@"程序进入前台");
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    NSLog(@"程序复原(程序重新激活)");
    [self removeBlurEffectWithUIVisualEffectView];
    
    
}


- (void)applicationWillTerminate:(UIApplication *)application {
    NSLog(@"程序终止");
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}


@end
