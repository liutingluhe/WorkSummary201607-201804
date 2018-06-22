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
    
    public required init(frame: CGRect, refreshView: UIScrollView?) {
        super.init(frame: frame, refreshView: refreshView)
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    /// 滑动偏移转化为刷新进度，子类可重载进行修改
    open override var scrollMapToProgress: (CGFloat) -> CGFloat {
        return { [weak self] offsetY in
            guard let strongSelf = self, let scrollView = strongSelf.refreshView else { return 0.0 }
            return -(offsetY + scrollView.contentInset.top) / strongSelf.refreshHeight
        }
    }
    
    /// 根据刷新状态重新设置顶部或底部刷新间距
    open override func resetScrollViewContentInset(isRefreshing: Bool) {
        guard let scrollView = self.refreshView else { return }
        var contentInset: CGFloat = scrollView.contentInset.top
        
        if isRefreshing {
            insetBeforRefresh = contentInset
            contentInset += self.frame.size.height
            insetInRefreshing = contentInset
        } else {
            contentInset -= insetInRefreshing - insetBeforRefresh
        }
        UIView.animate(withDuration: duration, delay: 0.0, options: .curveEaseInOut, animations: {
            scrollView.contentInset.top = contentInset
            if isRefreshing && self.needSetContentOffset {
                scrollView.setContentOffset(CGPoint(x: 0, y: -contentInset), animated: true)
            }
        })
    }
}
