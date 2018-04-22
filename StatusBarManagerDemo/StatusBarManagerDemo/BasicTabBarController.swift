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
    override var childViewControllerForStatusBarStyle: UIViewController? {
        return self.selectedViewController
    }
    override var childViewControllerForStatusBarHidden: UIViewController? {
        return self.selectedViewController
    }
    
    override var selectedIndex: Int {
        get {
            return super.selectedIndex
        }
        set {
            if let viewControllers = super.viewControllers {
                let selectedViewController = viewControllers[newValue]
                StatusBarManager.shared.showState(for: "\(selectedViewController)", root: "\(self)")
            }
            super.selectedIndex = newValue
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        if let viewControllers = viewControllers {
            let keys = viewControllers.map({ "\($0)" })
            StatusBarManager.shared.clearSubStates(with: "\(self)")
            StatusBarManager.shared.addSubStates(with: keys)
            self.selectedIndex = 0
        }
        self.delegate = self
        
    }
    
    override func setViewControllers(_ viewControllers: [UIViewController]?, animated: Bool) {
        if let viewControllers = viewControllers {
            let keys = viewControllers.map({ "\($0)" })
            StatusBarManager.shared.clearSubStates(with: "\(self)")
            StatusBarManager.shared.addSubStates(with: keys)
        }
        super.setViewControllers(viewControllers, animated: animated)
    }
    
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        if let viewControllers = viewControllers, let index = viewControllers.index(of: viewController) {
            self.selectedIndex = index
        }
    }
}
