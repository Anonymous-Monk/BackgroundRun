//
//  AppDelegate.m
//  BackgroundRun
//
//  Created by zero on 2017/2/4.
//  Copyright © 2017年 zero-zhou. All rights reserved.
//

#import "AppDelegate.h"

@interface AppDelegate ()
@property(nonatomic,assign)UIBackgroundTaskIdentifier bgTask;

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    return YES;
}


- (void)applicationWillResignActive:(UIApplication *)application {
    //在AppDelegate中添加 UIBackgroundTaskIdentifier bgTask;
    _bgTask = [application beginBackgroundTaskWithExpirationHandler:^{
        //10分钟后执行这里，应该进行一些清理工作，如断开和服务器的链接等
        [application endBackgroundTask:_bgTask];
        _bgTask = UIBackgroundTaskInvalid;
    }];
    
    if (_bgTask == UIBackgroundTaskInvalid) {
        NSLog(@"failed to start background task");
    }
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        NSTimeInterval timeRemain = 0;
        do {
            [NSThread sleepForTimeInterval:5];
            if (_bgTask != UIBackgroundTaskInvalid) {
                timeRemain = [application backgroundTimeRemaining];
                NSLog(@"Time remaining:%f",timeRemain);
            }
        } while (_bgTask != UIBackgroundTaskInvalid && timeRemain > 0); //如果改为timeRemain > 5 * 60 ,表示后台运行五分钟
        //done
        
        //如果没到10分钟，也可以主动关闭后台任务，但这里需要在主线程中执行，否则会出错
        dispatch_async(dispatch_get_main_queue(), ^{
            if (_bgTask != UIBackgroundTaskInvalid) {
                //和上面 的10分钟后执行的代码一样
                [application endBackgroundTask:_bgTask];
                _bgTask = UIBackgroundTaskInvalid;
            }
        });
        
    });
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    //如果没到10分钟又打开了app，结束后台任务
    if (_bgTask != UIBackgroundTaskInvalid) {
        [application endBackgroundTask:_bgTask];
        _bgTask = UIBackgroundTaskInvalid;
    }
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
