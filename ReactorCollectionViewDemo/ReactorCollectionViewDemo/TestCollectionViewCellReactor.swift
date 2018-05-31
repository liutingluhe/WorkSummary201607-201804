//
//  TestCollectionViewCellReactor.swift
//  ReactorCollectionViewDemo
//
//  Created by luhe liu on 2018/5/18.
//  Copyright © 2018年 luhe liu. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import ReactorKit

class TestCollectionViewCellReactor: BasicListItemModel, Reactor {
    
    enum Action {
        case push
    }
    
    enum Mutation {
        case setPushState(Bool)
    }
    
    struct State {
        var model: Model
        var isPush: Bool = false
    }
    
    var initialState: State
    unowned var service: BasicCollectionService
    
    init(service: BasicCollectionService, model: Model) {
        self.service = service
        self.initialState = State(model: model, isPush: false)
        super.init()
        identity = model.title
        cellSize = TestCollectionViewCell.Constraint.cellSize
    }
    
    deinit {
        print("TestCollectionViewCellReactor dealloc")
    }
    
    /// 拼接当前事件和服务列表事件
    public func transform(mutation: Observable<Mutation>) -> Observable<Mutation> {
        let serviceEvent = service.event
            .flatMap { [weak self] (event) -> Observable<Mutation> in
                guard let strongSelf = self else { return .empty() }
                return strongSelf.transformEventToMutation(event: event)
        }
        
        return Observable.merge([mutation, serviceEvent])
    }
    
    /// 服务列表事件转成突变
    func transformEventToMutation(event: BasicCollectionService.Event) -> Observable<Mutation> {
        switch event {
        case let .didSelectedItem(item):
            if item.identity == self.identity {
                return Observable.concat(
                    .just(.setPushState(true)),
                    .just(.setPushState(false))
                )
            }
        default:
            break
        }
        return .empty()
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        switch mutation {
        case let .setPushState(isPush):
            newState.isPush = isPush
        }
        return newState
    }
}
