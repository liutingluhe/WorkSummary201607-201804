//
//  RxBasicTableView.swift
//  ReactorTableViewDemo
//
//  Created by luhe liu on 2018/7/26.
//  Copyright © 2018年 luhe liu. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import RxDataSources
import ReactorKit

/// 基础列表
open class RxBasicTableView: UITableView, UITableViewDelegate {
    
    /// 列表刷新间隔
    open var reloadDebounceTime: TimeInterval = 0.3
    /// 列表布局
    open var layoutSource = RxTableViewLayoutSource()
    /// 资源管理
    open var basicDisposeBag = DisposeBag()
    /// 基础列表处理器
    open var basicReactor: RxBasicTableViewReactor? {
        didSet {
            basicDisposeBag = DisposeBag()
            if let basicReactor = basicReactor {
                self.basicBind(reactor: basicReactor)
            }
        }
    }
    // 是否可以滚动到顶部
    open var shouldScrollToTop: (() -> Bool)?
    
    // MARK: 顶部刷新控件
    /// 是否可以加载第一页
    open var canLoadFirst: Bool = true
    /// 顶部加载间距
    open var loadFirstInset: CGFloat = 60
    /// 顶部刷新控件默认高度
    open var defaultHeaderRefreshHeight: CGFloat = 60
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
    open var defaultFooterRefreshHeight: CGFloat = 60
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
        if let basicReactor = basicReactor, basicReactor.currentState.isLoadingNextPage {
            return false
        }
        return contentOffset.y > contentSize.height - contentInset.top - frame.size.height - preloadNextInset
    }
    
    /// 是否可以加载第一页
    open var canPreLoadFirst: Bool {
        guard canLoadFirst else { return false }
        if let basicReactor = basicReactor, basicReactor.currentState.isLoadingFirstPage {
            return false
        }
        return contentOffset.y < -loadFirstInset - contentInset.top
    }
    
    /// 当前列表是否为空
    open var isContentEmpty: Bool {
        return contentSize.height <= 0
    }
    
    /// 是否可以选中
    open var canSelectedIndex: (IndexPath) -> Bool {
        return { [weak self] indexPath in
            guard let strongBasicReactor = self?.basicReactor else { return false }
            guard let model = strongBasicReactor.dataSource.sectionModels.model(in: indexPath) else { return true }
            return model.canSelected
        }
    }
    
    // MARK: 初始化
    public override init(frame: CGRect, style: UITableViewStyle = .grouped) {
        super.init(frame: frame, style: style)
        configureTableView()
        setupSubviews()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        configureTableView()
        setupSubviews()
    }
    
    // MARK: 自定义方法
    /// 初始化列表控件配置
    open func configureTableView() {
        self.showsVerticalScrollIndicator = false
        self.showsHorizontalScrollIndicator = false
        self.backgroundColor = UIColor.clear
        self.removeAdjustmentBehavior()
    }
    
    open func setupSubviews() {
        
    }
    
    /// 动作绑定
    open func basicBind(reactor: RxBasicTableViewReactor) {
        bindLayoutSource(reactor: reactor)
        bindHeaderRefresh(reactor: reactor)
        bindFooterRefresh(reactor: reactor)
        bindReloadData(reactor: reactor)
        bindPlaceholderState(reactor: reactor)
    }
    
    /// 绑定刷新列表动作
    open func bindReloadData(reactor: RxBasicTableViewReactor) {
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
            .bind(to: self.rx.items(dataSource: reactor.dataSource))
            .disposed(by: basicDisposeBag)
        
        // 选中某个 Cell
        self.rx.itemSelected
            .filter({ [unowned self] in self.canSelectedIndex($0) })
            .map({ RxBasicTableViewReactor.Action.selectIndexes([$0]) })
            .bind(to: reactor.action)
            .disposed(by: basicDisposeBag)
        
        reactor.state.asObservable()
            .filter { $0.refreshIndexPaths.count > 0 }
            .map { $0.refreshIndexPaths }
            .debounce(reloadDebounceTime * 0.5, scheduler: MainScheduler.instance)
            .subscribe(onNext: { [weak self] (indies) in
                guard let strongSelf = self else { return }
                strongSelf.refreshIndexPaths(indies)
            }).disposed(by: basicDisposeBag)
    }
    
    open func refreshIndexPaths(_ indexPaths: [IndexPath]) {
        if self.basicReactor?.isRefreshItemsAnimated == true {
            self.reloadRows(at: indexPaths, with: .automatic)
        } else {
            UIView.performWithoutAnimation {
                self.reloadRows(at: indexPaths, with: .none)
            }
        }
    }
    
    // MARK: - 顶部刷新
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
    open func bindHeaderRefresh(reactor: RxBasicTableViewReactor) {
        guard let headerRefreshReactor = reactor.headerRefreshReactor else { return }
        // 添加顶部控件
        addHeaderRefresh(reactor: headerRefreshReactor)
        // 加载第一页
        self.rx.didEndDragging
            .filter { [unowned self] _ in return self.canPreLoadFirst }
            .map { _ in RxBasicTableViewReactor.Action.loadFirstPage }
            .bind(to: reactor.action)
            .disposed(by: basicDisposeBag)
    }
    
    // MARK: - 底部刷新
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
    open func bindFooterRefresh(reactor: RxBasicTableViewReactor) {
        guard let footerRefreshReactor = reactor.footerRefreshReactor else { return }
        // 添加底部控件
        let footerRefreshView = addFooterRefresh(reactor: footerRefreshReactor)
        footerRefreshView.isHidden = true
        // 加载更多
        self.rx.didScroll
            .throttle(reloadDebounceTime * 2, scheduler: MainScheduler.instance)
            .filter { [unowned self] _ in return self.canPreLoadMore }
            .map { _ in RxBasicTableViewReactor.Action.loadNextPage }
            .bind(to: reactor.action)
            .disposed(by: basicDisposeBag)
        
        /// 底部控件跟随
        self.rx.contentSize
            .map({ $0.height })
            .distinctUntilChanged()
            .observeOn(MainScheduler.instance)
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
    
    // MARK: - 占位显示
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
    open func bindPlaceholderState(reactor: RxBasicTableViewReactor) {
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
            .debounce(reloadDebounceTime, scheduler: MainScheduler.instance)
            .bind(to: placeholderView.rx.isNetworkError)
            .disposed(by: basicDisposeBag)
        
    }
    
    // MARK: - Cell/Footer/Header 高度设置、间隙设置
    /// 绑定列表配置布局
    open func bindLayoutSource(reactor: RxBasicTableViewReactor) {
        
        self.rx.setDelegate(self).disposed(by: basicDisposeBag)
        
        // Cell/Footer/Header 高度默认设置
        if self.layoutSource.configureHeightForRow == nil {
            self.layoutSource.configureHeightForRow = { reactor.getRowHeight(indexPath: $0) }
        }
        if self.layoutSource.configureHeaderHeight == nil {
            self.layoutSource.configureHeaderHeight = { reactor.getHeaderHeight(section: $0) }
        }
        if self.layoutSource.configureFooterHeight == nil {
            self.layoutSource.configureFooterHeight = { reactor.getFooterHeight(section: $0) }
        }
        if self.layoutSource.configureEstimatedHeightForRow == nil {
            self.layoutSource.configureEstimatedHeightForRow = { reactor.getRowHeight(indexPath: $0) }
        }
        if self.layoutSource.configureHeaderEstimatedHeight == nil {
            self.layoutSource.configureHeaderEstimatedHeight = { reactor.getHeaderHeight(section: $0) }
        }
        if self.layoutSource.configureFooterEstimatedHeight == nil {
            self.layoutSource.configureFooterEstimatedHeight = { reactor.getFooterHeight(section: $0) }
        }
        
        reactor.dataSource.titleForHeaderInSection = { _, _ in
            return " "
        }
        
        reactor.dataSource.titleForFooterInSection = { _, _ in
            return " "
        }
    }
    
    open func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return layoutSource.heightForRow.at(indexPath)
    }
    
    open func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        let height = layoutSource.heightForHeader.at(section)
        return height == 0 ? 0.01 : height
    }
    
    open func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        let height = layoutSource.heightForFooter.at(section)
        return height == 0 ? 0.01 : height
    }
    
    open func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return layoutSource.estimatedHeightForRow.at(indexPath)
    }
    
    open func tableView(_ tableView: UITableView, estimatedHeightForHeaderInSection section: Int) -> CGFloat {
        let height = layoutSource.estimatedHeightForHeader.at(section)
        return height == 0 ? 0.01 : height
    }
    
    open func tableView(_ tableView: UITableView, estimatedHeightForFooterInSection section: Int) -> CGFloat {
        let height = layoutSource.estimatedHeightForFooter.at(section)
        return height == 0 ? 0.01 : height
    }
    
    // MARK: - 滑动事件
    open func scrollViewShouldScrollToTop(_ scrollView: UIScrollView) -> Bool {
        return shouldScrollToTop?() ?? scrollsToTop
    }
    
    // MARK: - 解决刷新前后 ContentOffset 突变问题
    open func setContentHeaderInset(header: CGFloat) {
        var newInset = header
        if let headerRefreshView = headerRefreshView, headerRefreshView.isRefreshing {
            newInset += headerRefreshView.refreshHeight
        }
        self.contentInset.top = newInset
    }
    
    open func setContentFooterInset(footer: CGFloat) {
        var newInset = footer
        if let footerRefreshView = footerRefreshView, footerRefreshView.isRefreshing {
            newInset += footerRefreshView.refreshHeight
        }
        self.contentInset.bottom = newInset
    }
}

/// 基础列表控件 Rx 扩展
public extension Reactive where Base: RxBasicTableView {
    public var footerFollow: UIBindingObserver<Base, CGFloat> {
        return UIBindingObserver(UIElement: self.base) { view, contentHeight in
            view.updateFooterRefeshViewState(with: contentHeight)
        }
    }
    
}
