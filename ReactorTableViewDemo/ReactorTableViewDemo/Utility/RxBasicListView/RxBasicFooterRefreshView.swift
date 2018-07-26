//
//  RxBasicFooterRefreshView.swift
//  ReactorCollectionViewDemo
//
//  Created by luhe liu on 2018/5/30.
//  Copyright © 2018年 luhe liu. All rights reserved.
//

import UIKit
import ReactorKit
import RxSwift
import RxCocoa

/// 基础列表底部刷新控件
open class RxBasicFooterRefreshView: RxBasicRefreshView {
    
    /// 是否已经重置了刷新间距
    open fileprivate(set) var didResetBottomInset: Bool = true
    /// 是否能加载更多
    open var canLoadMore: Bool = false {
        didSet {
            updateLoadMoreState()
        }
    }

    /// 滑动偏移转化为刷新进度，子类可重载进行修改
    open override var scrollMapToProgress: (CGFloat) -> CGFloat {
        return { [weak self] offsetY in
            guard let strongSelf = self, let scrollView = strongSelf.scrollView else { return 0.0 }
            return (offsetY - scrollView.contentSize.height + UIScreen.main.bounds.size.height) / strongSelf.refreshHeight
        }
    }
    
    public required init(frame: CGRect, scrollView: UIScrollView?) {
        super.init(frame: frame, scrollView: scrollView)
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    open override func setupSubviews() {
        super.setupSubviews()
    }
    
    /// 更新是否加载到最后一页的状态
    open func updateLoadMoreState() {
        if !canLoadMore {
            guard !didResetBottomInset, let scrollView = self.scrollView else { return }
            didResetBottomInset = true
            let contentInset = scrollView.contentInset.bottom - (insetInRefreshing - insetBeforRefresh)
            UIView.animate(withDuration: duration, delay: 0.0, options: .curveEaseInOut, animations: {
                scrollView.contentInset.bottom = contentInset
            })
        }
    }
    
    /// 根据刷新状态重新设置顶部或底部刷新间距
    open override func resetScrollViewContentInset(isRefreshing: Bool) {
        guard let scrollView = self.scrollView, isRefreshing else { return }
        guard didResetBottomInset else { return }
        didResetBottomInset = false
        var contentInset: CGFloat = scrollView.contentInset.bottom
        insetBeforRefresh = contentInset
        contentInset += refreshHeight
        insetInRefreshing = contentInset
        UIView.animate(withDuration: duration, delay: 0.0, options: .curveEaseInOut, animations: {
            scrollView.contentInset.bottom = contentInset
        })
    }
}
