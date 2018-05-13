//
//  YLImageView.swift
//  YLGIFImage
//
//  Created by Yong Li on 6/8/14.
//  Copyright (c) 2014 Yong Li. All rights reserved.
//

import UIKit
import QuartzCore

class BasicGIFImageView: UIImageView {
    /// 后台下载图片队列
    fileprivate lazy var downloadImageQueue: DispatchQueue = DispatchQueue(label: "image.gif.downloadImageQueue", qos: .background)
    /// 累加器，用于计算一个定时循环中的可用动画时间
    fileprivate var accumulator: TimeInterval = 0.0
    /// 当前正在显示的图片帧索引
    fileprivate var currentFrameIndex: Int = 0
    /// 当前正在显示的图片
    fileprivate var currentFrame: UIImage?
    /// 动画图片存储属性
    fileprivate var animatedImage: GIFImage?
    /// 定时器
    fileprivate var displayLink: CADisplayLink!
    /// 当前将要显示的 GIF 图片资源路径
    fileprivate var gifUrl: URL?
  
    /// 重载初始化，初始化定时器
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupDisplayLink()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupDisplayLink()
    }
    
    override init(image: UIImage?) {
        super.init(image: image)
        setupDisplayLink()
    }
    
    override init(image: UIImage?, highlightedImage: UIImage!) {
        super.init(image: image, highlightedImage: highlightedImage)
        setupDisplayLink()
    }
    
    /// 当设置该属性时，将不显示 GIF 动效
    override var image: UIImage? {
        get {
            if let animatedImage = self.animatedImage {
                return animatedImage.getFrame(index: 0)
            } else {
                return super.image
            }
        }
        set {
            if image === newValue {
                return
            }
            super.image = newValue
            self.gifImage = nil
        }
    }
    
    /// 设置 GIF 图片
    var gifImage: GIFImage? {
        get {
            return self.animatedImage
        }
        set {
            if animatedImage === newValue {
                return
            }
            self.stopAnimating()
            self.currentFrameIndex = 0
            self.accumulator = 0.0
            if let newAnimatedImage = newValue {
                self.animatedImage = newAnimatedImage
                if let currentImage = newAnimatedImage.getFrame(index: 0) {
                    super.image = currentImage
                    self.currentFrame = currentImage
                }
                self.startAnimating()
            } else {
                self.animatedImage = nil
            }
            self.layer.setNeedsDisplay()
        }
        
    }
    
    /// 当显示 GIF 时，不处理高亮状态
    override var isHighlighted: Bool {
        get {
            return super.isHighlighted
        }
        set {
            if self.animatedImage == nil {
                super.isHighlighted = newValue
            }
        }
    }
    
    /// 获取是否正在动画
    override var isAnimating: Bool {
        if self.animatedImage != nil {
            return !self.displayLink.isPaused
        } else {
            return super.isAnimating
        }
    }
    
    /// 开启定时器
    override func startAnimating() {
        if self.animatedImage != nil {
            self.displayLink.isPaused = false
        } else {
            super.startAnimating()
        }
    }
    
    /// 暂停定时器
    override func stopAnimating() {
        if self.animatedImage != nil {
            self.displayLink.isPaused = true
        } else {
            super.stopAnimating()
        }
    }
    
    /// 当前显示内容为 GIF 当前帧图片
    override func display(_ layer: CALayer) {
        if self.animatedImage != nil {
            if let frame = self.currentFrame {
                layer.contents = frame.cgImage
            }
        }
    }
    
    /// 初始化定时器
    fileprivate func setupDisplayLink() {
        displayLink = CADisplayLink(target: self, selector: #selector(BasicGIFImageView.changeKeyFrame))
        self.displayLink.add(to: RunLoop.main, forMode: .commonModes)
        self.displayLink.isPaused = true
    }
    
    /// 动态改变图片动画帧
    @objc fileprivate func changeKeyFrame() {
        if let animatedImage = self.animatedImage {
            guard self.currentFrameIndex < animatedImage.frameTotalCount else { return }
            self.accumulator += min(1.0, displayLink.duration)
            var frameDuration = animatedImage.frameDurations[self.currentFrameIndex] ?? displayLink.duration
            while self.accumulator >= frameDuration {
                self.accumulator -= frameDuration
                self.currentFrameIndex += 1
                if self.currentFrameIndex >= animatedImage.frameTotalCount {
                    self.currentFrameIndex = 0
                }
                if let currentImage = animatedImage.getFrame(index: self.currentFrameIndex) {
                    self.currentFrame = currentImage
                }
                self.layer.setNeedsDisplay()
                if let newFrameDuration = animatedImage.frameDurations[self.currentFrameIndex] {
                    frameDuration = min(displayLink.duration, newFrameDuration)
                }
            }
        } else {
            self.stopAnimating()
        }
    }
    
    /// 显示本地 GIF 图片
    func showLocalGIF(name: String?) {
        guard let name = name else { return }
        self.gifImage = GIFImage(named: name)
    }
    
    /// 根据 urlStr 显示网络 GIF 图片
    func showNetworkGIF(urlStr: String?) {
        guard let urlStr = urlStr else { return }
        guard let url = URL(string: urlStr) else { return }
        showNetworkGIF(url: url)
    }
    
    /// 根据 url 显示网络 GIF 图片
    func showNetworkGIF(url: URL) {
        guard let fileName = url.absoluteString.encodeMD5, let directoryPath = NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true).first else { return }
        let filePath = (directoryPath as NSString).appendingPathComponent("\(fileName).gif") as String
        let fileUrl = URL(fileURLWithPath: filePath)
        self.gifUrl = fileUrl
        // 后台下载网络图片或者加载本地缓存图片
        self.downloadImageQueue.async { [weak self] in
            if FileManager.default.fileExists(atPath: filePath) { // 本地缓存
                let gifImage = GIFImage(contentsOf: fileUrl)
                DispatchQueue.main.async { [weak self] in
                    if let strongSelf = self, strongSelf.gifUrl == fileUrl {
                        strongSelf.gifImage = gifImage
                    }
                }
            } else { // 网络加载
                let task = URLSession.shared.dataTask(with: url, completionHandler: { (data, _, _) in
                    guard let data = data else { return }
                    do {
                        try data.write(to: fileUrl, options: .atomic)
                    } catch {
                        debugPrint(error)
                    }
                    let gifImage = GIFImage(data: data)
                    DispatchQueue.main.async { [weak self] in
                        if let strongSelf = self, strongSelf.gifUrl == fileUrl {
                            strongSelf.gifImage = gifImage
                        }
                    }
                })
                task.resume()
            }
        }
    }
}
