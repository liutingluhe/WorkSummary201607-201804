//
//  BasicCollectionViewReactor.swift
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
open class BasicCollectionViewReactor: Reactor, CellSizeLayoutable {
    /// 列表动作，加载/排序/选中/插入/删除/更新/替换
    public enum Action {
        case loadFirstPage
        case loadNextPage
        case sort
        case selectIndexes([IndexPath])
        case insertItems([IndexPath: BasicListItemModel])
        case deleteItems([BasicListItemModel])
        case deleteIndexes([IndexPath])
        case updateSections([BasicListModel])
        case updateItems([BasicListItemModel])
        case replaceItems([IndexPath: BasicListItemModel])
    }
    /// 列表突变
    public enum Mutation {
        case setLoadingState(Bool, page: Int)
        case setSections([BasicListModel], page: Int)
        case refreshSections([BasicListModel])
        case loadFailure(page: Int)
    }
    /// 列表状态
    public struct State {
        var sections: [BasicListModel] = []
        var currentPage: Int = 0
        var isRefresh: Bool = false
        var isFetchData: Bool = false
        var isLoadFirstPageSuccess: Bool?
        var isLoadNextPageSuccess: Bool?
        var isLoadingFirstPage: Bool = false
        var isLoadingNextPage: Bool = false
        var canLoadMore: Bool = false
    }
    
    /// 初始状态
    open var initialState: State = State()
    /// 列表服务
    open var service: BasicCollectionService
    /// 是否需要列表动画
    open let isAnimated: Bool
    /// 是否自动排序
    open var isAutoSorted: Bool = true
    /// 列表数据源
    open var dataSource: RxCollectionViewSectionedReloadDataSource<BasicListModel>
    /// 顶部刷新处理器
    open var headerRefreshReactor: BasicRefreshReactor?
    /// 底部刷新处理器
    open var footerRefreshReactor: BasicRefreshReactor?
    
    /// 初始化
    public init(service: BasicCollectionService, isAnimated: Bool = false, useDefaultRefresh: Bool = true) {
        self.service = service
        self.isAnimated = isAnimated
        if isAnimated {
            dataSource = RxCollectionViewSectionedAnimatedReloadDataSource<BasicListModel>()
        } else {
            dataSource = RxCollectionViewSectionedReloadDataSource<BasicListModel>()
        }
        initialState.sections = handleSections(service.sections)
        initialState.isRefresh = true
        // 使用默认刷新
        if useDefaultRefresh {
            // 顶部下拉刷新
            let headerRefreshReactor = BasicRefreshReactor(isHiddenWhenInit: false)
            headerRefreshReactor.loadingReactor = BasicLoadingReactor()
            self.headerRefreshReactor = headerRefreshReactor
            // 底部加载更多
            let footerRefreshReactor = BasicRefreshReactor(isHiddenWhenInit: true)
            footerRefreshReactor.loadingReactor = BasicLoadingReactor()
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
        case let .selectIndexes(indexs):
            return service.select(indexs: indexs).flatMap({ _ in Observable.empty() })
            // 插入元素
        case let .insertItems(items):
            return service.insert(items: items).flatMap({ _ in Observable.empty() })
            // 删除元素
        case let .deleteItems(items):
            return service.delete(items: items).flatMap({ _ in Observable.empty() })
            // 删除索引
        case let .deleteIndexes(indexs):
            return service.delete(indexs: indexs).flatMap({ _ in Observable.empty() })
            // 更新组
        case let .updateSections(sections):
            return service.update(sections: sections).flatMap({ _ in Observable.empty() })
            // 更新元素
        case let .updateItems(items):
            return service.update(items: items).flatMap({ _ in Observable.empty() })
            // 替换元素
        case let .replaceItems(items):
            return service.replace(items: items).flatMap({ _ in Observable.empty() })
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
                    let refreshNext: BasicRefreshReactor.Action = isLoading ? .startRefresh : .stopRefresh
                    if page <= 1 {
                        strongSelf.headerRefreshReactor?.action.onNext(refreshNext)
                    } else {
                        strongSelf.footerRefreshReactor?.action.onNext(refreshNext)
                    }
                }
            })
    }
    
    /// 服务列表事件转成突变
    func transformEventToMutation(event: BasicCollectionService.Event) -> Observable<Mutation> {
        switch event {
        case let .request(page, result):
            guard let value = result.value else {
                return .just(.loadFailure(page: page))
            }
            return .just(.setSections(value, page: page))
        case let .sort(sections):
            return .just(.refreshSections(sections))
        case let .selectIndexes(_, sections):
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
        }
    }
    
    /// 旧状态 + 突变 -> 新状态
    open func reduce(state: State, mutation: Mutation) -> State {
        var newState = resetState(state)
        switch mutation {
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
            
        case let .setSections(sections, page):
            newState.sections = handleSections(sections)
            newState.canLoadMore = checkListCanLoadMore(newState.sections)
            newState.currentPage = page
            newState.isFetchData = true
            if page <= 1 {
                newState.isLoadFirstPageSuccess = true
            } else {
                newState.isLoadNextPageSuccess = true
            }
            
        case let .loadFailure(page):
            if page <= 1 {
                newState.isLoadFirstPageSuccess = false
            } else {
                newState.isLoadNextPageSuccess = false
            }
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
        return newState
    }
    
    /// 处理数据
    open func handleSections(_ sections: [BasicListModel]) -> [BasicListModel] {
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
            .observeOn(ConcurrentDispatchQueueScheduler(qos: .background))
            .takeUntil(self.isEndLoadNextPage(page: nextPage))
            .flatMap({ _ -> Observable<Mutation> in Observable.empty() })
        
        var mutations: [Observable<Mutation>] = []
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
    
    open func checkListCanLoadMore(_ sections: [BasicListModel]) -> Bool {
        return sections.filter({ $0.model.canLoadMore }).count > 0
    }
}
