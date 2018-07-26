//
//  Mappable.swift
//  ifanr
//
//  Created by luhe liu on 2018/6/25.
//  Copyright © 2018年 com.ifanr. All rights reserved.
//

import UIKit

// MARK: - 字典处理
public protocol Mappable {
    init?(data: NSDictionary)
    static func basicMap(data: NSDictionary) -> Mappable?
}

public extension Mappable {
    
    public static func basicMap(data: NSDictionary) -> Mappable? {
        return Self(data: data)
    }
}

public extension NSDictionary {
    public func getModel<T: Mappable>(_ keys: String..., type: T.Type, isBasic: Bool = false) -> T? {
        for key in keys {
            if let dict = self[key] as? NSDictionary {
                if isBasic {
                    if let model = T.basicMap(data: dict) as? T {
                        return model
                    }
                } else {
                    if let model = T(data: dict) {
                        return model
                    }
                }
            }
        }
        return nil
    }
    
    public func getModelArray<T: Mappable>(_ keys: String..., type: T.Type, isBasic: Bool = false) -> [T] {
        for key in keys {
            var models: [T] = []
            if let dicts = self[key] as? [NSDictionary] {
                dicts.forEach({ (dict) in
                    if isBasic {
                        if let model = T.basicMap(data: dict) as? T {
                            models.append(model)
                        }
                    } else {
                        if let model = T(data: dict) {
                            models.append(model)
                        }
                    }
                })
                return models
            }
        }
        return []
    }
}
