//
//  XMNLaunchView.m
//  XMNLaunchViewExample
//
//  Created by XMFraker on 16/11/9.
//  Copyright © 2016年 XMFraker. All rights reserved.
//

#import "XMNLaunchView.h"
#import "YYAnimatedImageView.h"

#import "YYWebImage.h"

#import "UIImage+YYWebImage.h"
#import "UIImageView+YYWebImage.h"


NSInteger kXMNLaunchViewTag = 12306;

@interface XMNLaunchView ()

@property (weak, nonatomic) YYAnimatedImageView *imageView;
@property (weak, nonatomic) UIButton *skipButton;
@property (strong, nonatomic) YYWebImageManager *imageManager;

@property (strong, nonatomic, nullable) NSURL   *imageURL;


@property (strong, nonatomic) NSTimer *countdownTimer;
@property (strong, nonatomic) NSDate *countdownDate;

@end

@implementation XMNLaunchView

#pragma mark - Life Cycle

- (instancetype)initWithPlaceholder:(UIImage *)placeholder
                           imageURL:(NSURL *)imageURL {
    
    if (self = [super initWithFrame:[UIApplication sharedApplication].keyWindow.bounds]) {
        
        NSOperationQueue *queue = [[NSOperationQueue alloc] init];
        queue.name = @"com.XMFraker.XMNLaunchView.kXMNDownloadLaunchQueue";
        if ([queue respondsToSelector:@selector(setQualityOfService:)]) {
            queue.qualityOfService = NSQualityOfServiceBackground;
        }
        self.tag = kXMNLaunchViewTag;
        
        self.imageManager = [[YYWebImageManager alloc] initWithCache:[YYImageCache sharedCache] queue:queue];
        
        self.autoHide = YES;
        self.displayTimeout = 3.f;
        self.requestTimeout = 5.f;
        self.placeholder = placeholder ? : [XMNLaunchView launchImage];
        
        [self setupUI];
        
        [self launchImageWithURL:imageURL
                  requestTimeout:self.requestTimeout
                  displayTimeout:self.displayTimeout];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    
    return [self initWithPlaceholder:nil
                            imageURL:nil];
}

- (instancetype)initWithFrame:(CGRect)frame {
    
    return [self initWithPlaceholder:nil
                            imageURL:nil];
}

#pragma mark - Method

- (void)setupUI {
    
    YYAnimatedImageView *animatedImageView = [[YYAnimatedImageView alloc] initWithFrame:self.bounds];
    animatedImageView.autoPlayAnimatedImage = YES;
    animatedImageView.userInteractionEnabled = NO;
    [self addSubview:self.imageView = animatedImageView];
    
    UITapGestureRecognizer *tapGes = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapLaunch)];
    [animatedImageView addGestureRecognizer:tapGes];
    
    UIButton *skipButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [skipButton setTitle:[NSString stringWithFormat:@"%02ds",(int)self.displayTimeout] forState:UIControlStateNormal];
    skipButton.layer.cornerRadius = 15.f;
    skipButton.frame = CGRectMake(self.bounds.size.width - 16 - 60, 32, 60, 30);
    skipButton.backgroundColor = [UIColor colorWithRed:0.f green:0.f blue:0.f alpha:.5f];
    [skipButton.titleLabel setFont:[UIFont systemFontOfSize:12.f]];
    [skipButton addTarget:self action:@selector(handleSkipAction:) forControlEvents:UIControlEventTouchUpInside];
    skipButton.hidden = YES;
    [self addSubview:self.skipButton = skipButton];
}

