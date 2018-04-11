//
//  StatusBarManager.swift
//  AppSo
//
//  Created by luhe liu on 17/5/19.
//  Copyright © 2017年 Judson. All rights reserved.
//

import UIKit

/// 状态栏单一状态
class StatusBarState {
    static let defaultKey: String = "default"
    
    var isHidden: Bool = false
    var style: UIStatusBarStyle = .lightContent
    var animation: UIStatusBarAnimation = .fade
    var key: String = defaultKey
}

/// 全局状态栏状态管理单例类
class StatusBarManager {
    static let shared = StatusBarManager()
    // MARK: - 属性
    /// 状态栈
    fileprivate var states: [StatusBarState] = []
    /// 更新状态栏动画时间
    fileprivate var duration: TimeInterval = 0.1
    
    /// 以下3个计算属性都是取栈顶状态显示以及更新栈顶状态
    var isHidden: Bool {
        get {
            return getCurrentState().isHidden
        }
        set {
            setTopState(isHidden: newValue)
        }
    }
    var style: UIStatusBarStyle {
        get {
            return getCurrentState().style
        }
        set {
            setTopState(style: newValue)
        }
    }
    var animation: UIStatusBarAnimation {
        get {
            return getCurrentState().animation
        }
        set {
            setTopState(animation: newValue)
        }
    }
    
    // MARK: - 方法
    fileprivate init() {
        states.append(StatusBarState())
    }
    
    // 在栈顶增加一个新状态并更新
    func appendState(_ state: StatusBarState) {
        // 保证栈中每个状态的 key 都是唯一的
        if !states.contains(where: { $0.key == state.key }) {
            states.append(state)
            updateStatusBar()
        }
    }
    
    // 从栈顶移除一个状态并更新（当栈中只有一个状态时，不移除）
    func popState() {
        // 保证栈中至少有一个状态
        guard states.count > 1 else { return }
        if states.popLast() != nil {
            updateStatusBar()
        }
    }
    
    /// 快捷调用方法，更新栈顶状态
    func setTopState(isHidden: Bool? = nil, style: UIStatusBarStyle? = nil, animation: UIStatusBarAnimation? = nil) {
        setState(for: nil, isHidden: isHidden, style: style, animation: animation)
    }
    
    /// 快捷调用方法，更新栈底状态
    func setBottomState(isHidden: Bool? = nil, style: UIStatusBarStyle? = nil, animation: UIStatusBarAnimation? = nil) {
        setState(for: StatusBarState.defaultKey, isHidden: isHidden, style: style, animation: animation)
    }
    
    /// 更新栈中 key 对应的状态，key == nil 表示栈顶状态
    func setState(for key: String?, isHidden: Bool? = nil, style: UIStatusBarStyle? = nil, animation: UIStatusBarAnimation? = nil) {
        var needUpdate: Bool = false
        let state = getCurrentState(key)
        if let isHidden = isHidden, state.isHidden != isHidden {
            needUpdate = true
            state.isHidden = isHidden
        }
        if let style = style, state.style != style {
            needUpdate = true
            state.style = style
        }
        if let animation = animation, state.animation != animation {
            needUpdate = true
            state.animation = animation
        }
        // key != nil 表示更新对应 key 的状态，需要判断该状态是否是栈顶
        if let key = key {
            guard let lastState = states.last, lastState.key == key else { return }
        }
        // 状态有变化才需要更新视图
        if needUpdate {
            updateStatusBar()
        }
    }
    
    /// 开始更新状态栏的状态
    fileprivate func updateStatusBar() {
        DispatchQueue.main.async { // 在主线程异步执行 避免同时索取同一属性
            // 如果状态栏需要动画（fade or slide），需要添加动画时间，才会有动画效果
            UIView.animate(withDuration: self.duration, animations: {
                UIApplication.shared.keyWindow?.rootViewController?.setNeedsStatusBarAppearanceUpdate()
            })
        }
    }
    
    /// 获取状态，key == nil 则取栈顶状态，否则根据 key 查找状态
    fileprivate func getCurrentState(_ key: String? = nil) -> StatusBarState {
        if let key = key { // 查找
            if let state = states.filter({ $0.key == key }).first {
                return state
            }
        } else if let lastState = states.last { // 栈顶
            return lastState
        }
        // 发现栈为空，插入一个状态
        let newState = StatusBarState()
        states.append(newState)
        return newState
    }
}
