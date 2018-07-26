//
//  EasyCallHelper.swift
//  tableview
//
//  Created by 王 巍 (@onevcat) on 14-6-4.
//  Copyright (c) 2014年 OneV's Den. All rights reserved.
//
// swiftlint:disable operator_whitespace
import UIKit
import CoreGraphics

let screenBounds = UIScreen.main.bounds
let screenWidth = ceil(UIScreen.main.bounds.size.width)
let screenHeight = ceil(UIScreen.main.bounds.size.height)
let tabBarHeight: CGFloat = 49 + ScreenAdapter.shared.addBottomForInchX
let statusBarHeight: CGFloat = 20 + ScreenAdapter.shared.addTopForInchX

/// 跳转链接
@discardableResult
public func applicationOpenURL(_ urlStr: String?, completion: ((Bool) -> Swift.Void)? = nil) -> Bool {
    guard let urlStr = urlStr else {
        return false
    }
    
    if let url = URL(string: urlStr) {
        if UIApplication.shared.canOpenURL(url) {
            if #available(iOS 10.0, *) {
                UIApplication.shared.open(url, options: [:], completionHandler: completion)
            } else {
                UIApplication.shared.openURL(url)
                completion?(true)
            }
            return true
        }
    }
    return false
}

/// 震动
public func addFeedBackEffect(style: UIImpactFeedbackStyle = .light) {
    if #available(iOS 10, *) {
        let feedback = UIImpactFeedbackGenerator(style: style)
        feedback.impactOccurred()
    }
}

/// 弧度转角度
public func degreesToRadians(_ value: CGFloat) -> CGFloat {
    return value * CGFloat(Double.pi) / 180.0
}

/// 求两点之间的距离
public func distanceBetweenPoints(_ first: CGPoint, second: CGPoint) -> CGFloat {
    let deltaX = abs(first.x - second.x)
    let deltaY = abs(first.y - second.y)
    return sqrt(deltaX * deltaX + deltaY * deltaY)
}

/// 求一个圆心为 center，半径为 radius 的圆上的角度为 angle 的弧上的一点坐标
public func circlePoint(center: CGPoint, angle: CGFloat, radius: CGFloat) -> CGPoint {
    let offsetX = radius * cos(angle * Double.pi / 180)
    let offsetY = radius * sin(angle * Double.pi / 180)
    return CGPoint(x: center.x + offsetX, y: center.y - offsetY)
}

// MARK: - 运算符
public func < <T: Comparable>(lhs: T?, rhs: T?) -> Bool {
    switch (lhs, rhs) {
    case let (l?, r?):
        return l < r
    case (nil, _?):
        return true
    default:
        return false
    }
}

public func > <T: Comparable>(lhs: T?, rhs: T?) -> Bool {
    switch (lhs, rhs) {
    case let (l?, r?):
        return l > r
    default:
        return rhs < lhs
    }
}

public func +(lhs: Int, rhs: Double) -> Double {
    return Double(lhs) + rhs
}

public func +(lhs: Double, rhs: Int) -> Double {
    return lhs + Double(rhs)
}

public func +(lhs: Int, rhs: Float) -> Float {
    return Float(lhs) + rhs
}

public func +(lhs: Float, rhs: Int) -> Float {
    return lhs + Float(rhs)
}

public func +(lhs: Float, rhs: Double) -> Double {
    return Double(lhs) + rhs
}

public func +(lhs: Double, rhs: Float) -> Double {
    return lhs + Double(rhs)
}

public func +(lhs: UInt, rhs: Double) -> Double {
    return Double(lhs) + rhs
}

public func +(lhs: Double, rhs: UInt) -> Double {
    return lhs + Double(rhs)
}

public func +(lhs: UInt, rhs: Float) -> Float {
    return Float(lhs) + rhs
}

public func +(lhs: Float, rhs: UInt) -> Float {
    return lhs + Float(rhs)
}

public func -(lhs: Int, rhs: Double) -> Double {
    return Double(lhs) - rhs
}

public func -(lhs: Double, rhs: Int) -> Double {
    return lhs - Double(rhs)
}

public func -(lhs: Int, rhs: Float) -> Float {
    return Float(lhs) - rhs
}

public func -(lhs: Float, rhs: Int) -> Float {
    return lhs - Float(rhs)
}

public func -(lhs: Float, rhs: Double) -> Double {
    return Double(lhs) - rhs
}

public func -(lhs: Double, rhs: Float) -> Double {
    return lhs - Double(rhs)
}

public func -(lhs: UInt, rhs: Double) -> Double {
    return Double(lhs) - rhs
}

public func -(lhs: Double, rhs: UInt) -> Double {
    return lhs - Double(rhs)
}

public func -(lhs: UInt, rhs: Float) -> Float {
    return Float(lhs) - rhs
}

public func -(lhs: Float, rhs: UInt) -> Float {
    return lhs - Float(rhs)
}

public func *(lhs: Int, rhs: Double) -> Double {
    return Double(lhs) * rhs
}

public func *(lhs: Double, rhs: Int) -> Double {
    return lhs * Double(rhs)
}

public func *(lhs: Int, rhs: Float) -> Float {
    return Float(lhs) * rhs
}

public func *(lhs: Float, rhs: Int) -> Float {
    return lhs * Float(rhs)
}

public func *(lhs: Float, rhs: Double) -> Double {
    return Double(lhs) * rhs
}

public func *(lhs: Double, rhs: Float) -> Double {
    return lhs * Double(rhs)
}

