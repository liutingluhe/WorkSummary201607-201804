//
//  BasicCollectionRefreshView.swift
//  ReactorCollectionViewDemo
//
//  Created by luhe liu on 2018/5/18.
//  Copyright © 2018年 luhe liu. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import ReactorKit

/// 基础加载控件
open class BasicLoadingView: UIView, View {
    /// 资源管理
    open var disposeBag = DisposeBag()
    /// 系统加载控件
    open lazy var indicatorView: UIActivityIndicatorView = {
        let indicatorView = UIActivityIndicatorView(activityIndicatorStyle: .gray)
        indicatorView.center = CGPoint(x: self.frame.size.width * 0.5, y: self.frame.size.height * 0.5)
        self.addSubview(indicatorView)
        return indicatorView
    }()
    
    /// 是否正在加载
    open var isAnimated: Bool {
        return self.reactor?.currentState.isLoading ?? false
    }
    
    /// 初始化
    public required override init(frame: CGRect) {
        super.init(frame: frame)
        setupSubviews()
    }
    /// 初始化
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupSubviews()
    }
    
    /// 初始化子控件
    open func setupSubviews() {
    }

    /// 绑定事件
    open func bind(reactor: BasicLoadingReactor) {
        
        reactor.state.asObservable()
            .map({ $0.isLoading })
            .distinctUntilChanged()
            .observeOn(MainScheduler.instance)
            .bind(to: self.rx.isAnimating)
            .disposed(by: disposeBag)
        
        reactor.state.asObservable()
            .filter({ $0.isProgress })
            .map({ $0.currentProgress })
            .distinctUntilChanged()
            .observeOn(MainScheduler.instance)
            .bind(to: self.rx.progress)
            .disposed(by: disposeBag)
    }
    
    /// 开始加载动画
    open func startAnimating() {
        self.indicatorView.startAnimating()
    }
    
    /// 结束加载动画
    open func stopAnimating() {
        self.indicatorView.stopAnimating()
    }
    
    /// 加载进度变化
    open func updateProgress(_ progress: CGFloat) {
    }

}
