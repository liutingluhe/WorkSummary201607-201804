//
//  UserModel.swift
//  ArchiveWithMirror
//
//  Created by luhe liu on 2018/3/18.
//  Copyright © 2018年 luhe liu. All rights reserved.
//

import UIKit

/*
没用反射前需要的代码
class UserModel: NSObject, NSCoding {
    
    var name: String?
    var age: Int = 0
    var isWriter: Bool = false
    var createAt: Double = 0
   
    required init(coder aDecoder: NSCoder) {
        name = aDecoder.decodeObject(forKey: "user_name") as? String
        age = aDecoder.decodeInteger(forKey: "user_age")
        isWriter = aDecoder.decodeBool(forKey: "user_is_writer")
        createAt = aDecoder.decodeDouble(forKey: "user_created_at")
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(name, forKey: "user_name")
        aCoder.encode(age, forKey: "user_age")
        aCoder.encode(isWriter, forKey: "user_is_writer")
        aCoder.encode(isWriter, forKey: "user_created_at")
    }
}
 
 class WriterModel2: UserModel {
 
    enum WriterType: Int {
        case white
        case black
    }
 
    var type: WriterType = .white
    var writerName: String?
    var object: UserModel?
 
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        object = aDecoder.decodeObject(forKey: "object") as? UserModel
        writerName = aDecoder.decodeObject(forKey: "writerName") as? String
        if let type = WriterType(rawValue: aDecoder.decodeInteger(forKey: "type")) {
            self.type = type
        }
    }
 
    override func encode(with aCoder: NSCoder) {
        super.encode(with: aCoder)
        aCoder.encode(type.rawValue, forKey: "type")
        aCoder.encode(writerName, forKey: "writerName")
        aCoder.encode(object, forKey: "object")
    }
 }
 */

class UserModel: BasicCodingModel {
    
    var name: String?
    var age: Int = 0
    var isWriter: Bool = false
    var createAt: Double = 0
    
    override init() {
        super.init()
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}

class WriterModel: UserModel {
    
    enum WriterType: Int {
        case white
        case black
    }
    
    var type: WriterType {
        get {
            return WriterType(rawValue: typeRawValue) ?? .white
        }
        set {
            typeRawValue = newValue.rawValue
        }
    }
    var typeRawValue: Int = 0
    var writerName: String?
    var object: UserModel?
    
    override init() {
        super.init()
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}

@objcMembers class BasicCodingModel: NSObject, NSCoding {
    
    override init() {
        super.init()
    }
    
    required init(coder aDecoder: NSCoder) {
        // 这个要先调用 super.init ，因为 decodeMirror 里用到了 self，否则会报错
        super.init()
        decodeMirror(coder: aDecoder)
    }
    
    func encode(with aCoder: NSCoder) {
        encodeMirror(coder: aCoder)
    }
    
    // 重载该方法是为了防止使用 KVC 设置没有的属性时不至于直接崩溃
    override func setValue(_ value: Any?, forUndefinedKey key: String) {
    }
    
    // 用来确保获取和设置的 key 是一致的
    fileprivate func getCodingKey(_ label: String) -> String {
        // 这里直接用属性名当 key
        return label
    }
    
    // 解码的反射应用
    fileprivate func decodeMirror(coder aDecoder: NSCoder) {
        
        // 创建当前模型的反射
        var mirror: Mirror? = Mirror(reflecting: self)
        while mirror != nil {
            // mirror.children 表示该模型所有存储属性集合，它是一个元组（label = 属性名, value = 属性值）var mirror: Mirror? = Mirror(reflecting: model)
            mirror?.children.forEach { (label, value) in
                if let label = label {
                    let decodeKey = getCodingKey(label)
                    var decodeValue: Any?
                    if value is Bool {
                        decodeValue = aDecoder.decodeBool(forKey: decodeKey)
                    } else if value is Int {
                        decodeValue = aDecoder.decodeInteger(forKey: decodeKey)
                    } else if value is Double {
                        decodeValue = aDecoder.decodeDouble(forKey: decodeKey)
                    } else if value is String {
                        decodeValue = aDecoder.decodeObject(forKey: decodeKey)
                    } else if let displayStyle = Mirror(reflecting: value).displayStyle, displayStyle != .`enum` { // 过滤掉可选类型
                        decodeValue = aDecoder.decodeObject(forKey: decodeKey)
                    }
                    if let decodeValue = decodeValue, !(decodeValue is NSNull) {
                        // 通过使用 KVC 的方式对属性进行赋值
                        self.setValue(decodeValue, forKeyPath: label)
                    }
                }
            }
            // 判断有没有父类，直到顶层类
            mirror = mirror?.superclassMirror
        }
    }
    
    // 编码的反射应用
    fileprivate func encodeMirror(coder aCoder: NSCoder) {
        // 创建当前模型的反射
        var mirror: Mirror? = Mirror(reflecting: self)
        while mirror != nil {
            // mirror.children 表示该模型所有存储属性集合，它是一个元组（label = 属性名, value = 属性值）
            mirror?.children.forEach { (label, value) in
                if let label = label {
                    let decodeKey = getCodingKey(label)
                    if let valueBool = value as? Bool {
                        // 具体调用的是 encode(_ value: Bool, forKey key: String)
                        aCoder.encode(valueBool, forKey: decodeKey)
                    } else if let valueInt = value as? Int {
                        // 具体调用的是 encode(_ value: Int, forKey key: String)
                        aCoder.encode(valueInt, forKey: decodeKey)
                    } else if let valueDouble = value as? Double {
                        // 具体调用的是 encode(_ value: Double, forKey key: String)
                        aCoder.encode(valueDouble, forKey: decodeKey)
                    } else if let valueStr = value as? String {
                        // 具体调用的是 encode(_ value: Any?, forKey key: String)
                        aCoder.encode(valueStr, forKey: decodeKey)
                    } else if let displayStyle = Mirror(reflecting: value).displayStyle, displayStyle != .`enum` { // 过滤掉可选类型
                        // 具体调用的是 encode(_ value: Any?, forKey key: String)
                        aCoder.encode(value, forKey: decodeKey)
                    }
                }
            }
            // 判断有没有父类，直到顶层类
            mirror = mirror?.superclassMirror
        }
    }
}
