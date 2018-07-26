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
}

/// 基础列表控件 Rx 扩展
public extension Reactive where Base: RxBasicCollectionView {
    public var footerFollow: UIBindingObserver<Base, CGFloat> {
        return UIBindingObserver(UIElement: self.base) { view, contentHeight in
            view.updateFooterRefeshViewState(with: contentHeight)
        }
    }
    
}

/// 基础刷新控件 Rx 扩展
public extension Reactive where Base: RxBasicRefreshView {
    public var isRefreshing: UIBindingObserver<Base, Bool> {
        return UIBindingObserver(UIElement: self.base) { view, isRefreshing in
            view.resetScrollViewContentInset(isRefreshing: isRefreshing)
        }
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
