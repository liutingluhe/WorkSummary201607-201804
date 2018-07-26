//
//  RxBasicCollectionViewReactor.swift
//  RxTodo
//
//  Created by luhe liu on 2018/5/16.
//  Copyright © 2018年 Suyeol Jeon. All rights reserved.
//

import UIKit
import RxSwift
import RxDataSources
import ReactorKit

/// 基础列表处理器
open class RxBasicCollectionViewReactor: Reactor, RxCellSizeLayoutable {
    
    /// 列表动作，加载/排序/选中/插入/删除/更新/替换
    public enum Action {
        case loadFirstPage
        case loadNextPage
        case sort
        case selectIndexes([IndexPath])
        case selectItems([RxBasicListItem])
        case insertItems([IndexPath: RxBasicListItem])
        case deleteIndexes([IndexPath])
        case deleteItems([RxBasicListItem])
        case updateSections([RxBasicListModel])
        case updateItems([RxBasicListItem])
        case replaceItems([IndexPath: RxBasicListItem])
        case replaceSections([RxBasicListModel])
    }
    /// 列表突变
    public enum Mutation {
        case willLoad(page: Int)
        case setLoadingState(Bool, page: Int)
        case setSections([RxBasicListModel], page: Int)
        case refreshSections([RxBasicListModel])
        case refreshIndexPaths([IndexPath])
        case loadFailure(page: Int, error: Error?)
        case didSelectedItem(RxBasicListItem)
    }
    /// 列表状态
    public struct State {
        var sections: [RxBasicListModel] = []
        var currentPage: Int = 0
        var isRefresh: Bool = false
        var isFetchData: Bool = false
        var isLoadFirstPageSuccess: Bool?
        var isLoadNextPageSuccess: Bool?
        var loadFailureError: Error?
        var isLoadingFirstPage: Bool = false
        var isLoadingNextPage: Bool = false
        var willLoadFirstPage: Bool = false
        var willLoadNextPage: Bool = false
        var canLoadMore: Bool = false
        var currentSelectedItem: RxBasicListItem?
        var refreshIndexPaths: [IndexPath] = []
    }
    
    /// 初始状态
    open var initialState: State = State()
    /// 列表服务
    open var service: RxBasicListService
    /// 是否自动排序
    open var isAutoSorted: Bool = true
    /// 列表数据源
    open var dataSource = RxCollectionViewSectionedAnimatedReloadDataSource<RxBasicListModel>()
    /// 顶部刷新处理器
    open var headerRefreshReactor: RxBasicRefreshReactor?
    /// 底部刷新处理器
    open var footerRefreshReactor: RxBasicRefreshReactor?
    /// 是否忽略第一次顶部刷新动作触发
    open var isFirstHeaderRefresh: Bool = true
    open var isFirstHeaderRefreshIgnore: Bool = false
    /// 是否自动触发顶部刷新事件
    open var isAutoSendHeaderRefreshAction: Bool = true
    /// 是否刷新元素有动画
    open var isRefreshItemsAnimated: Bool = true
    
    /// 初始化
    public init(service: RxBasicListService, isAnimated: Bool = false, defaultRefresh: Bool = true) {
        self.service = service
        dataSource.isAnimated = isAnimated
        dataSource.isAutoUpdate = service.isSelectedForReloadData && !service.isSelectedNext
        initialState.sections = handleSections(service.sections)
        initialState.isRefresh = true
        // 使用默认刷新
        if defaultRefresh {
            // 顶部下拉刷新
            let headerRefreshReactor = RxBasicRefreshReactor(isHiddenWhenInit: false)
            headerRefreshReactor.loadingReactor = RxBasicLoadingReactor()
            self.headerRefreshReactor = headerRefreshReactor
            // 底部加载更多
            let footerRefreshReactor = RxBasicRefreshReactor(isHiddenWhenStop: true, isHiddenWhenInit: true)
            footerRefreshReactor.loadingReactor = RxBasicLoadingReactor()
            self.footerRefreshReactor = footerRefreshReactor
        }
    }
    