public func *(lhs: UInt, rhs: Double) -> Double {
    return Double(lhs) * rhs
}

public func *(lhs: Double, rhs: UInt) -> Double {
    return lhs * Double(rhs)
}

public func *(lhs: UInt, rhs: Float) -> Float {
    return Float(lhs) * rhs
}

public func *(lhs: Float, rhs: UInt) -> Float {
    return lhs * Float(rhs)
}

public func /(lhs: Int, rhs: Double) -> Double {
    return Double(lhs) / rhs
}

public func /(lhs: Double, rhs: Int) -> Double {
    return lhs / Double(rhs)
}

public func /(lhs: Int, rhs: Float) -> Float {
    return Float(lhs) / rhs
}

public func /(lhs: Float, rhs: Int) -> Float {
    return lhs / Float(rhs)
}

public func /(lhs: Float, rhs: Double) -> Double {
    return Double(lhs) / rhs
}

public func /(lhs: Double, rhs: Float) -> Double {
    return lhs / Double(rhs)
}

public func /(lhs: UInt, rhs: Double) -> Double {
    return Double(lhs) / rhs
}

public func /(lhs: Double, rhs: UInt) -> Double {
    return lhs / Double(rhs)
}

public func /(lhs: UInt, rhs: Float) -> Float {
    return Float(lhs) / rhs
}

public func /(lhs: Float, rhs: UInt) -> Float {
    return lhs / Float(rhs)
}

// MARK: - Core Graphics Calculation

public func +(lhs: CGFloat, rhs: Float) -> CGFloat {
    return lhs + CGFloat(rhs)
}

public func +(lhs: Float, rhs: CGFloat) -> CGFloat {
    return CGFloat(lhs) + rhs
}

public func +(lhs: CGFloat, rhs: Double) -> CGFloat {
    return lhs + CGFloat(rhs)
}

public func +(lhs: Double, rhs: CGFloat) -> CGFloat {
    return CGFloat(lhs) + rhs
}

public func +(lhs: CGFloat, rhs: Int) -> CGFloat {
    return lhs + CGFloat(rhs)
}

public func +(lhs: Int, rhs: CGFloat) -> CGFloat {
    return CGFloat(lhs) + rhs
}

public func +(lhs: CGFloat, rhs: UInt) -> CGFloat {
    return lhs + CGFloat(rhs)
}

public func +(lhs: UInt, rhs: CGFloat) -> CGFloat {
    return CGFloat(lhs) + rhs
}

public func -(lhs: CGFloat, rhs: Float) -> CGFloat {
    return lhs - CGFloat(rhs)
}

public func -(lhs: Float, rhs: CGFloat) -> CGFloat {
    return CGFloat(lhs) - rhs
}

public func -(lhs: CGFloat, rhs: Double) -> CGFloat {
    return lhs - CGFloat(rhs)
}

public func -(lhs: Double, rhs: CGFloat) -> CGFloat {
    return CGFloat(lhs) - rhs
}

public func -(lhs: CGFloat, rhs: Int) -> CGFloat {
    return lhs - CGFloat(rhs)
}

public func -(lhs: Int, rhs: CGFloat) -> CGFloat {
    return CGFloat(lhs) - rhs
}

public func -(lhs: CGFloat, rhs: UInt) -> CGFloat {
    return lhs - CGFloat(rhs)
}

public func -(lhs: UInt, rhs: CGFloat) -> CGFloat {
    return CGFloat(lhs) - rhs
}

public func *(lhs: CGFloat, rhs: Float) -> CGFloat {
    return lhs * CGFloat(rhs)
}

public func *(lhs: Float, rhs: CGFloat) -> CGFloat {
    return CGFloat(lhs) * rhs
}

public func *(lhs: CGFloat, rhs: Double) -> CGFloat {
    return lhs * CGFloat(rhs)
}

public func *(lhs: Double, rhs: CGFloat) -> CGFloat {
    return CGFloat(lhs) * rhs
}

public func *(lhs: CGFloat, rhs: Int) -> CGFloat {
    return lhs * CGFloat(rhs)
}

public func *(lhs: Int, rhs: CGFloat) -> CGFloat {
    return CGFloat(lhs) * rhs
}

public func *(lhs: CGFloat, rhs: UInt) -> CGFloat {
    return lhs * CGFloat(rhs)
}

public func *(lhs: UInt, rhs: CGFloat) -> CGFloat {
    return CGFloat(lhs) * rhs
}

public func /(lhs: CGFloat, rhs: Float) -> CGFloat {
    return lhs / CGFloat(rhs)
}

public func /(lhs: Float, rhs: CGFloat) -> CGFloat {
    return CGFloat(lhs) / rhs
}

public func /(lhs: CGFloat, rhs: Double) -> CGFloat {
    return lhs / CGFloat(rhs)
}

public func /(lhs: Double, rhs: CGFloat) -> CGFloat {
    return CGFloat(lhs) / rhs
}

public func /(lhs: CGFloat, rhs: Int) -> CGFloat {
    return lhs / CGFloat(rhs)
}

public func /(lhs: Int, rhs: CGFloat) -> CGFloat {
    return CGFloat(lhs) / rhs
}

public func /(lhs: CGFloat, rhs: UInt) -> CGFloat {
    return lhs / CGFloat(rhs)
}

public func /(lhs: UInt, rhs: CGFloat) -> CGFloat {
    return CGFloat(lhs) / rhs
}
