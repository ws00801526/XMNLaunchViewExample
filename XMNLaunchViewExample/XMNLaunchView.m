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

/** 跳过按钮 */
@property (strong, nonatomic) UIButton *skipButton;

/** 显示图片的imageView */
@property (weak, nonatomic)   YYAnimatedImageView *imageView;

/** 定时器 1秒执行一次 */
@property (strong, nonatomic) NSTimer *timer;

/** 记录显示图片的时间 */
@property (strong, nonatomic) NSDate *startDate;

@property (weak, nonatomic)   UIWindow *window;

@property (strong, nonatomic) YYWebImageManager *imageManager;


@end

@implementation XMNLaunchView
@synthesize placeholder = _placeholder;

- (instancetype)initWithWindow:(UIWindow *)window
                      imageURL:(NSURL *)imageURL {
    
    
    if (self = [super initWithFrame:window.bounds]) {
        
        self.window = window;
        self.imageURL = imageURL;
        [self setup];
        [self setupUI];
        
        [self loadImage];
    }
    return self;
}

- (void)dealloc {
    
    NSLog(@"%@  dealloc",NSStringFromClass([self class]));
    [self.imageView yy_cancelCurrentImageRequest];
}

#pragma mark - Method


- (void)setup {
    
    NSOperationQueue *queue = [NSOperationQueue new];
    if ([queue respondsToSelector:@selector(setQualityOfService:)]) {
        queue.qualityOfService = NSQualityOfServiceBackground;
    }
    self.imageManager = [[YYWebImageManager alloc] initWithCache:[YYImageCache sharedCache] queue:queue];
    self.imageManager.timeout = self.imageTimeoutInterval;
    
    self.imageDisplayInerval = 3.f;
    self.imageTimeoutInterval = 5.f;
}

- (void)setupUI {
    
    /** 注意此处 要先调用window makeKeyAndVisible 将window.rootViewController.view渲染出来 */
    [self.window makeKeyAndVisible];
    
    /** 设置默认背景为启动图图片 */
    self.backgroundColor = [UIColor colorWithPatternImage:self.placeholder];
    
    /** 添加imageView */
    YYAnimatedImageView *imageView = [[YYAnimatedImageView alloc] initWithFrame:self.bounds];
    imageView.contentMode = UIViewContentModeScaleAspectFill;
    imageView.userInteractionEnabled = YES;
    imageView.tag = XMNLaunchViewDismissModeTap;
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapAction:)];
    [imageView addGestureRecognizer:tap];
    [self addSubview:self.imageView = imageView];
    
    [self.window addSubview:self];
}

- (void)loadImage {
    
    if (self.imageURL) {
        /** 取消之前的图片下载 */
        [self.imageView yy_cancelCurrentImageRequest];
    
        __weak typeof(*&self) wSelf = self;
        
        [self.imageView yy_setImageWithURL:self.imageURL placeholder:self.placeholder options:YYWebImageOptionSetImageWithFadeAnimation manager:self.imageManager progress:nil transform:nil completion:^(UIImage * _Nullable image, NSURL * _Nonnull url, YYWebImageFromType from, YYWebImageStage stage, NSError * _Nullable error) {
            
            __strong typeof(*&wSelf) self = wSelf;
            /** 忽略被取消的请求 */
            if (stage == YYWebImageStageCancelled) {
                return ;
            }
            
            if (image && !error) {
                
                YYImage *animatedImage = (YYImage *)image;
                if (animatedImage.animatedImageType == YYImageTypeGIF) {
                    self.imageView.animatedImage = animatedImage;
                }else {
                    self.imageView.image = [image yy_imageByResizeToSize:self.bounds.size];
                }
                
                self.startDate = [NSDate date];
                self.timer = [NSTimer scheduledTimerWithTimeInterval:1.f target:self selector:@selector(handleTimerAction) userInfo:nil repeats:YES];
                [self addSubview:self.skipButton];
                [self.imageView startAnimating];
                self.backgroundColor = [UIColor clearColor];
            }else {
                [self callCompletedBlockWithMode:XMNLaunchViewDismissModeImageFailed];
            }
        }];
    }
}

/**
 *  @brief 处理用户点击广告imageView
 *
 *  @param tap
 */
