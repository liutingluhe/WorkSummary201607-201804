//
//  BasicRefreshReactor.swift
//  ReactorCollectionViewDemo
//
//  Created by luhe liu on 2018/5/24.
//  Copyright © 2018年 luhe liu. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import ReactorKit

open class BasicRefreshReactor: Reactor {
    public enum Action {
        case startRefresh
        case stopRefresh
        case pull(progress: CGFloat)
        case refresh(enable: Bool)
    }
    
    public enum Mutation {
        case setRefreshing(Bool)
        case setProgress(CGFloat)
        case setRefreshEnable(Bool)
    }
    
    public struct State {
        public var isRefreshing: Bool = false
        public var progress: CGFloat = 0
        public var isEnable: Bool = true
    }
    
    open var initialState: State = State()
    open var loadingReactor: BasicLoadingReactor?
    
    public init() {
    }
    
    open func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .startRefresh:
            guard !currentState.isRefreshing else { return .empty() }
            return .just(.setRefreshing(true))
            
        case .stopRefresh:
            guard currentState.isRefreshing else { return .empty() }
            return .just(.setRefreshing(false))
            
        case let .pull(progress):
            return .just(.setProgress(progress))
            
        case let .refresh(enable):
            return .just(.setRefreshEnable(enable))
        }
    }
    
    open func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        switch mutation {
        case let .setRefreshing(isRefreshing):
            newState.isRefreshing = isRefreshing
            
        case let .setProgress(value):
            newState.progress = value
            
        case let .setRefreshEnable(enable):
            newState.isEnable = enable
        }
        return newState
    }
    
}
