//
//  XMNLaunchView.h
//  XMNLaunchViewExample
//
//  Created by XMFraker on 16/11/9.
//  Copyright © 2016年 XMFraker. All rights reserved.
//

#import <UIKit/UIKit.h>


typedef NS_ENUM(NSUInteger, XMNLaunchViewDismissMode) {
    
    XMNLaunchViewDismissModeDefault = 0,
    XMNLaunchViewDismissModeTap,
};

/**
 2.0版本launchView
 */
@interface XMNLaunchView : UIView


/** 未获取到imageURL链接图片之前显示的默认占位图 */
@property (strong, nonatomic, nullable) UIImage *placeholder;
/** 网络图片路径地址 */
@property (strong, nonatomic, nullable, readonly) NSURL   *imageURL;

/** 图片最大展示时间 默认3.f*/
@property (assign, nonatomic) NSTimeInterval displayTimeout;
/** 图片最大请求时间 默认5.f*/
@property (assign, nonatomic) NSTimeInterval requestTimeout;

/** 是否自动隐藏launchView
 * YES 时  当图片加载失败 时会自动dismissLaunchView
 * 默认为YES */
@property (assign, nonatomic, getter=isAutoHide) BOOL autoHide;

/** 回调block
 *
 *  除了用户手动点击加载的图片会回调此block  其他例如 图片加载失败,显示图片超时,点击图片,点击跳过按钮均不会回调此block
 *
 **/
@property (copy, nonatomic, nullable)   void(^completionBlock)(XMNLaunchView *__nonnull __weak launchView, XMNLaunchViewDismissMode mode);

/**
 获取一个XMNLaunchView实例
 
 @warning 默认XMNLaunchView的大小为[UIApplication shareApplication].keywindow.bounds
 如果在didFinishLaunchingWithOptions配置 可能keywindow为nil ,获取不到大小,需要手动指定XMNLaunchView大小
 @param placeholder 默认占位图
 @param imageURL    网络图片地址
 @return XMNLaunchView 实例
 */
- (instancetype __nonnull)initWithPlaceholder:(UIImage * __nullable)placeholder
                                     imageURL:(NSURL * __nullable)imageURL;

/**
 展示一个图片地址
 
 @param imageURL       图片网络地址
 @param requestTimeout 图片最大请求时间
 @param displayTimeout 图片最大展示时间
 */
- (void)launchImageWithURL:(NSURL * _Nullable)imageURL
            requestTimeout:(NSInteger)requestTimeout
            displayTimeout:(NSInteger)displayTimeout;

/**
 隐藏launchView,手动调用,不会回调launchView.completionBlock
 */
- (void)dismissLaunchView;

#pragma mark - Class Method

/**
 从启动图中获取当前启动图片
 
 @return 获取到的图片
 */
+ (UIImage * __nullable)launchImage;


/**
 获取window上的launchView
 
 @return XMNLaunchView 实例 or nil
 */
+ (XMNLaunchView * __nullable)launchViewOnWindow;

@end

FOUNDATION_EXPORT NSInteger kXMNLaunchViewTag;
