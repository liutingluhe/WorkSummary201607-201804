//
//  GCDHelper.swift
//  ifanr
//
//  Created by Limon on 16/1/8.
//  Copyright © 2016年 ifanr. All rights reserved.
//
import UIKit

public protocol ExcutableQueue {
    var queue: DispatchQueue { get }
}

public extension ExcutableQueue {
    public func execute(_ closure: @escaping () -> Void) {
        queue.async(execute: closure)
    }
    
    public func delay(_ seconds: Double, delayedCode: @escaping () -> Void) {
        let targetTime = DispatchTime.now() + Double(Int64(Double(NSEC_PER_SEC) * seconds)) / Double(NSEC_PER_SEC)
        queue.asyncAfter(deadline: targetTime) {
            delayedCode()
        }
    }
}

public enum Queue: ExcutableQueue {
    case main
    case userInteractive
    case userInitiated
    case utility
    case background

    public var queue: DispatchQueue {
        switch self {
        case .main:
            return DispatchQueue.main
        case .userInteractive:
            return DispatchQueue.global(qos: DispatchQoS.QoSClass.userInteractive)
        case .userInitiated:
            return DispatchQueue.global(qos: DispatchQoS.QoSClass.userInitiated)
        case .utility:
            return DispatchQueue.global(qos: DispatchQoS.QoSClass.utility)
        case .background:
            return DispatchQueue.global(qos: DispatchQoS.QoSClass.background)
        }
    }
}
