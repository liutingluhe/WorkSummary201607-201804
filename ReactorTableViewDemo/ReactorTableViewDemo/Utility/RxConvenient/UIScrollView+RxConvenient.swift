//
//  UIButton+RxConvenient.swift
//  ifanr
//
//  Created by luhe liu on 2018/6/26.
//  Copyright © 2018年 com.ifanr. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

extension Reactive where Base: UIScrollView {
    
    public var contentSize: Observable<CGSize> {
        return self.observeWeakly(CGSize.self, "contentSize", options: .new).map { $0 ?? .zero }
    }
}
