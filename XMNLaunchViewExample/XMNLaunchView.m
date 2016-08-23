//
//  XMNLaunchView.m
//  XMNLaunchViewExample
//
//  Created by XMFraker on 16/8/22.
//  Copyright © 2016年 XMFraker. All rights reserved.
//

#import "XMNLaunchView.h"

#import "YYWebImage.h"

#import "UIImage+YYWebImage.h"
#import "UIImageView+YYWebImage.h"

@interface XMNLaunchView ()

/** 启动图,从Assets中获取 */
@property (strong, nonatomic, readonly) UIImage *launchImage;

@property (strong, nonatomic) NSURL *imageURL;
@property (weak, nonatomic)   UIWindow *window;

/** 跳过按钮 */
@property (strong, nonatomic) UIButton *skipButton;

/** 显示图片的imageView */
@property (weak, nonatomic)   YYAnimatedImageView *imageView;

/** 定时器 1秒执行一次 */
@property (strong, nonatomic) NSTimer *timer;

/** 记录显示图片的时间 */
@property (strong, nonatomic) NSDate *startDate;



@end

@implementation XMNLaunchView

- (instancetype)initWithWindow:(UIWindow *)window
                      imageURL:(NSURL *)imageURL {
    
    
    if (self = [super initWithFrame:window.bounds]) {
        
        self.imageDisplayInerval = 3.f;
        self.imageTimeoutInterval = 10.f;
        
        self.window = window;
        [self.window makeKeyAndVisible];
        
        /** 设置默认背景为启动图图片 */
        self.backgroundColor = [UIColor colorWithPatternImage:self.launchImage];
        
        /** 添加imageView */
        YYAnimatedImageView *imageView = [[YYAnimatedImageView alloc] initWithFrame:self.bounds];
        imageView.contentMode = UIViewContentModeScaleAspectFill;
        imageView.userInteractionEnabled = YES;
        imageView.tag = XMNLaunchViewDismissModeTap;
        imageView.alpha = 0.f;
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapAction:)];
        [imageView addGestureRecognizer:tap];
        [self addSubview:self.imageView = imageView];
        
        self.imageURL = imageURL;
        [self.window addSubview:self];
    }
    return self;
}


- (void)dealloc {
    
    NSLog(@"%@  dealloc",NSStringFromClass([self class]));
    [self.imageView yy_cancelCurrentImageRequest];
}

#pragma mark - Method

/**
 *  @brief 处理用户点击广告imageView
 *
 *  @param tap
 */
- (void)handleTapAction:(UITapGestureRecognizer *)tap {
    
    [self dismissLaunchViewWithMode:tap.view.tag];
}

/**
 *  @brief 处理请求图片超时
 */
- (void)handleRequestImageTimeOut {
    
    if ([NSThread isMainThread]) {
        [self dismissLaunchViewWithMode:XMNLaunchViewDismissModeRequestOverTime];
    }else {
        __weak typeof(*&self) wSelf = self;
        dispatch_sync(dispatch_get_main_queue(), ^{
            
            __strong typeof(*&wSelf) self = wSelf;
            [self dismissLaunchViewWithMode:XMNLaunchViewDismissModeRequestOverTime];
        });
    }
}

/**
 *  @brief 处理显示图片时间到
 */
- (void)handleDisplayImageTimeOut {
    
    if ([NSThread isMainThread]) {
        [self dismissLaunchViewWithMode:XMNLaunchViewDismissModeDisplayOverTime];
    }else {
        __weak typeof(*&self) wSelf = self;
        dispatch_sync(dispatch_get_main_queue(), ^{
            
            __strong typeof(*&wSelf) self = wSelf;
            self.timer ? [self.timer invalidate] : nil;
            self.skipButton.hidden = YES;
            [self dismissLaunchViewWithMode:XMNLaunchViewDismissModeDisplayOverTime];
        });
    }
}

/**
 *  @brief 处理用户点击了skip按钮
 *
 *  @param button
 */
- (void)handleSkipAction:(UIButton *)button {
    
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(handleDisplayImageTimeOut) object:nil];
    [self dismissLaunchViewWithMode:button.tag];
}

- (void)handleTimerAction {
    
    NSTimeInterval remainTimeInveral = MAX((int)self.imageDisplayInerval - (int)[[NSDate date] timeIntervalSinceDate:self.startDate], 0);
    [self.skipButton setTitle:[NSString stringWithFormat:@"%02ds",(int)remainTimeInveral] forState:UIControlStateNormal];
    
    if (remainTimeInveral <= 0) {
        [self handleDisplayImageTimeOut];
    }
}

