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

open class BasicCollectionView: UICollectionView, View, UICollectionViewDelegateFlowLayout {
    
    open var scrollDirection: UICollectionViewScrollDirection = .vertical
    open var disposeBag = DisposeBag()
    open var reloadDebounceTime: TimeInterval = 0.3
    open var preloadNextInset: CGFloat = 200
    open var preloadFirstInset: CGFloat = 100
    open var headerRefreshHeight: CGFloat = 100
    open var footerRefreshHeight: CGFloat = 100
    open var layoutSource = CollectionViewLayoutSource()
    open var headerRefreshView: BasicRefreshView?
    open var footerRefreshView: BasicRefreshView?
    open var canLoadFirst: Bool = true
    open var canLoadMore: Bool = true
    open var hadMoreData: Bool = false
    
    open var canPreLoadMore: Bool {
        guard canLoadMore else { return false }
        guard !isContentEmpty && hadMoreData else { return false }
        switch scrollDirection {
        case .vertical:
            return contentOffset.y > contentSize.height - contentInset.top - frame.size.height - preloadNextInset
        case .horizontal:
            return contentOffset.x > contentSize.width - contentInset.left - frame.size.width - preloadNextInset
        }
    }
    
    open var canPreLoadFirst: Bool {
        guard canLoadFirst else { return false }
        switch self.scrollDirection {
        case .vertical:
            return contentOffset.y < -preloadFirstInset - contentInset.top
        case .horizontal:
            return contentOffset.x < -preloadFirstInset - contentInset.left
        }
    }
    
    open var isContentEmpty: Bool {
        switch self.scrollDirection {
        case .vertical:
            return contentSize.height <= 0
        case .horizontal:
            return contentSize.width <= 0
        }
    }
    
    public init(frame: CGRect, layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()) {
        self.scrollDirection = layout.scrollDirection
        super.init(frame: frame, collectionViewLayout: layout)
        configureCollectionView()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        configureCollectionView()
    }
    
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

    // CollectionView 动作绑定
    open func bind(reactor: BasicCollectionViewReactor) {
        
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
        
        if let footerRefreshReactor = reactor.footerRefreshReactor {
            addFooterRefresh(reactor: footerRefreshReactor)
            // 加载更多
            self.rx.didScroll
                .filter { [unowned self] _ in return self.canPreLoadMore }
                .map { _ in Reactor.Action.loadNextPage }
                .bind(to: reactor.action)
                .disposed(by: self.disposeBag)
        }
        
        if let headerRefreshReactor = reactor.headerRefreshReactor {
            addHeaderRefresh(reactor: headerRefreshReactor)
            // 加载第一页
            self.rx.didEndDragging
                .filter { [unowned self] _ in return self.canPreLoadFirst }
                .map { _ in Reactor.Action.loadFirstPage }
                .bind(to: reactor.action)
                .disposed(by: self.disposeBag)
        }

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
            .filter({ [weak self] sections -> Bool in
                guard let strongSelf = self else { return false }
                strongSelf.hadMoreData = sections.last?.model.canLoadMore ?? false
                return true
            })
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
    
    open func addHeaderRefresh(reactor: BasicRefreshReactor) {
        if let headerRefreshView = self.headerRefreshView {
            headerRefreshView.reactor = reactor
        } else {
            let refreshFrame = CGRect(x: 0, y: self.contentInset.top - headerRefreshHeight, width: self.bounds.size.width, height: headerRefreshHeight)
            let refreshView = BasicRefreshView(frame: refreshFrame, refreshView: self, position: .header)
            refreshView.reactor = reactor
            self.addSubview(refreshView)
            self.headerRefreshView = refreshView
        }
    }
    
    open func addFooterRefresh(reactor: BasicRefreshReactor) {
        if let footerRefreshView = self.footerRefreshView {
            footerRefreshView.reactor = reactor
        } else {
            let refreshFrame = CGRect(x: 0, y: self.contentSize.height - self.contentInset.top, width: self.bounds.size.width, height: footerRefreshHeight)
            let refreshView = BasicRefreshView(frame: refreshFrame, refreshView: self, position: .footer)
            refreshView.reactor = reactor
            self.addSubview(refreshView)
            self.footerRefreshView = refreshView
            
            self.rx.contentSize
                .map({ $0.height })
                .distinctUntilChanged()
                .asDriver(onErrorJustReturn: 0)
                .drive(onNext: { [weak self] (contentHeight) in
                    guard let strongSelf = self else { return }
                    strongSelf.footerRefreshView?.frame.origin.y = contentHeight - strongSelf.contentInset.top
                }).disposed(by: disposeBag)
        }
    }
    
    // MARK: - Cell/Footer/Header 高度设置、间隙设置
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
