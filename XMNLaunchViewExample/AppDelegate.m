//
//  AppDelegate.m
//  XMNLaunchViewExample
//
//  Created by XMFraker on 16/8/22.
//  Copyright © 2016年 XMFraker. All rights reserved.
//

#import "AppDelegate.h"

#import "ViewController.h"

#import "XMNLaunchView.h"

#import "YYWebImage.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    
    /** 自定的 rootViewController */
//    ViewController *viewC = [[ViewController alloc] init];
//    viewC.view.backgroundColor = [UIColor redColor];
//    self.window.rootViewController = viewC;
    
    NSURL *imageURL = [NSURL URLWithString:@"http://img4q.duitang.com/uploads/item/201405/31/20140531174231_cA3VQ.jpeg"];
    
    /** 本地图片 */
//    imageURL = [[NSBundle mainBundle] URLForResource:@"qidong" withExtension:@"gif"];
    
    /** gif图片 */
//    imageURL = [NSURL URLWithString:@"https://d13yacurqjgara.cloudfront.net/users/288987/screenshots/1913272/depressed-slurp-cycle.gif"];
    
    /** 测试使用,移除缓存,查看没有缓存下 显示效果 */
    [[YYWebImageManager sharedManager].cache removeImageForKey:[[YYWebImageManager sharedManager] cacheKeyForURL:imageURL]];
    
    XMNLaunchView *view = [[XMNLaunchView alloc] initWithWindow:self.window
                                                       imageURL:imageURL];
    view.imageTimeoutInterval = 20.f;
    [view setCompletedBlock:^(XMNLaunchViewDismissMode mode) {
        
    }];
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
