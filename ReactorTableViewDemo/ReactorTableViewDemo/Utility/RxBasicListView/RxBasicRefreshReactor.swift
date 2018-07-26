//
//  RxBasicRefreshReactor.swift
//  ReactorCollectionViewDemo
//
//  Created by luhe liu on 2018/5/24.
//  Copyright © 2018年 luhe liu. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import ReactorKit

/// 刷新控件处理器
open class RxBasicRefreshReactor: Reactor {
    /// 刷新动作
    public enum Action {
        case startRefresh
        case stopRefresh
        case pull(progress: CGFloat)
    }
    /// 刷新突变
    public enum Mutation {
        case setRefreshing(Bool)
        case setProgress(CGFloat)
    }
    /// 刷新状态
    public struct State {
        public var isRefreshing: Bool = false
        public var progress: CGFloat = 0
        public var isHidden: Bool = true
    }
    /// 初始状态
    open var initialState: State = State()
    /// 加载处理器
    open var loadingReactor: RxBasicLoadingReactor?
    open var isHiddenWhenStop: Bool = false
    
    /// 初始化
    public init(isHiddenWhenStop: Bool = false, isHiddenWhenInit: Bool = false) {
        self.isHiddenWhenStop = isHiddenWhenStop
        initialState.isHidden = isHiddenWhenInit
    }
    
    /// 动作 -> 突变
    open func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .startRefresh:
            guard !currentState.isRefreshing else { return .empty() }
            return .just(.setRefreshing(true))
            
        case .stopRefresh:
            guard currentState.isRefreshing else { return .empty() }
            return .just(.setRefreshing(false))
            
        case let .pull(progress):
            if let loadingReactor = loadingReactor, !loadingReactor.currentState.isLoading {
                loadingReactor.action.onNext(.progress(progress))
            }
            return .just(.setProgress(progress))
        }
    }
    
    /// 旧状态 + 突变 -> 新状态
    open func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        switch mutation {
        case let .setRefreshing(isRefreshing):
            newState.isRefreshing = isRefreshing
            if isHiddenWhenStop {
                newState.isHidden = !isRefreshing
            } else {
                newState.isHidden = false
            }
            
        case let .setProgress(value):
            newState.progress = value
        }
        return newState
    }
    
}