    /// 动作 -> 突变
    open func mutate(action: Action) -> Observable<Mutation> {
        switch action {
            // 加载第一页数据
        case .loadFirstPage:
            return fetchData(page: 0)
            // 加载下一页数据
        case .loadNextPage:
            if currentState.canLoadMore {
                return fetchData(page: currentState.currentPage)
            }
            // 列表排序
        case .sort:
            guard !isAutoSorted else { return .empty() } // 当开启自动排序，则该事件不响应
            return service.sort().flatMap({ _ in Observable.empty() })
            // 选中索引
        case let .selectIndexes(indexes):
            return service.select(indexes: indexes).flatMap({ _ in Observable.empty() })
            // 选中元素
        case let .selectItems(items):
            return service.select(items: items).flatMap({ _ in Observable.empty() })
            // 插入元素
        case let .insertItems(items):
            return service.insert(items: items).flatMap({ _ in Observable.empty() })
            // 删除元素
        case let .deleteItems(items):
            return service.delete(items: items).flatMap({ _ in Observable.empty() })
            // 删除索引
        case let .deleteIndexes(indexes):
            return service.delete(indexes: indexes).flatMap({ _ in Observable.empty() })
            // 更新组
        case let .updateSections(sections):
            return service.update(sections: sections).flatMap({ _ in Observable.empty() })
            // 更新元素
        case let .updateItems(items):
            return service.update(items: items).flatMap({ _ in Observable.empty() })
            // 替换元素
        case let .replaceItems(items):
            return service.replace(items: items).flatMap({ _ in Observable.empty() })
            // 替换组
        case let .replaceSections(sections):
            return service.replace(sections: sections).flatMap({ _ in Observable.empty() })
        }
        return .empty()
    }
    
    /// 拼接当前事件和服务列表事件
    public func transform(mutation: Observable<Mutation>) -> Observable<Mutation> {
        
        let serviceEvent = service.event
            .flatMap { [weak self] (event) -> Observable<Mutation> in
                guard let strongSelf = self else { return .empty() }
                return strongSelf.transformEventToMutation(event: event)
            }
        
        return Observable.merge([mutation, serviceEvent])
            .do(onNext: { [weak self] (mutationValue) in
                // 触发顶部刷新控件和底部刷新控件的开始刷新和结束刷新事件
                guard let strongSelf = self else { return }
                if case let .setLoadingState(isLoading, page) = mutationValue {
                    let refreshNext: RxBasicRefreshReactor.Action = isLoading ? .startRefresh : .stopRefresh
                    if page <= 1 {
                        if strongSelf.isFirstHeaderRefreshIgnore && strongSelf.isFirstHeaderRefresh {
                            strongSelf.isFirstHeaderRefresh = false
                            return
                        }
                        if strongSelf.isAutoSendHeaderRefreshAction {
                            strongSelf.headerRefreshReactor?.action.onNext(refreshNext)
                        }
                        strongSelf.isFirstHeaderRefresh = false
                    } else {
                        strongSelf.footerRefreshReactor?.action.onNext(refreshNext)
                    }
                }
            })
    }
    
    /// 服务列表事件转成突变
    open func transformEventToMutation(event: RxBasicListService.Event) -> Observable<Mutation> {
        switch event {
        case let .request(page, result):
            guard let value = result.value else {
                return .just(.loadFailure(page: page, error: result.error))
            }
            return .just(.setSections(value, page: page))
            
        case let .sort(sections):
            return .just(.refreshSections(sections))
            
        case let .selectIndexes(indies, sections):
            if self.service.isSelectedForReloadData && self.service.isSelectedNext {
                return .just(.refreshIndexPaths(indies))
            }
            return .just(.refreshSections(sections))
            
        case let .selectItems(_, sections):
            return .just(.refreshSections(sections))
            
        case let .insertItems(_, sections):
            return .just(.refreshSections(sections))
            
        case let .deleteItems(_, sections):
            return .just(.refreshSections(sections))
            
        case let .deleteIndexes(_, sections):
            return .just(.refreshSections(sections))
            
        case let .updateItems(_, sections):
            return .just(.refreshSections(sections))
            
        case let .updateSections(_, sections):
            return .just(.refreshSections(sections))
            
        case let .replaceItems(_, sections):
            return .just(.refreshSections(sections))
            
        case let .replaceSections(_, sections):
            return .just(.refreshSections(sections))
            
        case let .didSelectedItem(item):
            return .just(.didSelectedItem(item))
        }
    }
    
