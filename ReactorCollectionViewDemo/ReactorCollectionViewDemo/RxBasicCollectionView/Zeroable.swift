//
//  Zeroable.swift
//  ReactorCollectionViewDemo
//
//  Created by luhe liu on 2018/6/21.
//  Copyright © 2018年 luhe liu. All rights reserved.
//

import UIKit

/// 描述数据为空的协议，满足有个 zero 属性表示数据为空
public protocol Zeroable {
    static var zero: Self { get }
}

extension CGSize: Zeroable { }
extension CGRect: Zeroable { }
extension UIEdgeInsets: Zeroable { }

extension CGFloat: Zeroable {
    public static var zero: CGFloat {
        return 0.0
    }
}
