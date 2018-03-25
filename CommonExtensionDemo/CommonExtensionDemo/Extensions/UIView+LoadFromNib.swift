//
//  UIView+LoadFromNib.swift
//  CommonExtensionDemo
//
//  Created by catch on 18/3/25.
//  Copyright © 2018年 执着·执念. All rights reserved.
//

import UIKit

extension UIView {
    
    /// 从 xib 中加载视图
    func loadViewFromNib(index: Int = 0) -> UIView? {
        let classInstance = type(of: self)
        let nibName = classInstance.className
        let nib = UINib(nibName: nibName, bundle: nil)
        
        if let views = nib.instantiate(withOwner: self, options: nil) as? [UIView] {
            return views.safeIndex(index)
        }
        return nil
    }
}