- (void)launchImageWithURL:(NSURL *)imageURL
            requestTimeout:(NSInteger)requestTimeout
            displayTimeout:(NSInteger)displayTimeout {
    
    self.skipButton.hidden = YES;
    self.requestTimeout = requestTimeout > 0 ? requestTimeout : 5.f;
    self.displayTimeout = displayTimeout > 0 ? displayTimeout : 3.f;
    
    self.imageView.image = self.placeholder;
    self.imageURL = imageURL;
    if (imageURL) {
        
        __weak typeof(*&self) wSelf = self;
        [self.imageView yy_cancelCurrentImageRequest];
        [self.imageView yy_setImageWithURL:imageURL placeholder:self.placeholder options:YYWebImageOptionSetImageWithFadeAnimation manager:self.imageManager progress:nil transform:^UIImage * _Nullable(UIImage * _Nonnull image, NSURL * _Nonnull url) {
            
            YYImage *animatedImage = (YYImage *)image;
            if (animatedImage.animatedImageType == YYImageTypeGIF) {
                /** gif图片不做处理 */
                return animatedImage;
            }else {
                return [image yy_imageByResizeToSize:[UIApplication sharedApplication].keyWindow.bounds.size contentMode:UIViewContentModeScaleAspectFill];
            }
            /** 适配图片 */
        } completion:^(UIImage * _Nullable image, NSURL * _Nonnull url, YYWebImageFromType from, YYWebImageStage stage, NSError * _Nullable error) {
            
            __strong typeof(*&wSelf) self = wSelf;
            if (image && !error) {
                
                /** 显示跳过按钮,开始显示倒计时 */
                self.imageView.userInteractionEnabled = YES;
                self.skipButton.hidden = NO;
                self.countdownDate = [NSDate date];
                self.countdownTimer = [NSTimer scheduledTimerWithTimeInterval:1.f
                                                                       target:self
                                                                     selector:@selector(handleCountdownAction)
                                                                     userInfo:nil
                                                                      repeats:YES];
            }else if (self.isAutoHide){
                
                [self dismissLaunchViewWithMode:XMNLaunchViewDismissModeDefault];
            }
        }];
    }
}

- (void)dismissLaunchView {
    
    [self dismissLaunchViewWithMode:XMNLaunchViewDismissModeDefault];
}

- (void)dismissLaunchViewWithMode:(XMNLaunchViewDismissMode)mode {
    
    self.countdownTimer ? [self.countdownTimer invalidate] : nil;
    self.skipButton.hidden = YES;
    
    [UIView animateWithDuration:.5f animations:^{
        
        self.alpha = 0.3f;
        self.transform = CGAffineTransformMakeScale(1.5f, 1.5f);
    } completion:^(BOOL finished) {
        
        switch (mode) {
            case XMNLaunchViewDismissModeTap:
                self.completionBlock ? self.completionBlock(self, mode) : nil;
            default:
                [self removeFromSuperview];
                break;
        }
    }];
}

#pragma mark - Events

- (void)handleSkipAction:(UIButton *)button {
    
    [self dismissLaunchViewWithMode:XMNLaunchViewDismissModeDefault];
}

- (void)handleTapLaunch {
    
    [self dismissLaunchViewWithMode:XMNLaunchViewDismissModeTap];
}

- (void)handleCountdownAction {
    
    NSTimeInterval remainTimeInveral = MAX((int)self.displayTimeout - (int)[[NSDate date] timeIntervalSinceDate:self.countdownDate], 0);
    [self.skipButton setTitle:[NSString stringWithFormat:@"%02ds",(int)remainTimeInveral] forState:UIControlStateNormal];
    
    if (remainTimeInveral <= 0) {
        [self dismissLaunchViewWithMode:XMNLaunchViewDismissModeDefault];
    }
}

#pragma mark - Setter

- (void)setPlaceholder:(UIImage *)placeholder {
    
    _placeholder = placeholder;
    self.imageView.image = placeholder;
}

- (void)setDisplayTimeout:(NSTimeInterval)displayTimeout {
    
    _displayTimeout = displayTimeout;
    [self.skipButton setTitle:[NSString stringWithFormat:@"%02ds",(int)self.displayTimeout] forState:UIControlStateNormal];
}

- (void)setRequestTimeout:(NSTimeInterval)requestTimeout {
    
    self.imageManager.timeout = requestTimeout;
}

- (void)setFrame:(CGRect)frame {
    
    [super setFrame:frame];
    self.imageView.frame = self.bounds;
}

#pragma mark - Getter

- (NSTimeInterval)requestTimeout {
    
    return self.imageManager.timeout;
}

- (BOOL)isAutoHide {
    
    return _autoHide;
}

#pragma mark - Class Method


/**
 从启动图中获取当前启动图片
 
 @return 获取到的图片
 */
+ (UIImage * __nullable)launchImage {
    
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
        if (CGSizeEqualToSize(imageSize, [UIApplication sharedApplication].keyWindow.bounds.size) && [viewOrientation isEqualToString:dict[@"UILaunchImageOrientation"]]) {
            launchImageName = dict[@"UILaunchImageName"];
        }
    }
    return launchImageName ? [UIImage imageNamed:launchImageName] : nil;
}


+ (XMNLaunchView * __nullable)launchViewOnWindow {
    
    XMNLaunchView *view = [[UIApplication sharedApplication].keyWindow viewWithTag:kXMNLaunchViewTag];
    if ([view isKindOfClass:[XMNLaunchView class]]) {
        return view;
    }
    return nil;
}
@end
