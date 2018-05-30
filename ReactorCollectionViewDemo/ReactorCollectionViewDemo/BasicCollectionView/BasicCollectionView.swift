//
//  BasicCollectionView.swift
//  RxTodo
//
//  Created by luhe liu on 2018/5/16.
//  Copyright © 2018年 Suyeol Jeon. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import RxDataSources
import ReactorKit

/// 基础列表
open class BasicCollectionView: UICollectionView, View, UICollectionViewDelegateFlowLayout {
    
    /// 列表滚动方向
    open fileprivate(set) var scrollDirection: UICollectionViewScrollDirection = .vertical
    /// 资源管理
    open var disposeBag = DisposeBag()
    /// 列表刷新间隔
    open var reloadDebounceTime: TimeInterval = 0.3
    /// 列表布局
    open var layoutSource = CollectionViewLayoutSource()
    
    // MARK: 顶部刷新控件：是否可以加载/预加载间距/刷新控件高度/刷新控件类/刷新控件
    open var canLoadFirst: Bool = true
    open var preloadFirstInset: CGFloat = 100
    open var headerRefreshHeight: CGFloat = 100
    open var headerRefreshClass: BasicHeaderRefreshView.Type = BasicHeaderRefreshView.self
    open fileprivate(set) var headerRefreshView: BasicHeaderRefreshView?
    
    // MARK: 底部刷新控件：是否可以加载/预加载间距/刷新控件高度/刷新控件类/刷新控件
    open var canLoadMore: Bool = true
    open var preloadNextInset: CGFloat = 200
    open var footerRefreshHeight: CGFloat = 100
    open var footerRefreshClass: BasicFooterRefreshView.Type = BasicFooterRefreshView.self
    open fileprivate(set) var footerRefreshView: BasicFooterRefreshView?
    
    // MARK: 刷新状态判断
    /// 是否可以加载下一页
    open var canPreLoadMore: Bool {
        guard canLoadMore else { return false }
        guard !isContentEmpty else { return false }
        switch scrollDirection {
        case .vertical:
            return contentOffset.y > contentSize.height - contentInset.top - frame.size.height - preloadNextInset
        case .horizontal:
            return contentOffset.x > contentSize.width - contentInset.left - frame.size.width - preloadNextInset
        }
    }
    
    /// 是否可以加载第一页
    open var canPreLoadFirst: Bool {
        guard canLoadFirst else { return false }
        switch self.scrollDirection {
        case .vertical:
            return contentOffset.y < -preloadFirstInset - contentInset.top
        case .horizontal:
            return contentOffset.x < -preloadFirstInset - contentInset.left
        }
    }
    
    /// 当前列表是否为空
    open var isContentEmpty: Bool {
        switch self.scrollDirection {
        case .vertical:
            return contentSize.height <= 0
        case .horizontal:
            return contentSize.width <= 0
        }
    }
    
    // MARK: 初始化
    public init(frame: CGRect, layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()) {
        self.scrollDirection = layout.scrollDirection
        super.init(frame: frame, collectionViewLayout: layout)
        configureCollectionView()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        configureCollectionView()
    }
    
