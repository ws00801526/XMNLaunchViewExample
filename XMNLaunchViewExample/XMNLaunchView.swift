//
//  XMNLaunchView.swift
//  XMNLaunchViewExample
//
//  Created by XMFraker on 16/8/23.
//  Copyright © 2016年 XMFraker. All rights reserved.
//


import UIKit

public enum XMNLaunchViewDismissMode: Int {
    
    /** 用户点击广告消失 */
    case tap
    /** 用户点击跳转消失 */
    case skip
    /** 图片展示时间到了 */
    case displayOverTime
    /** 广告超时消失,获取图片超时消失 */
    case requestOverTime
    /** 未设置imageURL,获取请求图片失败 */
    case noneImage
}

class XMNLaunchView: UIView {
    
    /** 回调block */
    fileprivate var completedBlock: ((_ dismissmode: XMNLaunchViewDismissMode) -> Void)?

    weak var displayWindow: UIWindow?
    
    var imageURL: URL? {
        
        //需要注意的是didSet,willSet 在类初始化的时候并不会调用
        //需要使用KVC模式 才会调用
        didSet {
            self.displayImage()
        }
    }
    
    var startDate: Date? {
        didSet {
            if self.startDate != nil {
                //停止之前的timer  否则不开启tiemr,因为没有timer 说明还没开始显示图片
                if self.timer != nil {
                    self.timer?.invalidate()
                    //重启一个timer
                    self.timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(XMNLaunchView.handleTimerAction(_:)), userInfo: nil, repeats: true)
                }
            }else {
                if self.timer != nil {
                    self.timer?.invalidate()
                }
            }
        }
    }
    var timer: Timer?
    
    /**
     使用懒加载方法,初始化imageView
     
     - returns:
     */
    lazy var imageView:YYAnimatedImageView = {
        
        let imageView = YYAnimatedImageView(frame: self.displayWindow!.bounds)
        imageView.contentMode = .scaleAspectFill
        imageView.isUserInteractionEnabled = true
        imageView.alpha = 0.0
        
        let tapGes = UITapGestureRecognizer(target: self, action: #selector(XMNLaunchView.handleTapAction(_:)))
        imageView.addGestureRecognizer(tapGes)
        return imageView
    }()
    
    
    /**
     使用懒加载方法,生成skipButton
     
     - returns:
     */
    lazy var skipButton:UIButton = {
       
        let button = UIButton(type: .custom)
        button.frame = CGRect(x: self.bounds.size.width - 16 - 60, y: 32, width: 60, height: 30)
        button.setTitle("\(self.displayInterval)s", for: UIControlState())
        
        let backgroundColor = UIColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 0.3)
        let backgroundImage = UIImage.yy_image(with: backgroundColor, size: CGSize(width: 60, height: 30))?.yy_image(byRoundCornerRadius: 15.0)
        button.addTarget(self, action: #selector(handleButtonAction(_:)), for: .touchUpInside)
        button.setBackgroundImage(backgroundImage, for: UIControlState())
        return button
    }()

    /// 显示 图片的时间
    var displayInterval: Int {
        
        didSet {
            //修改显示时间,则重启timer
            self.startDate = Date()
        }
    }
    var requestInterval: Int {
        
        didSet {
            //修改了requestInterval 重新设置超时方法
            NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(XMNLaunchView.handleRequestTimeOutAction), object: nil)
            self.perform(#selector(XMNLaunchView.handleRequestTimeOutAction), with: nil, afterDelay: Double(self.requestInterval))
        }
    }
    
    var launchImage: UIImage? {
        var launchImageName: String? = nil
        if let imageDicts = Bundle.main.infoDictionary?["UILaunchImages"] as? Array<AnyObject> {
            for imageDict in imageDicts{
                if let dict = imageDict as? NSDictionary {
                    let size = CGSizeFromString(dict["UILaunchImageSize"] as! String)
                    if size.equalTo((self.displayWindow?.bounds.size)!) {
                        launchImageName = dict["UILaunchImageName"] as? String
                    }
                }
                print(imageDict)
            }
            if let imageName = launchImageName {
                return UIImage(named: imageName)
            }else {
                return nil
            }
        }
        return nil
    }
    

    init(displayWindow: UIWindow, imageURL: URL?) {
        
        self.displayInterval = 3
        self.requestInterval = 10
        super.init(frame: displayWindow.bounds)
        self.displayWindow = displayWindow
        self.imageURL = imageURL

        self.setupUI()
        self.displayImage()
        
        //首次初始化 手动开启超时
        self.perform(#selector(XMNLaunchView.handleRequestTimeOutAction), with: nil, afterDelay: Double(self.requestInterval))
    }
    
    required convenience init?(coder aDecoder: NSCoder) {
        
        self.init(displayWindow: UIApplication.shared.keyWindow!, imageURL: nil)
    }
    
    /**
     重写析构方法,释放timer
     */
    deinit {
        if self.timer != nil {
            self.timer?.invalidate()
        }
        NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(XMNLaunchView.handleRequestTimeOutAction), object: nil)
        print("i am deinit \(NSStringFromClass(self.classForCoder))")
    }

    // MARK: Method
    
    /**
     设置完成回调
     
     - parameter block: 
     */
    func setCompletedBlock(_ block : @escaping (_: XMNLaunchViewDismissMode) -> Void) -> Void {
        self.completedBlock = block
    }
    
    func setupUI() {

        if self.launchImage != nil {
            self.backgroundColor = UIColor(patternImage: self.launchImage!)
        }else {
            self.backgroundColor = UIColor.white
        }
        //注意此处调用顺序, 先将keyWindow显示出来,再添加launchView, 防止launchView被添加到displayWindow.rootViewController.view后面
        self.displayWindow?.makeKeyAndVisible()
        self.displayWindow?.addSubview(self)
    }
    
    /**
     显示图片,如果没有imageURL,则直接隐藏launchView
     */
    func displayImage() {
        
        if self.imageURL != nil {
            
            if self.subviews.contains(self.imageView) {
                self.imageView.alpha = 0.0
            }else {
                self.addSubview(self.imageView)
            }
            
            self.imageView.yy_setImage(with: self.imageURL, placeholder: nil, options: .avoidSetImage, completion: { [unowned self] (downloadImage, originURL, fromType, imageState, error) in
                
                //判断下载的图片是否是YYImage
                if error != nil {
                    self.dismissLaunchView(dismissMode: .noneImage)
                    return
                }
                
                //取消请求超时的方法执行,已经获取到方法了
                NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(XMNLaunchView.handleRequestTimeOutAction), object: nil)

                if let image = downloadImage as? YYImage {
                    if image.animatedImageType == .GIF {
                        
                        self.imageView.animatedImage = image
                        self.imageView.startAnimating()
                    }else {
                        self.imageView.image = image.yy_imageByResize(to: (self.displayWindow?.bounds.size)!)
                    }
                    self.imageView.alpha = 0.0
                    UIView.animate(withDuration: 0.5, animations: {
                        self.imageView.alpha = 1.0
                        }, completion: { (_) in
                            self.startDate = Date()
                            self.timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(XMNLaunchView.handleTimerAction(_:)), userInfo: nil, repeats: true)
                            self.addSubview(self.skipButton)
                            self.backgroundColor = UIColor.clear
                    })
                }
            })
        }else {
         
            self.dismissLaunchView(dismissMode: .noneImage)
        }
    }
    
    /**
     处理timer方法
     
     - parameter timer:
     */
    func handleTimerAction(_ timer: Timer) {
        
        let remainTimeInterval = max(self.displayInterval - Int(Date().timeIntervalSince(self.startDate!)), 0)
        self.skipButton.setTitle("\(remainTimeInterval)s", for: UIControlState())
        if remainTimeInterval <= 0 {

            self.dismissLaunchView(dismissMode: .displayOverTime)
        }
        print("timer action")
    }
    
    /**
     处理请求超时
     */
    func handleRequestTimeOutAction() {

        self.dismissLaunchView(dismissMode: .requestOverTime)
    }
    
    /**
     隐藏launchView
     
     - parameter mode:
     */
    func dismissLaunchView(dismissMode mode :XMNLaunchViewDismissMode)  {
        
        NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(XMNLaunchView.handleRequestTimeOutAction), object: nil)
        
        if self.timer != nil {
            self.timer?.invalidate()
        }

        //只有此三种模式 skipButton 会被初始化显示出来,其他模式 不必去隐藏skipButton
        switch mode {
        case .displayOverTime: fallthrough
        case .skip: fallthrough
        case .tap : self.skipButton.isHidden = true
        default:
            break
        }
        
        UIView.animate(withDuration: 0.5, animations: { 
                self.imageView.alpha = 0.3
                self.imageView.transform = CGAffineTransform(scaleX: 1.5, y: 1.5)
            }, completion: { (_) in
                
                if let block = self.completedBlock {
                    block(mode)
                }
                self.removeFromSuperview()
        }) 
    }
    
    /**
     处理imageView的点击手势
     
     - parameter gesture:
     */
    func handleTapAction(_ gesture: UITapGestureRecognizer) {
        
        print("get tap action")
    }
    
    /**
     处理skipButton 跳过功能
     
     - parameter button:
     */
    func handleButtonAction(_ button: UIButton) {
        
        self.dismissLaunchView(dismissMode: .skip)
    }
    
}
