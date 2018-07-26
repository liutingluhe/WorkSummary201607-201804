//
//  ScreenEdgePanHelper.swift
//  ifanr
//
//  Created by luhe liu on 2018/7/24.
//  Copyright © 2018年 com.ifanr. All rights reserved.
//

import UIKit

open class ScreenEdgePanHelper: NSObject, UIGestureRecognizerDelegate {

    open var popGestureRecognizerEnabled = true
    open var popRecognizer: UIPanGestureRecognizer?
    public weak var navigationVC: UINavigationController?
    
    public init(navigationVC: UINavigationController?) {
        super.init()
        self.navigationVC = navigationVC
    }
    
    /// 替换系统右滑返回手势为自定义右滑返回手势
    open func replaceInteractivePopGestureRecognizer() {
        // 获取系统边缘右滑返回手势
        guard let gesture = navigationVC?.interactivePopGestureRecognizer, let gestureView = gesture.view else { return }
        // 让系统右滑返回手势失效
        gesture.isEnabled = false
        
        // 创建自己的右滑返回手势，并添加到视图上
        let popRecognizer = UIPanGestureRecognizer()
        popRecognizer.delegate = self
        popRecognizer.maximumNumberOfTouches = 1
        gestureView.addGestureRecognizer(popRecognizer)
    
        // 桥接系统右滑返回手势的触发方法到自己定义的手势上
        var navigationInteractiveTransition: Any?
        // gesture._targets.first._target 就是系统右滑返回触发方法所在的对象，因为涉及到隐式属性，所以通过 valueForKey 的方式获取
        if let targets = gesture.value(forKey: "_targets") as? NSMutableArray,
            let gestureRecognizerTarget = targets.firstObject as? NSObject {
            navigationInteractiveTransition = gestureRecognizerTarget.value(forKey: "_target")
        }
        if let navigationInteractiveTransition = navigationInteractiveTransition {
            // 因为 handleNavigationTransition 是 ObjC 的私有方法，这里通过字符串转方法名的方式实现桥接
            let handleTransition = NSSelectorFromString("handleNavigationTransition:")
            popRecognizer.addTarget(navigationInteractiveTransition, action: handleTransition)
        }
        self.popRecognizer = popRecognizer
    }

    /// 判断是否触发右滑返回手势，条件：1. 方向是往右滑, 2. 控制器栈的高度要大于1, 3. 不在转场过程中,
    open func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        guard let navigationVC = self.navigationVC else { return false }
        guard let popRecognizer = self.popRecognizer, popGestureRecognizerEnabled else { return false }
        // 1. 方向是往右滑
        guard popRecognizer.translation(in: navigationVC.view).x > 0 else { return false }
        // 2. 不在转场过程中
        if let isTransitioning = navigationVC.value(forKey: "_isTransitioning") as? NSNumber {
            // 3. 控制器栈的高度要大于1
            return !isTransitioning.boolValue && navigationVC.viewControllers.count > 1
        }
        return true
    }
    
    /// 控制开始触发右滑返回手势的区域，这里是左边边缘距离 1/3 屏幕宽度范围内都能触发
    open func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        guard let navigationVC = self.navigationVC else { return false }
        let point = touch.location(in: navigationVC.view)
        return point.x >= 0 && point.x < ceil(UIScreen.main.bounds.size.width) / 3.0
    }
    
    // 解决 scrollView 和 右滑返回手势 冲突问题
    open func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        if (gestureRecognizer is UIPanGestureRecognizer) && (otherGestureRecognizer is UIPanGestureRecognizer) {
            if let gestureRecognizerView = gestureRecognizer.view as? UIScrollView {
                if gestureRecognizerView.contentOffset.x <= 0 && gestureRecognizerView.alwaysBounceHorizontal {
                    return true
                }
            } else if let otherGestureRecognizerView = otherGestureRecognizer.view as? UIScrollView {
                if otherGestureRecognizerView.contentOffset.x <= 0 && otherGestureRecognizerView.alwaysBounceHorizontal {
                    return true
                }
            }
        }
        return false
    }

}
