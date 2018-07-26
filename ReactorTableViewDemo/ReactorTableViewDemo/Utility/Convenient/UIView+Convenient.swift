//
//  UIView+Convenient.swift
//  ReactorCollectionViewDemo
//
//  Created by luhe liu on 2018/6/21.
//  Copyright © 2018年 luhe liu. All rights reserved.
//

import UIKit

// MARK: - UIView + UIImage
public extension UIView {
    
    public func displayViewToImage() -> UIImage? {
        // 生成截图
        UIGraphicsBeginImageContextWithOptions(self.bounds.size, false, 0)
        if let context = UIGraphicsGetCurrentContext() {
            self.layer.render(in: context)
        }
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }
}

// MARK: - UIView + Responder
public extension UIView {
    
    /// 寻找当前视图所在的控制器
    public var responderController: UIViewController? {
        var nextReponder: UIResponder? = self.next
        while nextReponder != nil {
            if let viewController = nextReponder as? UIViewController {
                return viewController
            }
            nextReponder = nextReponder?.next
        }
        return nil
    }
}

// MARK: - UIView + Geometry
extension CGSize {
    public func expand(_ value: CGFloat) -> CGSize {
        return CGSize(width: self.width + value, height: self.height + value)
    }
    
    public func expand(w: CGFloat, h: CGFloat) -> CGSize {
        return CGSize(width: self.width + w, height: self.height + h)
    }
    
    public var center: CGPoint {
        return CGPoint(x: self.width * 0.5, y: self.height * 0.5)
    }
}

/// Extends CGRect with helper properties for positioning and setting dimensions
extension CGRect: ExpressibleByStringLiteral {
    
    /// The top coordinate of the rect.
    public var top: CGFloat {
        get {
            return origin.y
        }
        set(value) {
            origin.y = value
        }
    }
    
    // The left-side coordinate of the rect.
    public var left: CGFloat {
        get {
            return origin.x
        }
        set(value) {
            origin.x = value
        }
    }
    
    // The bottom coordinate of the rect. Setting this will change origin.y of the rect according to
    // the height of the rect.
    public var bottom: CGFloat {
        get {
            return origin.y + size.height
        }
        set(value) {
            origin.y = value - size.height
        }
    }
    
    // The right-side coordinate of the rect. Setting this will change origin.x of the rect according to
    // the width of the rect.
    public var right: CGFloat {
        get {
            return origin.x + size.width
        }
        set(value) {
            origin.x = value - size.width
        }
    }
    
    // The width of the rect.
    public var width: CGFloat {
        get {
            return size.width
        }
        set(value) {
            size.width = value
        }
    }
    
    // The height of the rect.
    public var height: CGFloat {
        get {
            return size.height
        }
        set(value) {
            size.height = value
        }
    }
    
    // The center x coordinate of the rect.
    public var centerX: CGFloat {
        get {
            return origin.x + size.width / 2
        }
        set (value) {
            origin.x = value - size.width / 2
        }
    }
    
    // The center y coordinate of the rect.
    public var centerY: CGFloat {
        get {
            return origin.y + size.height / 2
        }
        set (value) {
            origin.y = value - size.height / 2
        }
    }
    
    // The center of the rect.
    public var center: CGPoint {
        get {
            return CGPoint(x: centerX, y: centerY)
        }
        set (value) {
            centerX = value.x
            centerY = value.y
        }
    }
    
    public typealias ExtendedGraphemeClusterLiteralType = StringLiteralType
    
    public init(stringLiteral value: StringLiteralType) {
        self.init()
        let rect: CGRect
        if value[value.startIndex] != "{" {
            let comp = value.components(separatedBy: ",")
            if comp.count == 4 {
                rect = CGRectFromString("{{\(comp[0]),\(comp[1])}, {\(comp[2]), \(comp[3])}}")
            } else {
                rect = CGRect.zero
            }
        } else {
            rect = CGRectFromString(value)
        }
        
        self.size = rect.size
        self.origin = rect.origin
    }
    
    public init(extendedGraphemeClusterLiteral value: ExtendedGraphemeClusterLiteralType) {
        self.init(stringLiteral: value)
    }
    
    public typealias UnicodeScalarLiteralType = StringLiteralType
    
    public init(unicodeScalarLiteral value: UnicodeScalarLiteralType) {
        self.init(stringLiteral: value)
    }
}

extension CGPoint: ExpressibleByStringLiteral {
    public typealias ExtendedGraphemeClusterLiteralType = StringLiteralType
    
    public init(stringLiteral value: StringLiteralType) {
        self.init()
        
        let point: CGPoint
        if value[value.startIndex] != "{" {
            point = CGPointFromString("{\(value)}")
        } else {
            point = CGPointFromString(value)
        }
        self.x = point.x
        self.y = point.y
    }
    
    public init(extendedGraphemeClusterLiteral value: ExtendedGraphemeClusterLiteralType) {
        self.init(stringLiteral: value)
    }
    
    public typealias UnicodeScalarLiteralType = StringLiteralType
    
    public init(unicodeScalarLiteral value: UnicodeScalarLiteralType) {
        self.init(stringLiteral: value)
    }
}

extension UIView {
    
    /// The top coordinate of the UIView.
    public var top: CGFloat {
        get {
            return frame.top
        }
        set(value) {
            var frame = self.frame
            frame.top = value
            self.frame = frame
        }
    }
    
    /// The left coordinate of the UIView.
    public var left: CGFloat {
        get {
            return frame.left
        }
        set(value) {
            var frame = self.frame
            frame.left = value
            self.frame = frame
        }
    }
    
    /// The bottom coordinate of the UIView.
    public var bottom: CGFloat {
        get {
            return frame.bottom
        }
        set(value) {
            var frame = self.frame
            frame.bottom = value
            self.frame = frame
        }
    }
    
    /// The right coordinate of the UIView.
    public var right: CGFloat {
        get {
            return frame.right
        }
        set(value) {
            var frame = self.frame
            frame.right = value
            self.frame = frame
        }
    }
    
    // The width of the UIView.
    public var width: CGFloat {
        get {
            return frame.width
        }
        set(value) {
            var frame = self.frame
            frame.width = value
            self.frame = frame
        }
    }
    
    // The height of the UIView.
    public var height: CGFloat {
        get {
            return frame.height
        }
        set(value) {
            var frame = self.frame
            frame.height = value
            self.frame = frame
        }
    }
    
    /// The horizontal center coordinate of the UIView.
    public var centerX: CGFloat {
        get {
            return frame.centerX
        }
        set(value) {
            var frame = self.frame
            frame.centerX = value
            self.frame = frame
        }
    }
    
    /// The vertical center coordinate of the UIView.
    public var centerY: CGFloat {
        get {
            return frame.centerY
        }
        set(value) {
            var frame = self.frame
            frame.centerY = value
            self.frame = frame
        }
    }
    
    public var absolutePoint: CGPoint {
        if let window = UIApplication.shared.keyWindow {
            let rect = self.convert(self.bounds, to: window)
            return rect.origin
        }
        return .zero
    }
}
