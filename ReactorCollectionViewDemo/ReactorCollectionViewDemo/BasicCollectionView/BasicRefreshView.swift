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

/// 基础列表刷新控件
open class BasicRefreshView: UIView, View {

    /// 进入刷新前的滑动控件顶部/底部间距
    open var insetBeforRefresh: CGFloat = 0
    /// 正在刷新时的滑动控件顶部/底部间距
    open var insetInRefreshing: CGFloat = 0
    /// 加载控件类
    open var loadingClass: BasicLoadingView.Type = BasicLoadingView.self
    /// 加载控件
    open var loadingView: BasicLoadingView?
    /// 刷新间距变化动画时间
    open var duration: TimeInterval = 0.3
    /// 资源管理
    open var disposeBag = DisposeBag()
    /// 将要刷新的滑动控件
    open weak fileprivate(set) var refreshView: UIScrollView?
    /// 是否正在刷新
    open var isRefreshing: Bool {
        return self.reactor?.currentState.isRefreshing ?? false
    }
    
    /// 滑动偏移转化为刷新进度，子类可重载进行修改
    open var scrollMapToProgress: (CGFloat) -> CGFloat {
        return { offsetY in
            return offsetY
        }
    }
    
    /// 刷新高度默认为视图高度
    open var refreshHeight: CGFloat {
        return max(1, self.frame.size.height)
    }
    
    /// 初始化方法
    public required init(frame: CGRect, refreshView: UIScrollView?) {
        super.init(frame: frame)
        self.refreshView = refreshView
        setupSubviews()
    }
    /// 初始化方法
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupSubviews()
    }
    
    /// 子控件初始化方法
    open func setupSubviews() {
        self.backgroundColor = UIColor.clear
    }
    
    /// 添加加载控件
    open func addLoadingView(reactor: BasicLoadingReactor) {
        if let loadingView = self.loadingView {
            loadingView.reactor = reactor
            return
        } else {
            let loadingView = loadingClass.init(frame: self.bounds)
            loadingView.reactor = reactor
            self.addSubview(loadingView)
            self.loadingView = loadingView
        }
    }

    /// 绑定事件处理器
    open func bind(reactor: BasicRefreshReactor) {
        
        let isRefreshingObservable =
            reactor.state.asObservable()
                .map({ $0.isRefreshing })
                .distinctUntilChanged()
                .skip(1)
                .shareReplay(1)
                .observeOn(MainScheduler.instance)
        
        // 刷新状态变化，重置刷新间距
        isRefreshingObservable
            .subscribe(onNext: { [weak self] (isRefreshing) in
                guard let strongSelf = self else { return }
                strongSelf.resetScrollViewContentInset(isRefreshing: isRefreshing)
            }).disposed(by: disposeBag)
        
        // 结束刷新自动隐藏
        reactor.state.asObservable()
            .map({ $0.isHidden })
            .distinctUntilChanged()
            .observeOn(MainScheduler.instance)
            .bind(to: self.rx.isHidden)
            .disposed(by: disposeBag)
        
        // 加载动画开始或结束
        if let loadingReactor = reactor.loadingReactor {
            // 添加加载控件
            addLoadingView(reactor: loadingReactor)
            
            // 开启加载动画或结束加载动画
            isRefreshingObservable
                .map({ $0 ? BasicLoadingReactor.Action.startLoading : BasicLoadingReactor.Action.stopLoading })
                .bind(to: loadingReactor.action)
                .disposed(by: disposeBag)
        }
        
        // 滑动事件监听，执行滑动动效
        if let scrollView = self.refreshView {
            scrollView.rx.contentOffset
                .map({ [unowned self] in return self.scrollMapToProgress($0.y) })
                .map({ Reactor.Action.pull(progress: $0) })
                .bind(to: reactor.action)
                .disposed(by: disposeBag)
        }
    }
    
    /// 根据刷新状态重新设置顶部或底部刷新间距
    open func resetScrollViewContentInset(isRefreshing: Bool) {
    }
}
