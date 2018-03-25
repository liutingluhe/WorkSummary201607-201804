//
//  String+Substr.swift
//  CommonExtensionDemo
//
//  Created by catch on 18/3/25.
//  Copyright © 2018年 执着·执念. All rights reserved.
//

import Foundation

extension String {
    
    ///  寻找在 startString 和 endString 之间的字符串
    func substring(between startString: String, and endString: String?, options: String.CompareOptions = .caseInsensitive) -> String? {
        let range = self.range(of: startString, options: options)
        if let startIndex = range?.upperBound {
            let string = self.substring(from: startIndex)
            if let endString = endString {
                let range = string.range(of: endString, options: options)
                if let startIndex = range?.lowerBound {
                    return string.substring(to: startIndex)
                }
            }
            return string
        }
        return nil
    }
    
    ///  寻找 prefix 字符串，并返回从 prefix 到尾部的字符串
    func substring(prefix: String, options: String.CompareOptions = .caseInsensitive, isContain: Bool = true) -> String? {
        let range = self.range(of: prefix, options: options)
        if let startIndex = range?.upperBound {
            var resultString = self.substring(from: startIndex)
            if isContain {
                resultString = "\(prefix)\(resultString)"
            }
            return resultString
        }
        return nil
    }
    
    ///  寻找 suffix 字符串，并返回从头部到 suffix 位置的字符串
    func substring(suffix: String, options: String.CompareOptions = .caseInsensitive, isContain: Bool = false) -> String? {
        let range = self.range(of: suffix, options: options)
        if let startIndex = range?.lowerBound {
            var resultString = self.substring(to: startIndex)
            if isContain {
                resultString = "\(resultString)\(suffix)"
            }
            return resultString
        }
        return nil
    }
    
    ///  从 N 位置到尾位置的字符串
    func substring(from: IndexDistance) -> String? {
        let index = self.index(self.startIndex, offsetBy: from)
        return self.substring(from: index)
    }
    
    ///  从头位置到 N 位置的字符串
    func substring(to: IndexDistance) -> String? {
        let index = self.index(self.startIndex, offsetBy: to)
        return self.substring(to: index)
    }
    
    /// 以 lower 为起点，偏移 range 得到的字符串
    func substring(_ lower: IndexDistance, _ range: IndexDistance) -> String? {
        let lowerIndex = self.index(self.startIndex, offsetBy: lower)
        let upperIndex = self.index(lowerIndex, offsetBy: range)
        let range = Range(uncheckedBounds: (lowerIndex, upperIndex))
        return self.substring(with: range)
    }
}
