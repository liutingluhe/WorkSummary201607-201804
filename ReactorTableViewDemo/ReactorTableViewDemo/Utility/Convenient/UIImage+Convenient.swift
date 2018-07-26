//
//  UIImage+Convenient.swift
//  ifanr
//
//  Created by luhe liu on 2018/6/25.
//  Copyright © 2018年 com.ifanr. All rights reserved.
//

import UIKit
import CoreGraphics

public extension UIImage {
    
    /// 内容居中适配
    public func aspectFillToSize(_ size: CGSize) -> UIImage {
        var scaledImageRect = CGRect.zero
        
        let aspectWidth: CGFloat = size.width / self.size.width
        let aspectHeight: CGFloat = size.height / self.size.height
        let aspectRatio: CGFloat = max(aspectWidth, aspectHeight)
        
        scaledImageRect.size.width = self.size.width * aspectRatio
        scaledImageRect.size.height = self.size.height * aspectRatio
        scaledImageRect.origin.x = (size.width - scaledImageRect.size.width) / 2.0
        scaledImageRect.origin.y = (size.height - scaledImageRect.size.height) / 2.0
        
        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        
        self.draw(in: scaledImageRect)
        
        let scaledImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return scaledImage!
    }
    
    /// 返回图片坐标点(x, y)处的 [red(0~255), green(0~255), blue(0~255), alpha(0~255)] 数值数组
    public func getPixelColor(_ pos: CGPoint) -> (r: Int, g: Int, b: Int, a: Int)? {
        guard let pixelData = self.cgImage?.dataProvider?.data else { return nil }
        let data: UnsafePointer<UInt8> = CFDataGetBytePtr(pixelData)
        let pixelInfo: Int = (Int(self.size.width) * Int(pos.y) + Int(pos.x)) * 4
        let redValue: Int = Int(data[pixelInfo])
        let greenValue: Int = Int(data[pixelInfo + 1])
        let blueValue: Int = Int(data[pixelInfo + 2])
        let alphaValue: Int = Int(data[pixelInfo + 3])
        return (r: redValue, g: greenValue, b: blueValue, a: alphaValue)
    }
}
