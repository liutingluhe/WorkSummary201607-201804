//
//  RxBasicRefreshViewReactor.swift
//  ReactorCollectionViewDemo
//
//  Created by luhe liu on 2018/5/18.
//  Copyright © 2018年 luhe liu. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import ReactorKit

/// 基础加载处理器
open class RxBasicLoadingReactor: Reactor {
    /// 加载动作
    public enum Action {
        case startLoading
        case stopLoading
        case progress(CGFloat)
    }
    /// 加载突变
    public enum Mutation {
        case setLoadingState(Bool)
        case setProgress(CGFloat)
    }
    /// 加载状态
    public struct State {
        public var isLoading: Bool = false
        public var isProgress: Bool = false
        public var currentProgress: CGFloat = 0.0
    }
    /// 初始状态
    open var initialState: State = State()
    /// 定时器一个循环的总时间
    open var totalTime: TimeInterval = 1
    /// 一个循环时间分为多少个进度
    open var totalValue: Int = 100
    /// 是否开启定时器
    open var isOpenTimer: Bool = false
    
    /// 初始化，注意 totalValue 不能比 1 小，否则定时器工作不正常
    public init(totalTime: TimeInterval = 1, totalValue: Int = 100, isOpenTimer: Bool = false) {
        self.totalTime = totalTime
        self.totalValue = totalValue
        self.isOpenTimer = isOpenTimer
    }
    
    /// 动作 -> 突变
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
    
    /// 旧状态 + 突变 -> 新状态
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
    
    /// 开启定时器
    open func startTimer() -> Observable<Mutation> {
        let stepTime: TimeInterval = totalTime / Double(totalValue)
        return Observable<Int64>.interval(stepTime, scheduler: ConcurrentDispatchQueueScheduler(qos: .default))
            .takeUntil(isTimerStop())
            .flatMap { [weak self] _ -> Observable<Mutation> in
                guard let strongSelf = self else { return .empty() }
                let process = CGFloat(Int(strongSelf.currentState.currentProgress + 1) % max(2, strongSelf.totalValue))
                return .just(.setProgress(process))
            }
    }
    
    /// 判断是否停止定时器
    open func isTimerStop() -> Observable<Action> {
        return self.action.filter({ action in
            if case .stopLoading = action {
                return true
            }
            return false
        })
    }
}
