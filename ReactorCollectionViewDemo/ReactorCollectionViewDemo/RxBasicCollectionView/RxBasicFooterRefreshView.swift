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
    
    /// 是否需要在底部刷新后延时重置 ContentInsetBottom
    open var needDelayResetBottomInset: Bool = true
    /// 是否已经重置了刷新间距
    open fileprivate(set) var didResetBottomInset: Bool = true
    /// 是否能加载更多
    open var canLoadMore: Bool = true {
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
    
    /// 更新是否加载到最后一页的状态
    open func updateLoadMoreState() {
    }
    
    /// 用于底部刷新间距延时设置
    @objc open func delaySetContentInsetBottom(_ contentInset: CGFloat) {
        UIView.animate(withDuration: duration, delay: 0.0, options: .curveEaseInOut, animations: {
            self.scrollView?.contentInset.bottom = contentInset
        }, completion: { _ in
            self.didResetBottomInset = true
        })
    }
    
    /// 根据刷新状态重新设置顶部或底部刷新间距
    open override func resetScrollViewContentInset(isRefreshing: Bool) {
        guard let scrollView = self.scrollView else { return }
        var contentInset: CGFloat = scrollView.contentInset.bottom
        
        if isRefreshing {
            if needDelayResetBottomInset {
                // 取消延迟重置底部刷新间距
                NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(delaySetContentInsetBottom), object: insetBeforRefresh)
            }
            guard didResetBottomInset else { return }
            didResetBottomInset = false
            insetBeforRefresh = contentInset
            contentInset += refreshHeight
            insetInRefreshing = contentInset
        } else {
            guard !didResetBottomInset else { return }
            contentInset -= insetInRefreshing - insetBeforRefresh
            if needDelayResetBottomInset {
                // 开启延迟重置底部刷新间距
                self.perform(#selector(delaySetContentInsetBottom), with: contentInset, afterDelay: duration)
                return
            }
            didResetBottomInset = true
        }
        
        UIView.animate(withDuration: duration, delay: 0.0, options: .curveEaseInOut, animations: {
            scrollView.contentInset.bottom = contentInset
        })
    }
}
