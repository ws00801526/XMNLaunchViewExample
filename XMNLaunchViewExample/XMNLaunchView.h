//
//  XMNLaunchView.h
//  XMNLaunchViewExample
//
//  Created by XMFraker on 16/8/22.
//  Copyright © 2016年 XMFraker. All rights reserved.
//

#import <UIKit/UIKit.h>


typedef NS_ENUM(NSUInteger, XMNLaunchViewDismissMode) {
    /** 用户点击广告消失 */
    XMNLaunchViewDismissModeTap,
    /** 用户点击跳转消失 */
    XMNLaunchViewDismissModeSkip,
    /** 图片展示时间到了 */
    XMNLaunchViewDismissModeDisplayOverTime,
    /** 广告超时消失,获取图片超时消失 */
    XMNLaunchViewDismissModeRequestOverTime,
};

/**
 *  @brief 启动图后显示的加载页面
 *  可以显示本地图片,网络图片
 */
@interface XMNLaunchView : UIView


/** 图片展示的时长  默认3s */
@property (assign, nonatomic) NSTimeInterval imageDisplayInerval;
/** 图片超时时长,如果图片长时间未获取成功,则直接去下此页面  默认10s    */
@property (assign, nonatomic) NSTimeInterval imageTimeoutInterval;

/** 回调block */
@property (copy, nonatomic, nullable)   void(^completedBlock)(XMNLaunchViewDismissMode mode);

/** 显示的图片地址 */
@property (strong, nonatomic, readonly, nullable) NSURL *imageURL;
/** 显示launchView的主window */
@property (weak, nonatomic, readonly, nullable)   UIWindow *window;

/**
 *  @brief 指定初始化方法
 *
 *  @param window   显示launchView的主window
 *  @param imageURL 显示的图片地址
 *
 *  @return
 */
- (instancetype _Nonnull)initWithWindow:(UIWindow * _Nonnull)window
                               imageURL:(NSURL * _Nullable)imageURL NS_DESIGNATED_INITIALIZER;

- (instancetype __nonnull)initWithFrame:(CGRect)frame NS_UNAVAILABLE;

- (instancetype __nonnull)initWithCoder:(NSCoder * __nonnull)aDecoder NS_UNAVAILABLE;

@end
