//
//  UIViewController+StatusBar.swift
//  StatusBarManagerDemo
//
//  Created by luhe liu on 2018/4/23.
//  Copyright © 2018年 com.liuting. All rights reserved.
//

import UIKit

extension UIViewController {
    
    /// 控制器的状态栏唯一键
    var statusBarKey: String {
        return "\(self)"
    }
    
    /// 设置该控制器的状态栏状态
    func setStatusBar(isHidden: Bool? = nil, style: UIStatusBarStyle? = nil, animation: UIStatusBarAnimation? = nil) {
        StatusBarManager.shared.setState(for: statusBarKey, isHidden: isHidden, style: style, animation: animation)
    }

    /// 添加一个子状态
    func addSubStatusBar(for viewController: UIViewController) {
        let superKey = self.statusBarKey
        let subKey = viewController.statusBarKey
        StatusBarManager.shared.addSubState(with: subKey, root: superKey)
    }
    
    /// 批量添加子状态，树横向生长
    func addSubStatusBars(for viewControllers: [UIViewController]) {
        viewControllers.forEach { (viewController) in
            self.addSubStatusBar(for: viewController)
        }
    }
    
    /// 从整个状态树上删除当前状态
    func removeFromSuperStatusBar() {
        let key = self.statusBarKey
        StatusBarManager.shared.removeState(with: key)
    }
    
    /// 设置当前状态下的所有子状态
    func setSubStatusBars(for viewControllers: [UIViewController]?) {
        clearSubStatusBars()
        if let viewControllers = viewControllers {
            addSubStatusBars(for: viewControllers)
        }
    }
    
    /// 通过类似压栈的形式，压入一组状态，树纵向生长
    func pushStatusBars(for viewControllers: [UIViewController]) {
        var lastViewController: UIViewController? = self
        viewControllers.forEach { (viewController) in
            if let superController = lastViewController {
                superController.addSubStatusBar(for: viewController)
                lastViewController = viewController
            }
        }
    }
    
    /// 切换多个子状态的某个子状态
    func showStatusBar(for viewController: UIViewController?) {
        guard let viewController = viewController else { return }
        let superKey = self.statusBarKey
        let subKey = viewController.statusBarKey
        StatusBarManager.shared.showState(for: subKey, root: superKey)
    }
    
    /// 清除所有子状态
    func clearSubStatusBars(isUpdate: Bool = true) {
        StatusBarManager.shared.clearSubStates(with: self.statusBarKey, isUpdate: isUpdate)
    }
}
