//
//  String+MD5.swift
//  ifanr
//
//  Created by luhe liu on 17/9/4.
//  Copyright © 2017年 ifanr. All rights reserved.
//

import Foundation

extension String {
    
    /// 字符串 MD5 加密
    var encodeMD5: String? {
        guard let str = cString(using: String.Encoding.utf8) else { return nil }
        let strLen = CC_LONG(lengthOfBytes(using: String.Encoding.utf8))
        let digestLen = Int(CC_MD5_DIGEST_LENGTH)
        let result = UnsafeMutablePointer<CUnsignedChar>.allocate(capacity: digestLen)
        // MD5 加密
        CC_MD5(str, strLen, result)
        // 把结果打印输出成 16 进制字符串
        let hash = NSMutableString()
        for i in 0..<digestLen {
            hash.appendFormat("%02x", result[i])
        }
        result.deallocate(capacity: digestLen)
        return String(format: hash as String)
    }
}
