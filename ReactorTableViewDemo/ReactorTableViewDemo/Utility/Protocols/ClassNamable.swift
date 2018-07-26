//
//  ClassNamable.swift
//  ReactorCollectionViewDemo
//
//  Created by luhe liu on 2018/6/21.
//  Copyright © 2018年 luhe liu. All rights reserved.
//

import UIKit

public protocol ClassNamable: class {
    static var className: String { get }
    var className: String { get }
}

public extension ClassNamable {
    public static var className: String {
        let nameSpaceClassName = String(describing: self)
        if let shortClassName = nameSpaceClassName.components(separatedBy: ".").last {
            return shortClassName
        }
        return nameSpaceClassName
    }
    
    public var className: String {
        let nameSpaceClassName = String(describing: type(of: self))
        if let shortClassName = nameSpaceClassName.components(separatedBy: ".").last {
            return shortClassName
        }
        return nameSpaceClassName
    }
}

extension NSObject: ClassNamable { }
