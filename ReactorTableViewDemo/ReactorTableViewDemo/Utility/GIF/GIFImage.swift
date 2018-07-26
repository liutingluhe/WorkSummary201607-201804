//
//  YLGIFImage.swift
//  YLGIFImage
//
//  Created by Yong Li on 6/8/14.
//  Copyright (c) 2014 Yong Li. All rights reserved.
//

import UIKit
import ImageIO
import MobileCoreServices

open class GIFImage {
    open lazy var readFrameQueue: DispatchQueue = DispatchQueue(label: "com.ronnie.gifreadframe", qos: .background)
    open var cgImgSource: CGImageSource?
    open var totalDuration: TimeInterval = 0.0
    open var frameDurations: [Int: TimeInterval] = [:]
    open var loopCount: Int = 1
    open var frameImages: [Int: UIImage] = [:]
    open var frameTotalCount: Int = 0
    open var image: UIImage?

    public struct GlobalSetting {
        static var prefetchNumber: Int = 10
        static let gifType = ".gif"
    }

    public class func setPrefetchNum(_ number: Int) {
        GlobalSetting.prefetchNumber = number
    }

    public convenience init?(named name: String!) {
        guard let path = Bundle.main.path(forResource: name, ofType: GlobalSetting.gifType) else { return nil }
        guard let data = try? Data(contentsOf: URL(fileURLWithPath: path)) else { return nil }
        self.init(data: data)
    }

    public convenience init?(contentsOfFile path: String) {
        guard let url = URL(string: path) else { return nil }
        guard let data = try? Data(contentsOf: url) else { return nil }
        self.init(data: data)
    }
    
    public convenience init?(contentsOf url: URL) {
        guard let data = try? Data(contentsOf: url) else { return nil }
        self.init(data: data)
    }

    public convenience init?(data: Data) {
        self.init(data: data, scale: 1.0)
    }

    public init?(data: Data, scale: CGFloat) {
        guard let cgImgSource = CGImageSourceCreateWithData(data as CFData, nil) else { return }
        if GIFImage.isCGImageSourceContainAnimatedGIF(cgImageSource: cgImgSource) {
            image = nil
            createSelf(cgImageSource: cgImgSource)
        } else {
            image = UIImage(data: data, scale: scale)
        }
    }
    
    public class func isCGImageSourceContainAnimatedGIF(cgImageSource: CGImageSource) -> Bool {
        guard let type = CGImageSourceGetType(cgImageSource) else { return false }
        let isGIF = UTTypeConformsTo(type, kUTTypeGIF)
        let imgCount = CGImageSourceGetCount(cgImageSource)
        return isGIF && imgCount > 1
    }
    
    public class func getCGImageSourceGifFrameDelay(imageSource: CGImageSource, index: Int) -> TimeInterval {
        var delay = 0.0
        guard let imgProperties: NSDictionary = CGImageSourceCopyPropertiesAtIndex(imageSource, index, nil) else { return delay }
        let gifProperties: NSDictionary? = imgProperties[kCGImagePropertyGIFDictionary as String] as? NSDictionary
        if let property = gifProperties {
            if let unclampedDelayTime = property[kCGImagePropertyGIFUnclampedDelayTime as String] as? NSNumber {
                delay = unclampedDelayTime.doubleValue
                if delay <= 0, let delayTime = property[kCGImagePropertyGIFDelayTime as String] as? NSNumber {
                    delay = delayTime.doubleValue
                }
            }
        }
        return delay
    }
    
    public func createSelf(cgImageSource: CGImageSource) {
        self.cgImgSource = cgImageSource
        guard let imageProperties: NSDictionary = CGImageSourceCopyProperties(cgImageSource, nil) else { return }
        let gifProperties: NSDictionary? = imageProperties[kCGImagePropertyGIFDictionary as String] as? NSDictionary
        if let property = gifProperties {
            if let count = property[kCGImagePropertyGIFLoopCount as String] as? NSNumber {
                self.loopCount = count.intValue
            }
        }
        let numOfFrames = CGImageSourceGetCount(cgImageSource)
        frameTotalCount = numOfFrames
        for index in 0..<numOfFrames {
            // get frame duration
            let frameDuration = GIFImage.getCGImageSourceGifFrameDelay(imageSource: cgImageSource, index: index)
            self.frameDurations[index] = max(0.01, frameDuration)
            self.totalDuration += frameDuration
            
            if index < GlobalSetting.prefetchNumber {
                // get frame
                guard let cgimage = CGImageSourceCreateImageAtIndex(cgImageSource, index, nil) else { return }
                let image: UIImage = UIImage(cgImage: cgimage)
                self.frameImages[index] = image
            }
        }
    }

    open func getFrame(index: Int) -> UIImage? {
        guard index < frameTotalCount else {
            return nil
        }
        let image = self.frameImages[index]
        if frameTotalCount > GlobalSetting.prefetchNumber {
            if index != 0 {
                self.frameImages[index] = nil
            }

            for i in 1...GlobalSetting.prefetchNumber {
                let idx = (i + index) % frameTotalCount
                if self.frameImages[idx] == nil {
                    self.frameImages[idx] = self.frameImages[0]
                    self.readFrameQueue.async {
                        guard let imgSource = self.cgImgSource else { return }
                        guard let cgImg = CGImageSourceCreateImageAtIndex(imgSource, idx, nil) else { return }
                        self.frameImages[idx] = UIImage(cgImage: cgImg)
                    }
                }
            }
        }
        return image
    }
}
