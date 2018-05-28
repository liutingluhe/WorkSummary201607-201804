//
//  BasicHeaderRefreshView.swift
//  ReactorCollectionViewDemo
//
//  Created by luhe liu on 2018/5/24.
//  Copyright © 2018年 luhe liu. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import ReactorKit

public enum RefreshPosition {
    case header
    case footer
}

open class BasicRefreshView: UIView, View {

    fileprivate var insetBeforRefresh: CGFloat = 0
    fileprivate var insetInRefreshing: CGFloat = 0
    fileprivate var position: RefreshPosition = .header
    
    open var loadingView: BasicLoadingView?
    open var disposeBag = DisposeBag()
    open var needSetContentOffset: Bool = true
    open weak var refreshView: UIScrollView?
    open var isRefreshing: Bool {
        return self.reactor?.currentState.isRefreshing ?? false
    }
    
    open var scrollMapToProgress: (CGFloat) -> CGFloat {
        return { [weak self] offsetY in
            guard let strongSelf = self else { return 0.0 }
            let refreshHeight: CGFloat = max(1, strongSelf.frame.size.height)
            if let scrollView = strongSelf.refreshView {
                switch strongSelf.position {
                case .header:
                    return (offsetY + scrollView.contentInset.top) / refreshHeight
                case .footer:
                    return (offsetY - scrollView.contentSize.height + UIScreen.main.bounds.size.height) / refreshHeight
                }
            }
            return 0.0
        }
    }
    
    public init(frame: CGRect, refreshView: UIScrollView?, position: RefreshPosition = .header) {
        super.init(frame: frame)
        self.position = position
        self.refreshView = refreshView
        setupSubviews()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupSubviews()
    }
    
    open func setupSubviews() {
    }
    
    open func addLoadingView(reactor: BasicLoadingReactor) {
        if let loadingView = self.loadingView {
            loadingView.reactor = reactor
            return
        } else {
            let loadingView = BasicLoadingView(frame: self.bounds)
            loadingView.reactor = reactor
            self.addSubview(loadingView)
            self.loadingView = loadingView
        }
    }

    open func bind(reactor: BasicRefreshReactor) {
        
        let isRefreshingObservable =
            reactor.state.asObservable()
                .map({ $0.isRefreshing })
                .distinctUntilChanged()
                .skip(1)
                .shareReplay(1)
                .observeOn(MainScheduler.instance)
            
        isRefreshingObservable
            .subscribe(onNext: { [weak self] (isRefreshing) in
                guard let strongSelf = self else { return }
                strongSelf.resetScrollViewContentInset(isRefreshing: isRefreshing)
            }).disposed(by: disposeBag)
        
        if let scrollView = self.refreshView {
            
            scrollView.rx.contentOffset
                .map({ [unowned self] in return self.scrollMapToProgress($0.y) })
                .map({ Reactor.Action.pull(progress: $0) })
                .bind(to: reactor.action)
                .disposed(by: disposeBag)
        }
        
        if let loadingReactor = reactor.loadingReactor {
            addLoadingView(reactor: loadingReactor)
            isRefreshingObservable
                .map({ $0 ? BasicLoadingReactor.Action.startLoading : BasicLoadingReactor.Action.stopLoading })
                .bind(to: loadingReactor.action)
                .disposed(by: disposeBag)
        }
        
    }

    open func resetScrollViewContentInset(isRefreshing: Bool) {
        guard let scrollView = self.refreshView else { return }
        var contentInset: CGFloat = self.position == .header ? scrollView.contentInset.top : scrollView.contentInset.bottom
        let duration: TimeInterval = 0.3
        if isRefreshing {
            insetBeforRefresh = contentInset
            contentInset += self.frame.size.height
            insetInRefreshing = contentInset
        } else {
            contentInset -= insetInRefreshing - insetBeforRefresh
        }
        
        UIView.animate(withDuration: duration, delay: 0.0, options: .curveEaseInOut, animations: {
            if self.position == .header {
                scrollView.contentInset.top = contentInset
                if isRefreshing && self.needSetContentOffset {
                    scrollView.setContentOffset(CGPoint(x: 0, y: -contentInset), animated: true)
                }
            } else {
                scrollView.contentInset.bottom = contentInset
            }
        })
    }
}
