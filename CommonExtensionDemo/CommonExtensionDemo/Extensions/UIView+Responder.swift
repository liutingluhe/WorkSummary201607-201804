//
//  UIView+Responder.swift
//  CommonExtensionDemo
//
//  Created by catch on 18/3/25.
//  Copyright © 2018年 执着·执念. All rights reserved.
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
