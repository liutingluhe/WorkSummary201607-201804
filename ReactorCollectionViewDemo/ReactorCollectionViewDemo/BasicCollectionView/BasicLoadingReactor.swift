//
//  BasicRefreshViewReactor.swift
//  ReactorCollectionViewDemo
//
//  Created by luhe liu on 2018/5/18.
//  Copyright © 2018年 luhe liu. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import ReactorKit

open class BasicLoadingReactor: Reactor {
    
    public enum Action {
        case startLoading
        case stopLoading
        case progress(CGFloat)
    }
    
    public enum Mutation {
        case setLoadingState(Bool)
        case setProgress(CGFloat)
    }
    
    public struct State {
        public var isLoading: Bool = false
        public var isProgress: Bool = false
        public var currentProgress: CGFloat = 0.0
    }
    
    open var initialState: State = State()
    open var totalTime: TimeInterval = 1
    open var totalValue: Int = 100
    open var isOpenTimer: Bool = false
    
    public init(totalTime: TimeInterval = 1, totalValue: Int = 100, isOpenTimer: Bool = false) {
        self.totalTime = totalTime
        self.totalValue = totalValue
        self.isOpenTimer = isOpenTimer
    }
    
    open func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .startLoading:
            guard !currentState.isLoading else { return .empty() }
            if isOpenTimer {
                return .concat(.just(.setLoadingState(true)), startTimer())
            } else {
                return .just(.setLoadingState(true))
            }
            
        case .stopLoading:
            guard currentState.isLoading else { return .empty() }
            return .just(.setLoadingState(false))
            
        case let .progress(value):
            return .just(.setProgress(value))
        }
    }
    
    open func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        switch mutation {
        case let .setLoadingState(isLoading):
            newState.isLoading = isLoading
            
        case let .setProgress(value):
            newState.currentProgress = value
            newState.isProgress = true
        }
        return newState
    }
    
    open func startTimer() -> Observable<Mutation> {
        let stepTime: TimeInterval = totalTime / Double(totalValue)
        return Observable<Int64>.interval(stepTime, scheduler: ConcurrentDispatchQueueScheduler(qos: .default))
            .takeUntil(isTimerStop())
            .flatMap { [weak self] _ -> Observable<Mutation> in
                guard let strongSelf = self else { return .empty() }
                let process = CGFloat(Int(strongSelf.currentState.currentProgress + 1) % strongSelf.totalValue)
                return .just(.setProgress(process))
            }
    }
    
    open func isTimerStop() -> Observable<Action> {
        return self.action.filter({ action in
            if case .stopLoading = action {
                return true
            }
            return false
        })
    }
}
