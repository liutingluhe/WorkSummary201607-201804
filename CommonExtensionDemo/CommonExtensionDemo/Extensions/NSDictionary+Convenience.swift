//
//  NSDictionary+Convenience.swift
//  CommonExtensionDemo
//
//  Created by catch on 18/3/25.
//  Copyright © 2018年 执着·执念. All rights reserved.
//

import Foundation

extension NSDictionary {
    
    // MARK: - 以下都是从字典里取值的快捷方法，支持多键查找和默认返回
    func bool(_ keys: String..., defaultValue: Bool = false) -> Bool {
        return valueForKeys(keys, type: Bool.self) ?? defaultValue
    }
    
    func double(_ keys: String..., defaultValue: Double = 0.0) -> Double {
        return valueForKeys(keys, type: Double.self) ?? defaultValue
    }
    
    func int(_ keys: String..., defaultValue: Int = 0) -> Int {
        return valueForKeys(keys, type: Int.self) ?? defaultValue
    }
    
    func string(_ keys: String..., defaultValue: String? = nil) -> String? {
        return valueForKeys(keys, type: String.self) ?? defaultValue
    }
    
    func dictionary(_ keys: String..., defaultValue: NSDictionary? = nil) -> NSDictionary? {
        return valueForKeys(keys, type: NSDictionary.self) ?? defaultValue
    }
    
    func array<T>(_ keys: String..., type: T.Type, defaultValue: [T] = []) -> [T] {
        return valueForKeys(keys, type: Array<T>.self) ?? defaultValue
    }
    
    // MARK: - 以下是从字典里取值的核心方法，支持多键查找
    fileprivate func valueForKeys<T>(_ keys: [String], type: T.Type) -> T? {
        for key in keys {
            if let result = self[key] as? T {
                return result
            }
        }
        return nil
    }
}
