//
//  RxBasicCollectionView.swift
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
open class RxBasicCollectionView: UICollectionView {
    
    /// 列表滚动方向
    open fileprivate(set) var scrollDirection: UICollectionViewScrollDirection = .vertical
    /// 列表刷新间隔
    open var reloadDebounceTime: TimeInterval = 0.3
    /// 列表布局
    open var layoutSource = RxCollectionViewLayoutSource()
    /// 资源管理
    open var basicDisposeBag = DisposeBag()
    /// 基础列表处理器
    open var basicReactor: RxBasicCollectionViewReactor? {
        didSet {
            basicDisposeBag = DisposeBag()
            if let basicReactor = basicReactor {
                self.basicBind(reactor: basicReactor)
            }
        }
    }
    
    // MARK: 顶部刷新控件
    /// 是否可以加载第一页
    open var canLoadFirst: Bool = true
    /// 顶部加载间距
    open var loadFirstInset: CGFloat = 100
    /// 顶部刷新控件默认高度
    open var defaultHeaderRefreshHeight: CGFloat = 100
    /// 顶部刷新控件位置默认偏移
    open var defaultHeaderRefreshOffsetY: CGFloat = 0
    /// 顶部刷新控件类，用于创建顶部刷新控件
    open var headerRefreshClass: RxBasicHeaderRefreshView.Type = RxBasicHeaderRefreshView.self
    /// 顶部刷新控件，用于创建顶部刷新控件
    open var headerRefreshView: RxBasicHeaderRefreshView?
    
    // MARK: 底部刷新控件
    /// 是否可以加载更多
    open var canLoadMore: Bool = true
    /// 预加载间距
    open var preloadNextInset: CGFloat = 200
    /// 底部刷新控件默认高度
    open var defaultFooterRefreshHeight: CGFloat = 100
    /// 底部刷新控件类，用于创建底部刷新控件
    open var footerRefreshClass: RxBasicFooterRefreshView.Type = RxBasicFooterRefreshView.self
    /// 底部刷新控件，用于创建底部刷新控件
    open var footerRefreshView: RxBasicFooterRefreshView?
    
    // MARK: 列表占位控件
    open var placeholderView: RxBasicPlaceholderView?
    
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
            return contentOffset.y < -loadFirstInset - contentInset.top
        case .horizontal:
            return contentOffset.x < -loadFirstInset - contentInset.left
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
        setupSubviews()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        configureCollectionView()
        setupSubviews()
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
    
    open func setupSubviews() {
        
    }

    /// 动作绑定
    open func basicBind(reactor: RxBasicCollectionViewReactor) {
        bindLayoutSource(reactor: reactor)
        bindHeaderRefresh(reactor: reactor)
        bindFooterRefresh(reactor: reactor)
        bindReloadData(reactor: reactor)
        bindPlaceholderState(reactor: reactor)
    }
    
    /// 绑定刷新列表动作
    open func bindReloadData(reactor: RxBasicCollectionViewReactor) {
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
            .disposed(by: basicDisposeBag)
        
        // 选中某个 Cell
        self.rx.itemSelected
            .map({ RxBasicCollectionViewReactor.Action.selectIndexes([$0]) })
            .bind(to: reactor.action)
            .disposed(by: basicDisposeBag)
    }
}

// MARK: - 顶部刷新
extension RxBasicCollectionView {
    /// 添加顶部刷新控件
    @discardableResult
    open func addHeaderRefresh(reactor: RxBasicRefreshReactor) -> RxBasicHeaderRefreshView {
        
        if let headerRefreshView = self.headerRefreshView {
            headerRefreshView.basicReactor = reactor
            self.addSubview(headerRefreshView)
            return headerRefreshView
        } else {
            let refreshFrame = CGRect(
                x: 0,
                y: defaultHeaderRefreshOffsetY - defaultHeaderRefreshHeight,
                width: self.bounds.size.width,
                height: defaultHeaderRefreshHeight
            )
            let refreshView = headerRefreshClass.init(frame: refreshFrame, scrollView: self)
            refreshView.basicReactor = reactor
            self.addSubview(refreshView)
            self.headerRefreshView = refreshView
            return refreshView
        }
    }
    
    /// 绑定顶部刷新控件动作
    open func bindHeaderRefresh(reactor: RxBasicCollectionViewReactor) {
        guard let headerRefreshReactor = reactor.headerRefreshReactor else { return }
        // 添加顶部控件
        addHeaderRefresh(reactor: headerRefreshReactor)
        // 加载第一页
        self.rx.didEndDragging
            .filter { [unowned self] _ in return self.canPreLoadFirst }
            .map { _ in RxBasicCollectionViewReactor.Action.loadFirstPage }
            .bind(to: reactor.action)
            .disposed(by: basicDisposeBag)
    }
}

// MARK: - 底部刷新
extension RxBasicCollectionView {
    
