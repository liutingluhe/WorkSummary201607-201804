//
//  Nibloadable.swift
//  ifanr
//
//  Created by luhe liu on 2018/6/25.
//  Copyright © 2018年 com.ifanr. All rights reserved.
//

import UIKit

public protocol Nibloadable {
    func loadViewFromNib(index: Int) -> UIView
}

extension Nibloadable where Self: UIView {
    public static func loadNib(index: Int = 0) -> Self {
        let nibName = self.className
        let nib = UINib(nibName: nibName, bundle: nil)
        if let views = nib.instantiate(withOwner: self, options: nil) as? [UIView] {
            if let view = views.safeIndex(index) as? Self {
                return view
            }
        }
        return Self.init()
    }
}

extension UIView: Nibloadable {
    public func loadViewFromNib(index: Int = 0) -> UIView {
        let classInstance = type(of: self)
        let nibName = classInstance.className
        let nib = UINib(nibName: nibName, bundle: nil)
        if let views = nib.instantiate(withOwner: self, options: nil) as? [UIView] {
            if let view = views.safeIndex(index) {
                return view
            }
        }
        return UIView()
    }
}
