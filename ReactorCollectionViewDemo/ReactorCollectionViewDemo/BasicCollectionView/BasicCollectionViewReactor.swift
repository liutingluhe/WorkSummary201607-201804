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

open class BasicCollectionViewReactor: Reactor, CellSizeLayoutable {

    public enum Action {
        // 加载
        case loadFirstPage
        case loadNextPage
        // 选中
        case selectIndexs([IndexPath])
        // 插入
        case insertItems([IndexPath: BasicListItemModel])
        // 删除
        case deleteItems([BasicListItemModel])
        case deleteIndexs([IndexPath])
        // 更新
        case updateSections([BasicListModel])
        case updateItems([BasicListItemModel])
        // 替换
        case replaceItems([IndexPath: BasicListItemModel])
    }
    
    public enum Mutation {
        case setLoadingState(Bool, page: Int)
        case setSections([BasicListModel], page: Int)
        case refreshSections([BasicListModel])
        case loadFailure(page: Int)
    }
    
    public struct State {
        var sections: [BasicListModel] = []
        var currentPage: Int = 0
        var isRefresh: Bool = false
        var isFetchData: Bool = false
        var isLoadFirstPageSuccess: Bool?
        var isLoadNextPageSuccess: Bool?
        var isLoadingFirstPage: Bool = false
        var isLoadingNextPage: Bool = false
    }
    
    open var isCachePageData: Bool = false
    open var initialState: State = State()
    open var service: BasicCollectionService
    open let isAnimated: Bool
    open var dataSource: RxCollectionViewSectionedReloadDataSource<BasicListModel>
    var headerRefreshReactor: BasicRefreshReactor?
    var footerRefreshReactor: BasicRefreshReactor?
    
    public init(service: BasicCollectionService, isAnimated: Bool = false, useDefaultRefresh: Bool = true) {
        self.service = service
        self.isAnimated = isAnimated
        if isAnimated {
            dataSource = RxCollectionViewSectionedAnimatedReloadDataSource<BasicListModel>()
        } else {
            dataSource = RxCollectionViewSectionedReloadDataSource<BasicListModel>()
        }
        initialState.sections = handleSections(service.localSections)
        initialState.isRefresh = true
        // 使用默认刷新
        if useDefaultRefresh {
            // 顶部下拉刷新
            let headerRefreshReactor = BasicRefreshReactor()
            headerRefreshReactor.loadingReactor = BasicLoadingReactor()
            self.headerRefreshReactor = headerRefreshReactor
            // 底部加载更多
            let footerRefreshReactor = BasicRefreshReactor()
            footerRefreshReactor.loadingReactor = BasicLoadingReactor()
            self.footerRefreshReactor = footerRefreshReactor
        }
    }
    
    open func mutate(action: Action) -> Observable<Mutation> {
        switch action {
            // 加载
        case .loadFirstPage:
            return fetchData(page: 0)
        case .loadNextPage:
            if currentState.sections.filter({ $0.model.canLoadMore }).count > 0 {
                return fetchData(page: currentState.currentPage)
            }
            // 选中
        case let .selectIndexs(indexs):
            return .just(.refreshSections(service.select(indexs: indexs, sections: currentState.sections)))
            // 插入
        case let .insertItems(items):
            return .just(.refreshSections(service.insert(items: items, sections: currentState.sections)))
            // 删除
        case let .deleteItems(items):
            return .just(.refreshSections(service.delete(items: items, sections: currentState.sections)))
        case let .deleteIndexs(indexs):
            return .just(.refreshSections(service.delete(indexs: indexs, sections: currentState.sections)))
            // 更新
        case let .updateSections(sections):
            return .just(.refreshSections(sections))
        case let .updateItems(items):
            return .just(.refreshSections(service.update(items: items, sections: currentState.sections)))
            // 替换
        case let .replaceItems(items):
            return .just(.refreshSections(service.replace(items: items, sections: currentState.sections)))
        }
        return .empty()
    }
    
    public func transform(mutation: Observable<Mutation>) -> Observable<Mutation> {
        return mutation.do(onNext: { [weak self] (mutationValue) in
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
            newState.isRefresh = true
            
        case let .setSections(sections, page):
            newState.sections = handleSections(sections)
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
    
    open func resetState(_ state: State) -> State {
        var newState = state
        newState.isRefresh = false
        newState.isFetchData = false
        newState.isLoadFirstPageSuccess = nil
        newState.isLoadNextPageSuccess = nil
        return newState
    }
    
    // 处理数据
    open func handleSections(_ sections: [BasicListModel]) -> [BasicListModel] {
        var newSections = sections
        newSections = service.group(sections: newSections)
        newSections = service.sort(sections: newSections)
        return newSections
    }
    
    // 获取网络数据
    open func fetchData(page: Int) -> Observable<Mutation> {
        
        guard !self.currentState.isLoadingFirstPage else { return .empty() }
        let nextPage = page + 1
        if nextPage > 1 {
            guard !self.currentState.isLoadingNextPage else { return .empty() }
        }
        
        // 当加载第一页的时候，禁止加载更多
        let request = service.request(page: nextPage)
            .observeOn(ConcurrentDispatchQueueScheduler(qos: .background))
            .takeUntil(self.isEndLoadNextPage(page: nextPage))
            .flatMap { [weak self] (result) -> Observable<Mutation> in
                guard let strongSelf = self else { return .empty() }
                guard let value = result.value else { return .just(.loadFailure(page: nextPage)) }
                var newSections = strongSelf.currentState.sections
                if nextPage > 1 || strongSelf.isCachePageData {
                    newSections = strongSelf.service.mergeSections(newSections, with: value, page: nextPage)
                } else {
                    newSections = value
                }
                return .just(.setSections(newSections, page: nextPage))
            }
            .observeOn(MainScheduler.instance)
        
        var mutations: [Observable<Mutation>] = []
        mutations.append(.just(.setLoadingState(true, page: nextPage)))
        mutations.append(request)
        mutations.append(.just(.setLoadingState(false, page: nextPage)))
        return Observable<Mutation>.concat(mutations)
    }
    
    // 当加载第一页的时候，禁止加载更多
    open func isEndLoadNextPage(page: Int) -> Observable<Action> {
        return self.action.filter({ action in
            guard page > 1 else { return false }
            if case .loadFirstPage = action {
                return true
            }
            return false
        })
    }
}
