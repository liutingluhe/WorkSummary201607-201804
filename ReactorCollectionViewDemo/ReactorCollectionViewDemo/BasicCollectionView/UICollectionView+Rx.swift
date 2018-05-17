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
    var reload: UIBindingObserver<Base, Bool> {
        return UIBindingObserver(UIElement: base) { collectionView, isReload in
            if isReload {
                collectionView.reloadData()
            }
        }
    }
}
