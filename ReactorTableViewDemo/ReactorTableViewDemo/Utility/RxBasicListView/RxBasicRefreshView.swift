//
//  RxBasicHeaderRefreshView.swift
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
open class RxBasicRefreshView: UIView {

    /// 进入刷新前的滑动控件间距
    open var insetBeforRefresh: CGFloat = 0
    /// 正在刷新时的滑动控件间距
    open var insetInRefreshing: CGFloat = 0
    /// 加载控件类，用于创建加载控件
    open var loadingClass: RxBasicLoadingView.Type = RxBasicLoadingView.self
    /// 加载控件，用于创建加载控件
    open var loadingView: RxBasicLoadingView?
    /// 刷新间距变化动画时间
    open var duration: TimeInterval = 0.3
    /// 将要刷新的滑动控件
    open weak fileprivate(set) var scrollView: UIScrollView?
    /// 资源管理
    open var basicDisposeBag = DisposeBag()
    /// 基础刷新处理器
    open var basicReactor: RxBasicRefreshReactor? {
        didSet {
            basicDisposeBag = DisposeBag()
            if let basicReactor = basicReactor {
                self.basicBind(reactor: basicReactor)
            }
        }
    }
    /// 是否正在刷新
    open var isRefreshing: Bool {
        return self.basicReactor?.currentState.isRefreshing ?? false
    }
    
    /// 滑动偏移转化为刷新进度，子类可重载进行修改
    open var scrollMapToProgress: (CGFloat) -> CGFloat {
        return { offsetY in
            return offsetY
        }
    }
    
    /// 刷新高度默认为视图高度
    open var refreshHeight: CGFloat {
        var refreshValue: CGFloat = self.frame.size.height
        if let scrollView = scrollView {
            if scrollView.alwaysBounceHorizontal {
                refreshValue = self.frame.size.width
            }
        }
        return max(1, refreshValue)
    }
    
    /// 初始化方法
    public required init(frame: CGRect, scrollView: UIScrollView?) {
        super.init(frame: frame)
        self.scrollView = scrollView
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
    open func addLoadingView(reactor: RxBasicLoadingReactor) {
        if let loadingView = self.loadingView {
            loadingView.basicReactor = reactor
            self.addSubview(loadingView)
        } else {
            let loadingView = loadingClass.init(frame: self.bounds)
            loadingView.basicReactor = reactor
            self.addSubview(loadingView)
            self.loadingView = loadingView
        }
    }

    /// 绑定事件处理器
    open func basicBind(reactor: RxBasicRefreshReactor) {
        
        let isRefreshingObservable =
            reactor.state.asObservable()
                .map({ $0.isRefreshing })
                .distinctUntilChanged()
                .skip(1)
                .shareReplay(1)
                .observeOn(MainScheduler.instance)
        
        // 刷新状态变化，重置刷新间距
        isRefreshingObservable
            .throttle(duration, scheduler: MainScheduler.instance)
            .bind(to: self.rx.isRefreshing)
            .disposed(by: basicDisposeBag)
        
        // 结束刷新自动隐藏
        reactor.state.asObservable()
            .map({ $0.isHidden })
            .distinctUntilChanged()
            .throttle(duration, scheduler: MainScheduler.instance)
            .bind(to: self.rx.isHidden)
            .disposed(by: basicDisposeBag)
        
        // 加载动画开始或结束
        if let loadingReactor = reactor.loadingReactor {
            // 添加加载控件
            addLoadingView(reactor: loadingReactor)
            
            // 开启加载动画或结束加载动画
            isRefreshingObservable
                .map({ $0 ? RxBasicLoadingReactor.Action.startLoading : RxBasicLoadingReactor.Action.stopLoading })
                .throttle(duration, scheduler: MainScheduler.instance)
                .bind(to: loadingReactor.action)
                .disposed(by: basicDisposeBag)
        }
        
        // 滑动事件监听，执行滑动动效
        if let scrollView = self.scrollView {
            scrollView.rx.contentOffset
                .map({ [unowned self] in return self.scrollMapToProgress($0.y) })
                .map({ RxBasicRefreshReactor.Action.pull(progress: $0) })
                .bind(to: reactor.action)
                .disposed(by: basicDisposeBag)
        }
    }
    
    /// 根据刷新状态重新设置顶部或底部刷新间距
    open func resetScrollViewContentInset(isRefreshing: Bool) {
    }
}
