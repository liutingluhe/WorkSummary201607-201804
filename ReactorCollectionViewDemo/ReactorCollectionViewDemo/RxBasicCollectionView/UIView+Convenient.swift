//
//  UIView+Convenient.swift
//  ReactorCollectionViewDemo
//
//  Created by luhe liu on 2018/6/21.
//  Copyright © 2018年 luhe liu. All rights reserved.
//

import UIKit

extension UIView {
    
    /// 寻找当前视图所在的控制器
    var responderController: UIViewController? {
        var nextReponder: UIResponder? = self.next
        while nextReponder != nil {
            if let viewController = nextReponder as? UIViewController {
                return viewController
            }
            nextReponder = nextReponder?.next
        }
        return nil
    }
}
