//
//  UILabel+RxConvenient.swift
//  ifanr
//
//  Created by luhe liu on 2018/6/26.
//  Copyright © 2018年 com.ifanr. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift

extension Reactive where Base: UILabel {
    public var textColor: UIBindingObserver<Base, UIColor> {
        return UIBindingObserver(UIElement: base) { label, result in
            label.textColor = result
        }
    }
    
    public var font: UIBindingObserver<Base, UIFont> {
        return UIBindingObserver(UIElement: base) { label, font in
            label.font = font
        }
    }
    
}
