//
//  UIView+RxConvenient.swift
//  ifanr
//
//  Created by luhe liu on 2018/6/26.
//  Copyright © 2018年 com.ifanr. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift
import RxGesture

extension Reactive where Base: UIView {
    public var backgroundColor: UIBindingObserver<Base, UIColor> {
        return UIBindingObserver(UIElement: base) { view, color in
            view.backgroundColor = color
        }
    }
    
    public var width: UIBindingObserver<Base, CGFloat> {
        return UIBindingObserver(UIElement: base) { view, width in
            view.frame.size.width = width
        }
    }
    
    public var height: UIBindingObserver<Base, CGFloat> {
        return UIBindingObserver(UIElement: base) { view, height in
            view.frame.size.height = height
        }
    }
    
    public func alphaWithAnimated(duration: TimeInterval = 0.1) -> UIBindingObserver<Base, CGFloat> {
        return UIBindingObserver(UIElement: base) { view, alpha in
            UIView.animate(withDuration: duration, animations: {
                view.alpha = alpha
            })
        }
    }
    
    public var tapFailurePan: Observable<UITapGestureRecognizer> {
        return self.tapGesture(configuration: { (_, delegate) in
            delegate.otherFailureRequirementPolicy = .custom { _, otherGestureRecognizer in
                if otherGestureRecognizer is UIPanGestureRecognizer { return true }
                return false
            }
        }).when(.recognized)
    }
    
    public var tapFailurePanOrTap: Observable<UITapGestureRecognizer> {
        return self.tapGesture(configuration: { (_, delegate) in
            delegate.otherFailureRequirementPolicy = .custom { _, otherGestureRecognizer in
                if otherGestureRecognizer is UIPanGestureRecognizer { return true }
                if otherGestureRecognizer is UITapGestureRecognizer { return true }
                return false
            }
        }).when(.recognized)
    }
}
