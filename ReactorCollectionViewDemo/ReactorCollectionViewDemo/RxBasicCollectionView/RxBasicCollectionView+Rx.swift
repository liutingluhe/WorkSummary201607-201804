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

public extension Reactive where Base: UICollectionView {
    /// 刷新
    public var reload: UIBindingObserver<Base, Bool> {
        return UIBindingObserver(UIElement: base) { collectionView, isReload in
            if isReload {
                collectionView.reloadData()
            }
        }
    }
    
    /// 内容尺寸大小
    public var contentSize: Observable<CGSize> {
        return self.observeWeakly(CGSize.self, "contentSize")
            .map({ $0 ?? .zero })
    }
}

/// 基础加载控件 Rx 扩展
public extension Reactive where Base: RxBasicLoadingView {
    /// 是否开始加载动画
    public var isAnimating: UIBindingObserver<Base, Bool> {
        return UIBindingObserver(UIElement: self.base) { view, active in
            if active {
                view.startAnimating()
            } else {
                view.stopAnimating()
            }
        }
    }
    /// 设置动画进度
    public var progress: UIBindingObserver<Base, CGFloat> {
        return UIBindingObserver(UIElement: self.base) { view, progress in
            view.updateProgress(progress)
        }
    }
}

/// 基础加载控件 Rx 扩展
public extension Reactive where Base: RxBasicFooterRefreshView {
    /// 是否可以加载更多
    public var canLoadMore: UIBindingObserver<Base, Bool> {
        return UIBindingObserver(UIElement: self.base) { view, canLoadMore in
            view.canLoadMore = canLoadMore
        }
    }
}

/// 基础占位控件 Rx 扩展
public extension Reactive where Base: RxBasicPlaceholderView {
    /// 是否开始加载动画
    public var isNetworkError: UIBindingObserver<Base, Bool> {
        return UIBindingObserver(UIElement: self.base) { view, isError in
            view.isNetworkError = isError
        }
    }
}
