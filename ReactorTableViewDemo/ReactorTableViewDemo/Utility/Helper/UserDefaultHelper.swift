//
//  UserDefaultHelper.swift
//  ifanr
//
//  Created by luhe liu on 2018/7/13.
//  Copyright © 2018年 com.ifanr. All rights reserved.
//

import UIKit
import SwiftyUserDefaults

open class DictionaryKeys {
    public init() {}
}

open class DictionaryKey<ValueType>: DictionaryKeys {
    
    open let type: ValueType.Type
    open let valueKey: String
    open let dictionaryKey: String?
    
    public init(_ key: String, dictionaryKey: String? = nil) {
        self.type = ValueType.self
        self.valueKey = key
        self.dictionaryKey = dictionaryKey
    }
}

extension UserDefaults {
    
    public func value<T>(key: String, type: T.Type) -> Any? {
        
        if type == Double.self {
            return self[DefaultsKey<Double>(key)]
        } else if type == Int.self {
            return self[DefaultsKey<Int>(key)]
        } else if type == Bool.self {
            return self[DefaultsKey<Bool>(key)]
        } else if type == Double?.self {
            return self[DefaultsKey<Double?>(key)]
        } else if type == Int?.self {
            return self[DefaultsKey<Int?>(key)]
        } else if type == Bool?.self {
            return self[DefaultsKey<Bool?>(key)]
        } else if type == URL.self {
            return self.url(forKey: key)
        } else {
            return self.object(forKey: key)
        }
    }
}

open class UserDefaultHelper {
    
    open var currentVersion: String?
    
    public init() {
        currentVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String
    }
    
    /// UserDefault 缓存，先从缓存中取值，缓存不存在再去 UserDefaults 取
    open var cacheUserDefault: [String: Any] = [:]
    
    /// 获取 UserDefault 缓存的 cacheKey，UserDefault 缓存是一级字典结构，cacheKey 通过 {userDefaults}_{dictionaryKey}_{valueKey} 拼接而成
    open func getCacheKey<T>(with key: DictionaryKey<T>, userDefaults: UserDefaults = .standard) -> String {
        var cacheKey = "\(userDefaults)"
        
        if let dictionaryKey = key.dictionaryKey {
            cacheKey += "_\(dictionaryKey)_\(key.valueKey)"
        } else {
            cacheKey += "_\(key.valueKey)"
        }
        return cacheKey
    }
    
    /// 全局设置 UserDefault 值方法
    open func setValue<T>(_ value: Any?, forKey key: DictionaryKey<T>, to userDefaults: UserDefaults = .standard) {
        
        let cacheKey = getCacheKey(with: key, userDefaults: userDefaults)
        cacheUserDefault[cacheKey] = value
        let valueKey = key.valueKey
        if let dictionaryKey = key.dictionaryKey {
            if var userInfo = userDefaults[dictionaryKey].dictionary {
                userInfo[valueKey] = value
                userDefaults[dictionaryKey] = userInfo
            } else if let value = value {
                userDefaults[dictionaryKey] = [valueKey: value]
            }
        } else {
            userDefaults[valueKey] = value
        }
        userDefaults.synchronize()
    }
    
    /// 全局获取 UserDefault 值方法
    open func getValue<T>(for key: DictionaryKey<T>, from userDefaults: UserDefaults = .standard) -> Any? {
        
        let cacheKey = getCacheKey(with: key, userDefaults: userDefaults)
        if let cacheValue = cacheUserDefault[cacheKey] {
            return cacheValue
        } else {
            var value: Any? = nil
            let valueKey = key.valueKey
            if let dictionaryKey = key.dictionaryKey {
                let dict = userDefaults[dictionaryKey].dictionary
                value = dict?[valueKey]
            } else {
                value = userDefaults.value(key: valueKey, type: key.type)
            }
            if let value = value {
                cacheUserDefault[cacheKey] = value
                return value
            }
            return nil
        }
    }
    
    /// 给 UserDefault 设置字典结构数据
    open func setDictionary(_ dict: [String: Any]?, dictionaryKey: String, to userDefaults: UserDefaults = .standard) {
        if let dict = dict {
            dict.forEach { (key, value) in
                let key = DictionaryKey<[String: Any]>(key, dictionaryKey: dictionaryKey)
                let cacheKey = getCacheKey(with: key, userDefaults: userDefaults)
                cacheUserDefault[cacheKey] = value
            }
        } else { // 设置为 nil，需要清理缓存
            let key = DictionaryKey<[String: Any]>(dictionaryKey)
            let cacheKey = getCacheKey(with: key, userDefaults: userDefaults)
            let cleanKeys = cacheUserDefault.keys.filter({ return $0.hasPrefix(cacheKey) }).map({ return $0 })
            cleanKeys.forEach({ (cleanKey) in
                cacheUserDefault[cleanKey] = nil
            })
        }
        userDefaults[dictionaryKey] = dict
        userDefaults.synchronize()
    }
    
    open func getDictionary(dictionaryKey: String, to userDefaults: UserDefaults = .standard) -> [String: Any]? {
        var dict: [String: Any]? = userDefaults[dictionaryKey].dictionary
        if dict == nil {
            let key = DictionaryKey<[String: Any]>(dictionaryKey)
            let cacheKey = getCacheKey(with: key, userDefaults: userDefaults)
            cacheUserDefault.forEach { (dictKey, value) in
                if dictKey.hasPrefix(cacheKey) {
                    if dict == nil {
                        dict = [String: Any]()
                    }
                    let valueKey = dictKey.substring(from: cacheKey.endIndex)
                    dict?[valueKey] = value
                }
            }
        }
        return dict
    }
}
