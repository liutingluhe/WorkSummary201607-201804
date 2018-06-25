//
//  RxBasicHeaderRefreshView.swift
//  ReactorCollectionViewDemo
//
//  Created by luhe liu on 2018/5/30.
//  Copyright © 2018年 luhe liu. All rights reserved.
//

import UIKit
import ReactorKit
import RxSwift
import RxCocoa

/// 基础列表顶部刷新控件
open class RxBasicHeaderRefreshView: RxBasicRefreshView {
    
    /// 是否需要在顶部刷新时设置 ContentOffset
    open var needSetContentOffset: Bool = true
    /// 是否已经结束刷新
    open fileprivate(set) var isEndRefresh: Bool = true
    
    open lazy var displayLink: CADisplayLink = {
        let displayLink = CADisplayLink(target: self, selector: #selector(RxBasicHeaderRefreshView.refreshEnding))
        displayLink.add(to: RunLoop.main, forMode: .commonModes)
        displayLink.isPaused = true
        return displayLink
    }()
    
    public required init(frame: CGRect, scrollView: UIScrollView?) {
        super.init(frame: frame, scrollView: scrollView)
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    deinit {
        displayLink.isPaused = true
        displayLink.remove(from: RunLoop.main, forMode: .commonModes)
    }
    
    /// 滑动偏移转化为刷新进度，子类可重载进行修改
    open override var scrollMapToProgress: (CGFloat) -> CGFloat {
        return { [weak self] offsetY in
            guard let strongSelf = self, let scrollView = strongSelf.scrollView else { return 0.0 }
            return -(offsetY + scrollView.contentInset.top) / strongSelf.refreshHeight
        }
    }
    
    /// 根据刷新状态重新设置顶部或底部刷新间距
    open override func resetScrollViewContentInset(isRefreshing: Bool) {
        guard let scrollView = self.scrollView else { return }
        var contentInset: CGFloat = scrollView.contentInset.top
        
        if isRefreshing {
            insetBeforRefresh = contentInset
            contentInset += refreshHeight
            insetInRefreshing = contentInset
            willRefresh()
        } else {
            contentInset -= insetInRefreshing - insetBeforRefresh
            willEndRefresh()
        }
        
        UIView.animate(withDuration: duration, delay: 0.0, options: .curveEaseInOut, animations: {
            scrollView.contentInset.top = contentInset
            if isRefreshing && self.needSetContentOffset {
                scrollView.setContentOffset(CGPoint(x: 0, y: -contentInset), animated: true)
            }
        }, completion: { _ in
            self.didFinishContentInsetReset()
        })
    }
    
    open func willRefresh() {
        isEndRefresh = false
    }
    
    open func didRefresh() {
    }
    
    open func willEndRefresh() {
        displayLink.isPaused = false
    }
    
    open func didEndRefresh() {
        displayLink.isPaused = true
        isEndRefresh = true
    }
    
    @objc open func refreshEnding() {
        guard let scrollView = self.scrollView else { return }
        if let delegate = scrollView.delegate, let didScroll = delegate.scrollViewDidScroll {
            didScroll(scrollView)
        }
    }
    
    open func didFinishContentInsetReset() {
        if isRefreshing {
            didRefresh()
        } else {
            didEndRefresh()
        }
    }
}
