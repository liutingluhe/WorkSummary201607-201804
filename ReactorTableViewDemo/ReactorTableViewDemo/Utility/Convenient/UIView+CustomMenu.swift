//
//  UIView+CustomMenu.swift
//  ifanr
//
//  Created by luhe liu on 2018/1/31.
//  Copyright © 2018年 com.ifanr. All rights reserved.
//

import UIKit

// 以下代码用于修复 "Method 'initialize()' defines Objective-C class method 'initialize', which is not guaranteed to be invoked by Swift and will be disallowed in future versions" 的 bug
/// 1. 定义 `protocol`
public protocol SelfAware: class {
    static func awake()
}

/// 2. 创建代理执行单例
fileprivate class SelfAwareRunner {
    
    static func runAllAware() {
        let typeCount = Int(objc_getClassList(nil, 0))
        let types = UnsafeMutablePointer<AnyClass?>.allocate(capacity: typeCount)
        let autoreleaseintTypes = AutoreleasingUnsafeMutablePointer<AnyClass?>(types)
        objc_getClassList(autoreleaseintTypes, Int32(typeCount)) //获取所有的类
        for index in 0..<typeCount {
            (types[index] as? SelfAware.Type)?.awake() //如果该类实现了SelfAware协议，那么调用awake方法
        }
        types.deallocate(capacity: typeCount)
    }
}

/// 3. 执行单例
extension UIApplication {
    fileprivate static let runOnce: Void = {
        //使用静态属性以保证只调用一次(该属性是个方法)
        SelfAwareRunner.runAllAware()
    }()
    
    open override var next: UIResponder? {
        UIApplication.runOnce
        return super.next
    }
}

/// 4. 继承 SelfAware , 实现 awake 静态方法，这里的 awake() 方法就类似于 Obj-C 中的 initialize()
// MARK: 该分类是用来隐藏 WKWebView 的系统菜单项
extension UIView: SelfAware {
    
    public static func awake() {
        if #available(iOS 11.0, *) {
            guard NSStringFromClass(self) == "WKWebView" else { return }
        } else {
            guard NSStringFromClass(self) == "WKContentView" else { return }
        }
        
        swizzleMethod(#selector(canPerformAction), withSelector: #selector(swizzledCanPerformAction))
        
    }
    
    fileprivate class func swizzleMethod(_ selector: Selector, withSelector: Selector) {
        let originalSelector = class_getInstanceMethod(self, selector)
        let swizzledSelector = class_getInstanceMethod(self, withSelector)
        method_exchangeImplementations(originalSelector, swizzledSelector)
    }
    
    @objc fileprivate func swizzledCanPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
        return false
    }
}