    /// 旧状态 + 突变 -> 新状态
    open func reduce(state: State, mutation: Mutation) -> State {
        var newState = resetState(state)
        switch mutation {
        case let .willLoad(page):
            if page <= 1 {
                newState.willLoadFirstPage = true
            } else {
                newState.willLoadNextPage = true
            }
            
        case let .setLoadingState(isLoading, page):
            if page <= 1 {
                newState.isLoadingFirstPage = isLoading
            } else {
                newState.isLoadingNextPage = isLoading
            }
            
        case let .refreshSections(sections):
            newState.sections = handleSections(sections)
            newState.canLoadMore = checkListCanLoadMore(newState.sections)
            newState.isRefresh = true
            
        case let .refreshIndexPaths(indexPaths):
            newState.refreshIndexPaths = indexPaths
            
        case let .setSections(sections, page):
            newState.sections = handleSections(sections)
            newState.canLoadMore = checkListCanLoadMore(newState.sections)
            newState.isFetchData = true
            if page <= 1 {
                if newState.currentPage > 1 {
                    if !service.isCachePageData {
                        newState.currentPage = page
                    }
                } else {
                    newState.currentPage = page
                }
                newState.isLoadFirstPageSuccess = true
            } else {
                newState.isLoadNextPageSuccess = true
                newState.currentPage = page
            }
            
        case let .loadFailure(page, error):
            if page <= 1 {
                newState.isLoadFirstPageSuccess = false
            } else {
                newState.isLoadNextPageSuccess = false
            }
            newState.loadFailureError = error
            
        case let .didSelectedItem(item):
            newState.currentSelectedItem = item
            
        }
        return newState
    }
    
    /// 重置旧状态中非持久属性（非持久属性：下次状态突变时复原初始值的属性）
    open func resetState(_ state: State) -> State {
        var newState = state
        newState.isRefresh = false
        newState.isFetchData = false
        newState.isLoadFirstPageSuccess = nil
        newState.isLoadNextPageSuccess = nil
        newState.currentSelectedItem = nil
        newState.loadFailureError = nil
        newState.willLoadFirstPage = false
        newState.willLoadNextPage = false
        newState.refreshIndexPaths = []
        return newState
    }
    
    /// 处理数据
    open func handleSections(_ sections: [RxBasicListModel]) -> [RxBasicListModel] {
        var newSections = sections
        if isAutoSorted {
            newSections = service.sort(sections: newSections)
        }
        return newSections
    }
    
    /// 获取网络数据
    open func fetchData(page: Int) -> Observable<Mutation> {
        
        guard !self.currentState.isLoadingFirstPage else { return .empty() }
        let nextPage = page + 1
        if nextPage > 1 {
            guard !self.currentState.isLoadingNextPage else { return .empty() }
        }
        
        // 当加载第一页的时候，禁止加载更多
        let request = service.fetchData(page: nextPage)
            .takeUntil(self.isEndLoadNextPage(page: nextPage))
            .flatMap({ _ -> Observable<Mutation> in Observable.empty() })
        
        var mutations: [Observable<Mutation>] = []
        mutations.append(.just(.willLoad(page: nextPage)))
        mutations.append(.just(.setLoadingState(true, page: nextPage)))
        mutations.append(request)
        mutations.append(.just(.setLoadingState(false, page: nextPage)))
        return Observable<Mutation>.concat(mutations)
    }
    
    /// 当加载第一页的时候，禁止加载更多
    open func isEndLoadNextPage(page: Int) -> Observable<Action> {
        return self.action.filter({ action in
            guard page > 1 else { return false }
            if case .loadFirstPage = action {
                return true
            }
            return false
        })
    }
    
    open func checkListCanLoadMore(_ sections: [RxBasicListModel]) -> Bool {
        return sections.filter({ $0.model.canLoadMore }).count > 0
    }
}
