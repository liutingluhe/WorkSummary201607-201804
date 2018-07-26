//
//  Cancellable.swift
//  ifanr
//
//  Created by luhe liu on 17/8/4.
//  Copyright © 2017年 ifanr. All rights reserved.
//

public protocol Cancellable {
    func cancel()
}

open class CancellableWrapper: Cancellable {
    open var innerCancellable: Cancellable = SimpleCancellable()
    open var isCancel: Bool = false
    
    open func cancel() {
        isCancel = true
        innerCancellable.cancel()
    }
}

open class SimpleCancellable: Cancellable {

    open func cancel() {
    }
}
