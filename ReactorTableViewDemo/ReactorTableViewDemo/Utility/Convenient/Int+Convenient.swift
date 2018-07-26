//
//  Int+Convenient.swift
//  ifanr
//
//  Created by luhe liu on 2018/6/26.
//  Copyright © 2018年 com.ifanr. All rights reserved.
//

import UIKit

public extension Int {
    
    public func separatedToString(_ separated: String = ",", step: Int = 1000) -> String {
        var number: Int = abs(self)
        var result: String = ""
        var separatedStr: String = ""
        while number > 0 {
            let thousandNumber: Int = number % step
            let formatStr = number / step > 0 ? "%03d" : "%d"
            let thousandStr: String = String(format: formatStr, thousandNumber)
            number /= step
            result = thousandStr + separatedStr + result
            separatedStr = separated
        }
        if result.isEmpty {
            return "\(number)"
        }
        if self < 0 {
            return "-" + result
        }
        return result
    }
    
}