    /// 添加底部刷新控件
    @discardableResult
    open func addFooterRefresh(reactor: RxBasicRefreshReactor) -> RxBasicFooterRefreshView {
        if let footerRefreshView = self.footerRefreshView {
            footerRefreshView.basicReactor = reactor
            self.addSubview(footerRefreshView)
            return footerRefreshView
        } else {
            let refreshFrame = CGRect(
                x: 0,
                y: self.contentSize.height,
                width: self.bounds.size.width,
                height: defaultFooterRefreshHeight
            )
            let refreshView = footerRefreshClass.init(frame: refreshFrame, scrollView: self)
            refreshView.basicReactor = reactor
            self.addSubview(refreshView)
            self.footerRefreshView = refreshView
            return refreshView
        }
    }
    
    /// 绑定底部刷新控件动作
    open func bindFooterRefresh(reactor: RxBasicCollectionViewReactor) {
        guard let footerRefreshReactor = reactor.footerRefreshReactor else { return }
        // 添加底部控件
        let footerRefreshView = addFooterRefresh(reactor: footerRefreshReactor)
        footerRefreshView.needDelayResetBottomInset = !reactor.isAnimated
        // 加载更多
        self.rx.didScroll
            .filter { [unowned self] _ in return self.canPreLoadMore }
            .map { _ in RxBasicCollectionViewReactor.Action.loadNextPage }
            .bind(to: reactor.action)
            .disposed(by: basicDisposeBag)
        
        /// 底部控件跟随
        self.rx.contentSize
            .map({ $0.height })
            .distinctUntilChanged()
            .bind(to: self.rx.footerFollow)
            .disposed(by: basicDisposeBag)
        
        /// 是否加载到了最后一页
        reactor.state.asObservable()
            .map({ $0.canLoadMore })
            .distinctUntilChanged()
            .debounce(reloadDebounceTime, scheduler: MainScheduler.instance)
            .bind(to: footerRefreshView.rx.canLoadMore)
            .disposed(by: basicDisposeBag)
    }
    
    /// 更新尾部控件状态
    open func updateFooterRefeshViewState(with contentHeight: CGFloat) {
        guard let refreshView = self.footerRefreshView else { return }
        var isFooterHidden: Bool = false
        refreshView.frame.origin.y = contentHeight
        if !refreshView.canLoadMore {
            if refreshView.frame.origin.y < self.frame.size.height {
                isFooterHidden = true
            } else {
                refreshView.frame.origin.y = max(refreshView.frame.origin.y, self.frame.size.height)
            }
        }
        refreshView.isHidden = isFooterHidden
    }
}

// MARK: - 占位显示
extension RxBasicCollectionView {
    /// 添加底部刷新控件
    @discardableResult
    open func addPlaceholderView(classType: RxBasicPlaceholderView.Type) -> RxBasicPlaceholderView {
        if let placeholderView = self.placeholderView {
            self.insertSubview(placeholderView, at: 0)
            return placeholderView
        } else {
            let placeholderView = classType.init(frame: self.bounds)
            self.insertSubview(placeholderView, at: 0)
            self.placeholderView = placeholderView
            return placeholderView
        }
    }
    /// 绑定底部刷新控件动作
    open func bindPlaceholderState(reactor: RxBasicCollectionViewReactor) {
        guard let placeholderView = self.placeholderView else { return }
        self.insertSubview(placeholderView, at: 0)
        placeholderView.isHidden = placeholderView.isFirstRefreshHidden
        
        // 起始加载是否显示占位
        reactor.state.asObservable()
            .map({ $0.sections.filter({ $0.items.count > 0 }).count > 0 })
            .skip(placeholderView.isFirstRefreshHidden ? 2 : 0)
            .distinctUntilChanged()
            .debounce(reloadDebounceTime, scheduler: MainScheduler.instance)
            .bind(to: placeholderView.rx.isHidden)
            .disposed(by: basicDisposeBag)
        
        // 是否网络错误，更新占位视图
        reactor.state.asObservable()
            .filter({ $0.isLoadFirstPageSuccess != nil })
            .map({ $0.isLoadFirstPageSuccess == false })
            .distinctUntilChanged()
            .debounce(reloadDebounceTime, scheduler: MainScheduler.instance)
            .bind(to: placeholderView.rx.isNetworkError)
            .disposed(by: basicDisposeBag)
        
    }
}

// MARK: - Cell/Footer/Header 高度设置、间隙设置
extension RxBasicCollectionView: UICollectionViewDelegateFlowLayout {
    
    /// 绑定列表配置布局
    open func bindLayoutSource(reactor: RxBasicCollectionViewReactor) {
        
        self.rx.setDelegate(self).disposed(by: basicDisposeBag)
        
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


// MARK: - 解决刷新前后 ContentOffset 突变问题
extension RxBasicCollectionView {
    
}
