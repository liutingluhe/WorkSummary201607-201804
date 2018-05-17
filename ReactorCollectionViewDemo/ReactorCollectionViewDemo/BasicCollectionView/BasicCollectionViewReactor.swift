//
//  BasicCollectionViewReactor.swift
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

class BasicCollectionViewReactor: Reactor, CellSizeLayoutable {

    enum Action {
        case loadFirstPage
        case loadNextPage
        case selectIndexs([IndexPath])
        case insertItems([IndexPath: BasicListItemModel])
        case deleteItems([BasicListItemModel])
        case deleteIndexs([IndexPath])
        case updateSections([BasicListModel])
    }
    
    enum Mutation {
        case setLoadingState(Bool)
        case setSections([BasicListModel], page: Int)
        case refreshSections([BasicListModel])
        case loadFailure(page: Int)
        case beginLoadFirstPage
    }
    
    struct State {
        var sections: [BasicListModel] = []
        var currentPage: Int = 0
        var isRefresh: Bool = false
        var isFetchData: Bool = false
        var isLoading: Bool = false
        var isLoadFirstPageSuccess: Bool?
        var isLoadNextPageSuccess: Bool?
        var isBeginLoadFirstPage: Bool = false
    }
    
    var initialState: State = State()
    var dataSource: RxCollectionViewSectionedReloadDataSource<BasicListModel>
    var service: BasicCollectionService
    var isCachePageData: Bool = false
    var isAnimated: Bool = false
    
    init(service: BasicCollectionService, isAnimated: Bool = false) {
        self.service = service
        self.isAnimated = isAnimated
        if isAnimated {
            dataSource = RxCollectionViewSectionedAnimatedReloadDataSource<BasicListModel>()
        } else {
            dataSource = RxCollectionViewSectionedReloadDataSource<BasicListModel>()
        }
        var localSections = service.localSections
        localSections = service.group(sections: localSections)
        localSections = service.sort(sections: localSections)
        initialState.sections = localSections
        initialState.isRefresh = true
    }
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .loadFirstPage:
            return fetchData(page: 0)
        case .loadNextPage:
            if currentState.sections.filter({ $0.model.canLoadMore }).count > 0 {
                return fetchData(page: currentState.currentPage)
            }
        case let .selectIndexs(indexPaths):
            return .just(.refreshSections(service.select(indexs: indexPaths, sections: currentState.sections)))
        case let .insertItems(insertData):
            return .just(.refreshSections(service.insert(items: insertData, sections: currentState.sections)))
        case let .deleteItems(items):
            return .just(.refreshSections(service.delete(items: items, sections: currentState.sections)))
        case let .deleteIndexs(indexs):
            return .just(.refreshSections(service.delete(indexs: indexs, sections: currentState.sections)))
        case let .updateSections(sections):
            return .just(.refreshSections(sections))
        }
        return .empty()
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        var newState = resetState(state)
        switch mutation {
        case let .setLoadingState(isLoading):
            newState.isLoading = isLoading
            
        case .beginLoadFirstPage:
            newState.isBeginLoadFirstPage = true
            
        case let .refreshSections(sections):
            var newSections = sections
            newSections = service.group(sections: newSections)
            newSections = service.sort(sections: newSections)
            newState.sections = newSections
            newState.isRefresh = true
            
        case let .setSections(sections, page):
            var newSections = sections
            newSections = service.group(sections: newSections)
            newSections = service.sort(sections: newSections)
            newState.sections = newSections
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
    
    func resetState(_ state: State) -> State {
        var newState = state
        newState.isRefresh = false
        newState.isFetchData = false
        newState.isBeginLoadFirstPage = false
        newState.isLoadFirstPageSuccess = nil
        newState.isLoadNextPageSuccess = nil
        return newState
    }
    
    // 获取网络数据
    fileprivate func fetchData(page: Int) -> Observable<Mutation> {
        
        guard !self.currentState.isLoading else { return .empty() }
        
        let nextPage = page + 1
        let request = service.request(page: nextPage)
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
        
        var allObservable: [Observable<Mutation>]  = []
        allObservable.append(.just(.setLoadingState(true)))
        if page < 1 {
            allObservable.append(.just(.beginLoadFirstPage))
        }
        allObservable.append(request)
        allObservable.append(.just(.setLoadingState(false)))
        return Observable<Mutation>.concat(allObservable)
    }
}
