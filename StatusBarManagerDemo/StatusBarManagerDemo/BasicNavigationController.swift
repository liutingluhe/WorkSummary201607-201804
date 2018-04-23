//
//  BasicNavigationController.swift
//  StatusBarManagerDemo
//
//  Created by luhe liu on 2018/4/11.
//  Copyright © 2018年 com.liuting. All rights reserved.
//

import UIKit

/// 保证所有控制器都重载了 prefersStatusBarHidden 的方法
class BasicNavigationController: UINavigationController {
    
    override var prefersStatusBarHidden: Bool {
        return StatusBarManager.shared.isHidden
    }
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return StatusBarManager.shared.style
    }
    override var preferredStatusBarUpdateAnimation: UIStatusBarAnimation {
        return StatusBarManager.shared.animation
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        pushStatusBars(for: viewControllers)
    }
    
    override func setViewControllers(_ viewControllers: [UIViewController], animated: Bool) {
        clearSubStatusBars(isUpdate: false)
        pushStatusBars(for: viewControllers)
        super.setViewControllers(viewControllers, animated: animated)
    }
    
    override func pushViewController(_ viewController: UIViewController, animated: Bool) {
        topViewController?.addSubStatusBar(for: viewController)
        super.pushViewController(viewController, animated: animated)
    }
}
