//
//  YLImageView.swift
//  YLGIFImage
//
//  Created by Yong Li on 6/8/14.
//  Copyright (c) 2014 Yong Li. All rights reserved.
//

import UIKit

open class BasicGIFImageView: UIImageView {
    open var accumulator: TimeInterval = 0.0
    open var currentFrameIndex: Int = 0
    open var currentFrame: UIImage?
    open var loopCountdown: Int = Int.max
    open var animatedImage: GIFImage?
    open var displayLink: CADisplayLink!
    open var gifUrl: URL?
  
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupDisplayLink()
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        setupDisplayLink()
    }
    
    public override init(image: UIImage?) {
        super.init(image: image)
        setupDisplayLink()
    }
    
    public override init(image: UIImage?, highlightedImage: UIImage!) {
        super.init(image: image, highlightedImage: highlightedImage)
        setupDisplayLink()
    }
    
    open override var image: UIImage? {
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
            self.stopAnimating()
            self.currentFrameIndex = 0
            self.accumulator = 0.0
            super.image = newValue
            self.animatedImage = nil
        }
    }
    
    open var gifImage: GIFImage? {
        get {
            return self.animatedImage
        }
        set {
            if animatedImage === newValue {
                return
            }
            self.stopAnimating()
            if let newAnimatedImage = newValue {
                self.currentFrameIndex = 0
                self.accumulator = 0.0
                self.animatedImage = newAnimatedImage
                if let currentImage = newAnimatedImage.getFrame(index: 0) {
                    super.image = currentImage
                    self.currentFrame = super.image
                }
                self.startAnimating()
            } else {
                self.animatedImage = nil
            }
            self.layer.setNeedsDisplay()
        }
    }
    
    open override var isHighlighted: Bool {
        get {
            return super.isHighlighted
        }
        set {
            if self.animatedImage == nil {
                super.isHighlighted = newValue
            }
        }
    }
    
    open override var isAnimating: Bool {
        if self.animatedImage != nil {
            return !self.displayLink.isPaused
        } else {
            return super.isAnimating
        }
    }
    
    open override func startAnimating() {
        if self.animatedImage != nil {
            self.displayLink.isPaused = false
        } else {
            super.startAnimating()
        }
    }
    
    open override func stopAnimating() {
        if self.animatedImage != nil {
            self.displayLink.isPaused = true
        } else {
            super.stopAnimating()
        }
    }
    
    open override func display(_ layer: CALayer) {
        if self.animatedImage != nil {
            if let frame = self.currentFrame {
                layer.contents = frame.cgImage
            }
        }
    }
    
    open func setupDisplayLink() {
        displayLink = CADisplayLink(target: self, selector: #selector(BasicGIFImageView.changeKeyFrame))
        self.displayLink.add(to: RunLoop.main, forMode: .commonModes)
        self.displayLink.isPaused = true
    }
    
    open func changeKeyFrame() {
        if let animatedImage = self.animatedImage {
            guard self.currentFrameIndex < animatedImage.frameTotalCount else { return }
            self.accumulator += min(1.0, displayLink.duration)
            var frameDuration = animatedImage.frameDurations[self.currentFrameIndex] ?? 0.01
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
    
    open func showNetworkGIF(_ url: URL) {
        guard let fileName = url.absoluteString.encodeMD5, let directoryPath = NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true).first else { return }
        let filePath = (directoryPath as NSString).appendingPathComponent("\(fileName)\(GIFImage.GlobalSetting.gifType)") as String
        let fileUrl = URL(fileURLWithPath: filePath)
        self.gifUrl = fileUrl
        
        DispatchQueue.global(qos: .background).async { [weak self] in
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
                        debugLog(error)
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
