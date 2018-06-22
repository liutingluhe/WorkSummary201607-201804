//
//  Array+Convenient.swift
//  ReactorCollectionViewDemo
//
//  Created by luhe liu on 2018/6/21.
//  Copyright © 2018年 luhe liu. All rights reserved.
//

import UIKit

public extension Array {
    
    public func safeIndex(_ i: Int) -> Array.Iterator.Element? {
        guard !isEmpty && i >= 0 && i < count else { return nil }
        return self[i]
    }
}
