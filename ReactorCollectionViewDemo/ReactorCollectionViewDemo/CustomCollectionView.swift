//
//  CustomCollectionView.swift
//  ReactorCollectionViewDemo
//
//  Created by luhe liu on 2018/5/31.
//  Copyright © 2018年 luhe liu. All rights reserved.
//

import UIKit
import ReactorKit
import RxSwift
import RxCocoa

class CustomCollectionView: RxBasicCollectionView {
    
    var lastScrollOffset: CGPoint = .zero
    
    override var canPreLoadMore: Bool {
        debugPrint("smoothScrollOffset \(smoothScrollOffset)")
        return super.canPreLoadMore
    }
    
    override init(frame: CGRect, layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()) {
        super.init(frame: frame, layout: layout)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    deinit {
        print("CustomCollectionView dealloc")
    }
    
    override func setupSubviews() {
        self.headerRefreshClass = CustomHeaderRefreshView.self
        self.footerRefreshClass = CustomFooterRefreshView.self
        self.placeholderView = CustomPlaceholderView(frame: self.bounds)
        defaultHeaderRefreshHeight = 60
        loadFirstInset = 60
        defaultFooterRefreshHeight = 60
        preloadNextInset = self.frame.size.height * 0.5
    }
}

// MARK: - 解决刷新前后 ContentOffset 突变问题
extension CustomCollectionView {

    var smoothScrollOffset: CGPoint {
        var scrollOffset: CGPoint = CGPoint(x: self.contentOffset.x + self.contentInset.left,
                                            y: self.contentOffset.y + self.contentInset.top)
        var offset: CGFloat = 0
        if let headerRefreshView = headerRefreshView {
            let refreshOffset = headerRefreshView.refreshHeight
            switch scrollDirection {
            case .vertical:
                offset = abs(lastScrollOffset.y - scrollOffset.y)
            case .horizontal:
                offset = abs(lastScrollOffset.x - scrollOffset.x)
            }
            if !headerRefreshView.isEndRefresh {
                switch scrollDirection {
                case .horizontal:
                    scrollOffset.x = lastScrollOffset.x + (offset - refreshOffset) * 0.4
                case .vertical:
                    scrollOffset.y = lastScrollOffset.y + (offset - refreshOffset) * 0.4
                }
            }
        }
        lastScrollOffset = scrollOffset
        return scrollOffset
    }
    
    func setContentInsetWithRefreshState(_ inset: UIEdgeInsets) {
        var newInset = inset
        if let headerRefreshView = headerRefreshView, headerRefreshView.isRefreshing {
            switch scrollDirection {
            case .vertical:
                newInset.top += headerRefreshView.refreshHeight
            case .horizontal:
                newInset.left += headerRefreshView.refreshHeight
            }
        }
        super.contentInset = newInset
    }
}
