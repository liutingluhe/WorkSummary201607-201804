//
//  UICollectionView+Rx.swift
//  RxTodo
//
//  Created by luhe liu on 2018/5/17.
//  Copyright © 2018年 Suyeol Jeon. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

extension Reactive where Base: UICollectionView {
    public var reload: UIBindingObserver<Base, Bool> {
        return UIBindingObserver(UIElement: base) { collectionView, isReload in
            if isReload {
                collectionView.reloadData()
            }
        }
    }
    
    public var contentSize: Observable<CGSize> {
        return self.observe(CGSize.self, "contentSize")
            .map({ $0 ?? .zero })
    }
    
}