    // MARK: 自定义方法
    /// 初始化列表控件配置
    open func configureCollectionView() {
        
        self.alwaysBounceVertical = self.scrollDirection == .vertical
        self.alwaysBounceHorizontal = self.scrollDirection == .horizontal
        self.showsVerticalScrollIndicator = false
        self.showsHorizontalScrollIndicator = false
        self.backgroundColor = UIColor.clear
        if #available(iOS 11.0, *) {
            self.contentInsetAdjustmentBehavior = .never
        }
    }

    /// 动作绑定
    open func bind(reactor: BasicCollectionViewReactor) {
        bindLayoutSource(reactor: reactor)
        bindHeaderRefresh(reactor: reactor)
        bindFooterRefresh(reactor: reactor)
        bindReloadData(reactor: reactor)
    }
    
    /// 绑定列表配置布局
    open func bindLayoutSource(reactor: BasicCollectionViewReactor) {
        self.rx.setDelegate(self).disposed(by: disposeBag)
        
        // Cell/Footer/Header 高度默认设置
        if self.layoutSource.configureSizeForCell == nil {
            self.layoutSource.configureSizeForCell = { reactor.getCellSize(indexPath: $0) }
        }
        if self.layoutSource.configureHeaderSize == nil {
            self.layoutSource.configureHeaderSize = { reactor.getHeaderSize(section: $0) }
        }
        if self.layoutSource.configureFooterSize == nil {
            self.layoutSource.configureFooterSize = { reactor.getFooterSize(section: $0) }
        }
    }
    
    /// 绑定顶部刷新控件动作
    open func bindHeaderRefresh(reactor: BasicCollectionViewReactor) {
        guard let headerRefreshReactor = reactor.headerRefreshReactor else { return }
        // 添加顶部控件
        addHeaderRefresh(reactor: headerRefreshReactor)
        // 加载第一页
        self.rx.didEndDragging
            .filter { [unowned self] _ in return self.canPreLoadFirst }
            .map { _ in Reactor.Action.loadFirstPage }
            .bind(to: reactor.action)
            .disposed(by: self.disposeBag)
    }
    
    /// 绑定底部刷新控件动作
    open func bindFooterRefresh(reactor: BasicCollectionViewReactor) {
        guard let footerRefreshReactor = reactor.footerRefreshReactor else { return }
        // 添加底部控件
        let footerRefreshView = addFooterRefresh(reactor: footerRefreshReactor)
        // 加载更多
        self.rx.didScroll
            .filter { [unowned self] _ in return self.canPreLoadMore }
            .map { _ in Reactor.Action.loadNextPage }
            .bind(to: reactor.action)
            .disposed(by: self.disposeBag)
        
        /// 底部控件跟随
        self.rx.contentSize
            .map({ $0.height })
            .distinctUntilChanged()
            .asDriver(onErrorJustReturn: 0)
            .drive(onNext: { [weak self] (contentHeight) in
                guard let strongSelf = self else { return }
                strongSelf.footerRefreshView?.frame.origin.y = contentHeight - strongSelf.contentInset.top
            }).disposed(by: disposeBag)
        
        /// 是否加载到了最后一页
        reactor.state.asObservable()
            .map({ $0.canLoadMore })
            .distinctUntilChanged()
            .debounce(reloadDebounceTime, scheduler: MainScheduler.instance)
            .bind(to: footerRefreshView.rx.canLoadMore)
            .disposed(by: disposeBag)
    }
    
    /// 绑定刷新列表动作
    open func bindReloadData(reactor: BasicCollectionViewReactor) {
        // 立即刷新数据，一般用于排序、插入、删除操作等
        let refresh = reactor.state.asObservable()
            .filter { $0.isRefresh }
            .map { $0.sections }
            .observeOn(MainScheduler.instance)
        
        // 延后刷新数据，一般用于网络获取数据等
        let fetchData = reactor.state.asObservable()
            .filter { $0.isFetchData }
            .map { $0.sections }
            .debounce(reloadDebounceTime, scheduler: MainScheduler.instance)
        
        // 刷新数据，设置数据源
        Observable.merge([refresh, fetchData])
            .asDriver(onErrorJustReturn: [])
            .drive(self.rx.items(dataSource: reactor.dataSource))
            .disposed(by: self.disposeBag)
        
        // RxCollectionViewSectionedAnimatedReloadDataSource 无法刷新旧元素，这里手动刷新旧元素
        if reactor.isAnimated {
            Observable.merge([refresh, fetchData])
                .map { _ in true }
                .delay(0.1, scheduler: MainScheduler.instance)
                .asDriver(onErrorJustReturn: false)
                .drive(self.rx.reload)
                .disposed(by: self.disposeBag)
        }
    }
    
    /// 添加顶部刷新控件
    @discardableResult
    open func addHeaderRefresh(reactor: BasicRefreshReactor) -> BasicHeaderRefreshView {
        if let headerRefreshView = self.headerRefreshView {
            headerRefreshView.reactor = reactor
            return headerRefreshView
        } else {
            let refreshFrame = CGRect(x: 0, y: self.contentInset.top - headerRefreshHeight, width: self.bounds.size.width, height: headerRefreshHeight)
            let refreshView = headerRefreshClass.init(frame: refreshFrame, refreshView: self)
            refreshView.reactor = reactor
            self.addSubview(refreshView)
            self.headerRefreshView = refreshView
            return refreshView
        }
    }
    
    /// 添加底部刷新控件
    @discardableResult
    open func addFooterRefresh(reactor: BasicRefreshReactor) -> BasicFooterRefreshView {
        if let footerRefreshView = self.footerRefreshView {
            footerRefreshView.reactor = reactor
            return footerRefreshView
        } else {
            let refreshFrame = CGRect(x: 0, y: self.contentSize.height - self.contentInset.top, width: self.bounds.size.width, height: footerRefreshHeight)
            let refreshView = footerRefreshClass.init(frame: refreshFrame, refreshView: self)
            refreshView.reactor = reactor
            self.addSubview(refreshView)
            self.footerRefreshView = refreshView
            return refreshView
        }
    }
    
    // MARK: Cell/Footer/Header 高度设置、间隙设置
    open func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return layoutSource.sizeForCell.at(indexPath)
    }
    
    open func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return layoutSource.insetForSection.at(section)
    }
    
    open func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return layoutSource.minLineSpacing.at(section)
    }
    
    open func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return layoutSource.minInteritemSpacing.at(section)
    }
    
    open func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return layoutSource.sizeForHeader.at(section)
    }
    
    open func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
        return layoutSource.sizeForFooter.at(section)
    }
}
