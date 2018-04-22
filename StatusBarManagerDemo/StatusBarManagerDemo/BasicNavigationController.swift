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
    override var childViewControllerForStatusBarHidden: UIViewController? {
        return self.topViewController
    }
    override var childViewControllerForStatusBarStyle: UIViewController? {
        return self.topViewController
    }

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func pushViewController(_ viewController: UIViewController, animated: Bool) {
        StatusBarManager.shared.pushState(with: "\(viewController)")
        super.pushViewController(viewController, animated: animated)
    }
}
