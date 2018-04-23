//
//  BasicTabBarController.swift
//  StatusBarManagerDemo
//
//  Created by luhe liu on 2018/4/22.
//  Copyright © 2018年 com.liuting. All rights reserved.
//

import UIKit

/// 保证所有控制器都重载了 prefersStatusBarHidden 的方法
class BasicTabBarController: UITabBarController, UITabBarControllerDelegate {
    
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
        self.setSubStatusBars(for: viewControllers)
        self.delegate = self
    }
    
    override func setViewControllers(_ viewControllers: [UIViewController]?, animated: Bool) {
        self.setSubStatusBars(for: viewControllers)
        super.setViewControllers(viewControllers, animated: animated)
    }
    
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        showStatusBar(for: viewController)
    }
}
