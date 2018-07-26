//
//  NSDictionary+Convenient.swift
//  ifanr
//
//  Created by catch on 15/11/28.
//  Copyright © 2015年 ifanr. All rights reserved.
//

import Foundation

// MARK: - 字典取值
public extension NSDictionary {
    public func getBool(_ keys: String..., defaultValue: Bool = false) -> Bool {
        for key in keys {
            if let result = self[key] as? Bool {
                return result
            }
        }
        return defaultValue
    }
    
    public func getDouble(_ keys: String..., defaultValue: Double = 0.0, minValue: Double? = nil, maxValue: Double? = nil) -> Double {
        for key in keys {
            if var result = self[key] as? Double {
                if let minValue = minValue {
                    result = Swift.max(minValue, result)
                }
                if let maxValue = maxValue {
                    result = Swift.min(maxValue, result)
                }
                return result
            }
        }
        return defaultValue
    }
    
    public func getInt(_ keys: String..., defaultValue: Int = 0, minValue: Int? = nil, maxValue: Int? = nil) -> Int {
        for key in keys {
            if var result = self[key] as? Int {
                if let minValue = minValue {
                    result = Swift.max(minValue, result)
                }
                if let maxValue = maxValue {
                    result = Swift.min(maxValue, result)
                }
                return result
            }
        }
        return defaultValue
    }
    
    public func getString(_ keys: String..., defaultValue: String? = nil) -> String? {
        for key in keys {
            if let result = self[key] as? String {
                return result
            }
        }
        return defaultValue
    }
    
    public func getDict(_ keys: String..., defaultValue: NSDictionary? = nil) -> NSDictionary? {
        for key in keys {
            if let result = self[key] as? NSDictionary {
                return result
            }
        }
        return defaultValue
    }
    
    public func getArray<T>(_ keys: String..., type: T.Type) -> [T] {
        for key in keys {
            if let result = self[key] as? [T] {
                return result
            }
        }
        return []
    }
}

// MARK: - 字典合并
public extension Dictionary {
    
    /// Merges the dictionary with dictionaries passed. The latter dictionaries will override
    /// values of the keys that are already set
    ///
    /// :param dictionaries A comma seperated list of dictionaries
    public mutating func merge<K, V>(_ dictionaries: Dictionary<K, V>...) {
        for dict in dictionaries {
            for (key, value) in dict {
                if let v = value as? Value, let k = key as? Key {
                    self.updateValue(v, forKey: k)
                }
            }
        }
    }
}