- (void)handleTapAction:(UITapGestureRecognizer *)tap {
    
    [self callCompletedBlockWithMode:XMNLaunchViewDismissModeTap];
}


/**
 *  @brief 处理用户点击了skip按钮
 *
 *  @param button
 */
- (void)handleSkipAction:(UIButton *)button {
    
    self.timer ? [self.timer invalidate] : nil;
    [self callCompletedBlockWithMode:XMNLaunchViewDismissModeSkip];
}

- (void)handleTimerAction {
    
    NSTimeInterval remainTimeInveral = MAX((int)self.imageDisplayInerval - (int)[[NSDate date] timeIntervalSinceDate:self.startDate], 0);
    [self.skipButton setTitle:[NSString stringWithFormat:@"%02ds",(int)remainTimeInveral] forState:UIControlStateNormal];
    
    if (remainTimeInveral <= 0) {
        [self callCompletedBlockWithMode:XMNLaunchViewDismissModeDisplayTimeout];
    }
}

- (void)callCompletedBlockWithMode:(XMNLaunchViewDismissMode)mode {
    
    __weak typeof(*&self) wSelf = self;
    if ([NSThread isMainThread]) {
        self.completedBlock ? self.completedBlock(wSelf, mode) : nil;
    }else {
        dispatch_async(dispatch_get_main_queue(), ^{
            self.completedBlock ? self.completedBlock(wSelf, mode) : nil;
        });
    }
}

- (void)dismissLaunchView {

    self.timer ? [self.timer invalidate] : nil;
    self.skipButton.hidden = YES;
    
    [UIView animateWithDuration:.5f animations:^{
        
        self.alpha = 0.3f;
        self.transform = CGAffineTransformMakeScale(1.5f, 1.5f);
    } completion:^(BOOL finished) {
        
        [self removeFromSuperview];
    }];
}

#pragma mark - Setter

- (void)setImageTimeoutInterval:(NSTimeInterval)imageTimeoutInterval {
    
    _imageTimeoutInterval = imageTimeoutInterval;
    if (self.imageManager) {
        self.imageManager.timeout = imageTimeoutInterval;
    }
    
    /** 重新设置了timeout属性,重新加载图片 */
    [self loadImage];
}

- (void)setImageDisplayInerval:(NSTimeInterval)imageDisplayInerval {
    
    _imageDisplayInerval = imageDisplayInerval;
    [self.skipButton setTitle:[NSString stringWithFormat:@"%02ds",(int)self.imageDisplayInerval] forState:UIControlStateNormal];
    if (self.timer) {
        [self.timer invalidate];
        self.startDate = [NSDate date];
        self.timer = [NSTimer scheduledTimerWithTimeInterval:1.f target:self selector:@selector(handleTimerAction) userInfo:nil repeats:YES];
    }
}

- (void)setImageURL:(NSURL *)imageURL {
    
    if (imageURL && _imageURL != imageURL) {

        /** 重新加载新的图片 */
        _imageURL = imageURL;
        [self loadImage];
    }
}

- (void)setPlaceholder:(UIImage *)placeholder {
    
    _placeholder = placeholder;
    [self loadImage];
}

#pragma mark - Getter

- (UIImage *)placeholder {
    
    if (_placeholder) {
        return _placeholder;
    }

    NSString *viewOrientation;
    switch ([UIApplication sharedApplication].statusBarOrientation) {
        case UIInterfaceOrientationLandscapeLeft:
        case UIInterfaceOrientationLandscapeRight:
            viewOrientation = @"Landscape";
            break;
        case UIInterfaceOrientationPortrait:
        case UIInterfaceOrientationPortraitUpsideDown:
        default:
            viewOrientation = @"Portrait";
            break;
    }
    NSString *launchImageName = nil;
    NSArray* imagesDict = [[[NSBundle mainBundle] infoDictionary] valueForKey:@"UILaunchImages"];
    for (NSDictionary* dict in imagesDict) {
        CGSize imageSize = CGSizeFromString(dict[@"UILaunchImageSize"]);
        if (CGSizeEqualToSize(imageSize, self.window.bounds.size) && [viewOrientation isEqualToString:dict[@"UILaunchImageOrientation"]]) {
            launchImageName = dict[@"UILaunchImageName"];
        }
    }
    return launchImageName ? [UIImage imageNamed:launchImageName] : nil;
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
