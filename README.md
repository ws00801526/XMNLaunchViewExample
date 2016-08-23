# XMNLaunchViewExample
基于YYWebImage封装的 启动图显示,自定义显示网络图片,本地图片,GIF等


## 使用方法


```

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


```