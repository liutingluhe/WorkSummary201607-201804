//
//  UIColor+Convenient.swift
//  ifanr
//
//  Created by luhe liu on 2018/6/26.
//  Copyright © 2018年 com.ifanr. All rights reserved.
//

import UIKit

// MARK: - UIColor + UIImage
public extension UIColor {
    
    public func createImage(_ size: CGSize) -> UIImage? {
        let rect = CGRect(x: 0, y: 0, width: size.width, height: size.height)
        UIGraphicsBeginImageContext(rect.size)
        if let context = UIGraphicsGetCurrentContext() {
            context.setFillColor(self.cgColor)
            context.fill(rect)
        }
        let img = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return img
    }
    
}

// MARK: - UIColor 颜色值
public extension UIColor {
    
    public func alpha(_ alpha: CGFloat) -> UIColor {
        return self.withAlphaComponent(alpha)
    }
    
    public convenience init(r: Int, g: Int, b: Int, a: CGFloat = 1.0) {
        self.init(r: r, g: g, b: b, p3R: r, p3G: g, p3B: b, a: a)
    }
    
    public convenience init(r: Int, g: Int, b: Int, p3R: Int, p3G: Int, p3B: Int, a: CGFloat = 1.0) {
        let totalValue: Float = 255
        if #available(iOS 10.0, *) {
            self.init(displayP3Red: CGFloat(Float(p3R) / totalValue), green: CGFloat(Float(p3G) / totalValue), blue: CGFloat(Float(p3B) / totalValue), alpha: a)
        } else {
            self.init(red: CGFloat(Float(r) / totalValue), green: CGFloat(Float(g) / totalValue), blue: CGFloat(Float(b) / totalValue), alpha: a)
        }
    }
    
    // Random
    public static var randomColor: UIColor {
        return UIColor(r: Int(arc4random_uniform(256)), g: Int(arc4random_uniform(256)), b: Int(arc4random_uniform(256)))
    }
    
    // Pure
    public static func pureColor(_ pureValue: Int, alpha: CGFloat = 1.0) -> UIColor {
        return UIColor(r: pureValue, g: pureValue, b: pureValue)
    }
}
