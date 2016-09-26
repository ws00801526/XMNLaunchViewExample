//
//  AppDelegate.m
//  XMNLaunchViewExample
//
//  Created by XMFraker on 16/8/22.
//  Copyright © 2016年 XMFraker. All rights reserved.
//

#import "AppDelegate.h"

#import "ViewController.h"


#import "YYWebImage.h"



#define kTestOCLaunchView  1


#if kTestOCLaunchView
#import "XMNLaunchView.h"
#else
#import "XMNLaunchViewExample-swift.h"
#endif

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
    
    /** 加载图片失败的地址 */
//    imageURL = [NSURL URLWithString:@"http://failed.png"];
    
    /** 本地图片 */
//    imageURL = [[NSBundle mainBundle] URLForResource:@"qidong" withExtension:@"gif"];
    
    /** gif图片 */
//    imageURL = [NSURL URLWithString:@"https://d13yacurqjgara.cloudfront.net/users/288987/screenshots/1913272/depressed-slurp-cycle.gif"];
    
    /** 测试使用,移除缓存,查看没有缓存下 显示效果 */
    [[YYWebImageManager sharedManager].cache removeImageForKey:[[YYWebImageManager sharedManager] cacheKeyForURL:imageURL]];
    
#if kTestOCLaunchView
    [self setupLaunchViewOCWithURL:imageURL];
#else
    [self setupLaunchViewSwiftWithURL:imageURL];
#endif

    return YES;
}



#if kTestOCLaunchView

- (void)setupLaunchViewOCWithURL:(NSURL *)URL {
    
    XMNLaunchView *view = [[XMNLaunchView alloc] initWithWindow:self.window
                                                       imageURL:URL];
    
    [view setCompletedBlock:^(XMNLaunchView *launchView, XMNLaunchViewDismissMode mode) {
        
        [launchView dismissLaunchView];
    }];
}

#else

/**
 *  @brief 测试swift版本launchView
 *
 *  @param URL
 */
- (void)setupLaunchViewSwiftWithURL:(NSURL *)URL {
    
    XMNLaunchView *launchView = [[XMNLaunchView alloc] initWithDisplayWindow:self.window imageURL:URL];
    
}
#endif


@end
