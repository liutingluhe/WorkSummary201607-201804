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
    static let defaultKey: String = "StatusBarState.default.root.key"
    
    var isHidden: Bool = false
    var style: UIStatusBarStyle = .lightContent
    var animation: UIStatusBarAnimation = .fade
    var key: String = defaultKey
    // 子节点
    var subStates: [StatusBarState] = []
    // 父节点
    weak var superState: StatusBarState?
    // 选中子节点，没有选中说明没有子状态
    weak var selectedState: StatusBarState?
}

/// 全局状态栏状态管理单例类
class StatusBarManager {
    static let shared = StatusBarManager()
    // MARK: - 属性
    /// 状态键集合，用来判断树中是否有某个状态
    fileprivate var stateKeys: Set<String> = Set<String>()
    /// 根节点状态
    fileprivate var rootState: StatusBarState!
    /// 更新状态栏动画时间
    fileprivate var duration: TimeInterval = 0.1
    /// 当前状态
    var currentState: StatusBarState!
    
    /// 以下3个计算属性都是取当前状态显示以及更新当前状态
    var isHidden: Bool {
        get {
            return currentState.isHidden
        }
        set {
            setState(for: currentState.key, isHidden: newValue)
        }
    }
    var style: UIStatusBarStyle {
        get {
            return currentState.style
        }
        set {
            setState(for: currentState.key, style: newValue)
        }
    }
    var animation: UIStatusBarAnimation {
        get {
            return currentState.animation
        }
        set {
            setState(for: currentState.key, animation: newValue)
        }
    }
    
    // MARK: - 方法
    /// 初始化根节点
    fileprivate init() {
        rootState = StatusBarState()
        rootState.superState = rootState
        currentState = rootState
        stateKeys.insert(rootState.key)
    }
    
    /// 为某个状态(root)添加子状态(key)，当 root = nil 时，表示添加到当前状态上
    @discardableResult
    func addSubState(with key: String, root: String? = nil) -> StatusBarState? {
        guard !stateKeys.contains(key) else { return nil }
        stateKeys.insert(key)
        
        let newState = StatusBarState()
        newState.key = key
        
        // 找到键为 root 的父状态
        var superState: StatusBarState! = currentState
        if let root = root {
            superState = findState(root)
        }
        newState.isHidden = superState.isHidden
        newState.style = superState.style
        newState.animation = superState.animation
        newState.superState = superState
        
        // 添加进父状态的子状态集合中，默认选中第一个
        superState.subStates.append(newState)
        if superState.selectedState == nil {
            superState.selectedState = newState
        }
        
        return newState
    }
    
    /// 批量添加子状态
    func addSubStates(with stateKeys: [String], root: String? = nil) {
        stateKeys.forEach { (key) in
            addSubState(with: key, root: root)
        }
    }
    
    /// 更改某个状态(root)下要显示的子状态(key)
    func showState(for key: String, root: String? = nil) {
        guard stateKeys.contains(key) else { return }
        
        // 改变父状态 selectedState 属性
        let rootState = findState(root)
        for subState in rootState.subStates {
            if subState.key == key {
                rootState.selectedState = subState
                break
            }
        }
        // 找到切换后的最底层状态
        currentState = findCurrentStateInTree(rootState)
        updateStatusBar()
    }
    
    /// 删除某个状态下的所有子状态
    func clearSubStates(with key: String) {
        
        let state = findState(key)
        if findStateInTree(state, key: currentState.key) != nil {
            currentState = state
        }
        removeSubStatesInTree(state)
        updateStatusBar()
    }
    
    /// 在当前状态下压入一个新状态
    func pushState(with key: String) {
        if let newState = addSubState(with: key) {
            currentState = newState
            updateStatusBar()
        }
    }
    
    /// 弹出当前状态
    func popState() {
        guard stateKeys.count > 1 else { return }
        let superState = currentState.superState
        currentState = superState
        removeSubStatesInTree(currentState)
        updateStatusBar()
    }
    
    /// 负责打印状态树结构
    func printAllStates() {
        printAllStatesInTree(rootState)
    }

    /// 更新栈中 key 对应的状态，key == nil 表示栈顶状态
    func setState(for key: String? = nil, isHidden: Bool? = nil, style: UIStatusBarStyle? = nil, animation: UIStatusBarAnimation? = nil) {
        var needUpdate: Bool = false
        let state = findState(key)
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
        // key != nil 表示更新对应 key 的状态，需要判断该状态是否是当前状态
        if let key = key {
            guard let currentState = currentState, currentState.key == key else { return }
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
    
    /// 从状态树中找到对应的节点状态，没找到就返回根节点
    fileprivate func findState(_ key: String? = nil) -> StatusBarState {
        if let key = key { // 查找
            if let findState = findStateInTree(rootState, key: key) {
                return findState
            }
        }
        return rootState
    }
    
    /// 从状态树中找到对应的节点状态的递归方法
    fileprivate func findStateInTree(_ state: StatusBarState, key: String) -> StatusBarState? {
        if state.key == key {
            return state
        }
        for subState in state.subStates {
            if let findState = findStateInTree(subState, key: key) {
                return findState
            }
        }
        return nil
    }
    
    /// 删除某个状态下的所有子状态的递归方法
    fileprivate func removeSubStatesInTree(_ state: StatusBarState) {
        state.subStates.forEach { (subState) in
            stateKeys.remove(subState.key)
            removeSubStatesInTree(subState)
        }
        state.subStates.removeAll()
    }
    
    /// 找到某个状态下的最底层状态
    fileprivate func findCurrentStateInTree(_ state: StatusBarState) -> StatusBarState? {
        if let selectedState = state.selectedState {
            return findCurrentStateInTree(selectedState)
        }
        return state
    }
    
    /// 打印状态树结构的递归方法
    fileprivate func printAllStatesInTree(_ state: StatusBarState, deep: Int = 0) {
        print("\(deep) - key=\(state.key) stateKeys.count=\(stateKeys.count)")
        for subState in state.subStates {
            printAllStatesInTree(subState, deep: deep + 1)
        }
    }
}