- (void)dismissLaunchViewWithMode:(XMNLaunchViewDismissMode)mode {
    
    [UIView animateWithDuration:.5f animations:^{
        
        self.imageView.alpha = 0.3f;
        self.imageView.transform = CGAffineTransformMakeScale(1.5f, 1.5f);
    } completion:^(BOOL finished) {
        
        [self removeFromSuperview];
        self.completedBlock ? self.completedBlock(mode) : nil;
    }];
}

#pragma mark - Setter

- (void)setImageURL:(NSURL *)imageURL {
    
    _imageURL = imageURL;
    if (_imageURL) {
        
        __weak typeof(*&self) wSelf = self;
        [self.imageView yy_setImageWithURL:_imageURL placeholder:nil options:YYWebImageOptionAvoidSetImage completion:^(UIImage * _Nullable image, NSURL * _Nonnull url, YYWebImageFromType from, YYWebImageStage stage, NSError * _Nullable error) {
           
            __strong typeof(*&wSelf) self = wSelf;
            [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(handleRequestImageTimeOut) object:nil];
            if (image) {
                
                YYImage *animatedImage = (YYImage *)image;
                if (animatedImage.animatedImageType == YYImageTypeGIF) {
                    self.imageView.animatedImage = animatedImage;
                }else {
                    self.imageView.image = [image yy_imageByResizeToSize:self.bounds.size];
                }
                [UIView animateWithDuration:.15f animations:^{
                    self.imageView.alpha = 1.f;
                } completion:^(BOOL finished) {
                    self.startDate = [NSDate date];
                    self.timer = [NSTimer scheduledTimerWithTimeInterval:1.f target:self selector:@selector(handleTimerAction) userInfo:nil repeats:YES];
                    [self addSubview:self.skipButton];
                    [self.imageView startAnimating];
                    self.backgroundColor = [UIColor clearColor];
                }];
            }else {
                self.imageView.image = self.launchImage;
                self.imageView.alpha = 1.f;
                [self dismissLaunchViewWithMode:XMNLaunchViewDismissModeRequestOverTime];
            }
        }];
    }
}

- (void)setImageTimeoutInterval:(NSTimeInterval)imageTimeoutInterval {
    
    _imageTimeoutInterval = imageTimeoutInterval;
    if (!self.imageView.image) {
        [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(handleRequestImageTimeOut) object:nil];
        [self performSelector:@selector(handleRequestImageTimeOut) withObject:nil afterDelay:imageTimeoutInterval];
    }
}

- (void)setImageDisplayInerval:(NSTimeInterval)imageDisplayInerval {
    
    _imageDisplayInerval = imageDisplayInerval;
    if (self.imageView.image) {
        [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(handleDisplayImageTimeOut) object:nil];
        [self performSelector:@selector(handleDisplayImageTimeOut) withObject:nil afterDelay:imageDisplayInerval];
        [self.skipButton setTitle:[NSString stringWithFormat:@"%02ds",(int)self.imageDisplayInerval] forState:UIControlStateNormal];
    }
}

#pragma mark - Getter

- (UIImage *)launchImage {
    
    //横屏请设置成 @"Landscape"
    NSString *viewOrientation = @"Portrait";
    NSString *launchImageName = nil;
    NSArray* imagesDict = [[[NSBundle mainBundle] infoDictionary] valueForKey:@"UILaunchImages"];
    for (NSDictionary* dict in imagesDict) {
        CGSize imageSize = CGSizeFromString(dict[@"UILaunchImageSize"]);
        if (CGSizeEqualToSize(imageSize, self.window.bounds.size) && [viewOrientation isEqualToString:dict[@"UILaunchImageOrientation"]]) {
            launchImageName = dict[@"UILaunchImageName"];
        }
    }
    return [UIImage imageNamed:launchImageName];
}

- (UIButton *)skipButton {
    
    if (!_skipButton) {
        _skipButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_skipButton setTitle:[NSString stringWithFormat:@"%02ds",(int)self.imageDisplayInerval] forState:UIControlStateNormal];
        _skipButton.layer.cornerRadius = 15.f;
        _skipButton.frame = CGRectMake(self.bounds.size.width - 16 - 60, 32, 60, 30);
        _skipButton.backgroundColor = [UIColor colorWithRed:0.f green:0.f blue:0.f alpha:.5f];
        _skipButton.tag = XMNLaunchViewDismissModeSkip;
        [_skipButton.titleLabel setFont:[UIFont systemFontOfSize:12.f]];
        [_skipButton addTarget:self action:@selector(handleSkipAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _skipButton;
}

@end
