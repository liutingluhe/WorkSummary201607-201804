//
//  NSObject+ClassName.swift
//  CommonExtensionDemo
//
//  Created by catch on 18/3/25.
//  Copyright © 2018年 执着·执念. All rights reserved.
//

import Foundation

extension NSObject {
    
    /// 返回类名字符串
    static var className: String {
        return String(describing: self)
    }
    
    /// 返回类名字符串
    var className: String {
        return String(describing: type(of: self))
    }
}
