//
//  UIControl+Convenient.swift
//  ifanr
//
//  Created by luhe liu on 2018/6/25.
//  Copyright © 2018年 com.ifanr. All rights reserved.
//

import UIKit

fileprivate extension Selector {
    static let scaleToSmall = #selector(UIControl.scaleToSmall)
    static let scaleAnimationWithSpring = #selector(UIControl.scaleAnimationWithSpring)
    static let scaleToDefault = #selector(UIControl.scaleToDefault)
}

public extension UIControl {
    
    public func removeAnimatedTarget() {
        self.removeTarget(self, action: .scaleToSmall, for: .touchUpInside)
        self.removeTarget(self, action: .scaleAnimationWithSpring, for: .touchUpInside)
        self.removeTarget(self, action: .scaleToDefault, for: .touchDragExit)
    }
    
    public func addTargetForAnimation() {
        self.addTarget(self, action: .scaleToSmall, for: .touchUpInside)
        self.addTarget(self, action: .scaleAnimationWithSpring, for: .touchUpInside)
        self.addTarget(self, action: .scaleToDefault, for: .touchDragExit)
    }
    
    @objc fileprivate func scaleToSmall() {
        UIView.animate(withDuration: 0.2, animations: {
            self.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
        }, completion: nil)
    }
    
    @objc fileprivate func scaleAnimationWithSpring() {
        UIView.animate(withDuration: 0.35, delay: 0.0, usingSpringWithDamping: 1.0, initialSpringVelocity: 0, options: UIViewAnimationOptions(), animations: {
            self.transform = CGAffineTransform.identity
        }, completion: nil)
    }
    
    @objc fileprivate func scaleToDefault() {
        UIView.animate(withDuration: 0.2, delay: 0.0, usingSpringWithDamping: 1.0, initialSpringVelocity: 0, options: UIViewAnimationOptions(), animations: {
            self.transform = CGAffineTransform.identity
        }, completion: nil)
    }
}
