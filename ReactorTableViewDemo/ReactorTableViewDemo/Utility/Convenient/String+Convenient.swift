//
//  String+Convenient.swift
//  ifanr
//
//  Created by luhe liu on 2018/6/25.
//  Copyright © 2018年 com.ifanr. All rights reserved.
//

import UIKit

// MARK: - 编码
extension String {
    var encodeMD5: String? {
        
        guard let str = cString(using: String.Encoding.utf8) else {
            return nil
        }
        
        let strLen = CC_LONG(lengthOfBytes(using: String.Encoding.utf8))
        let digestLen = Int(CC_MD5_DIGEST_LENGTH)
        let result = UnsafeMutablePointer<CUnsignedChar>.allocate(capacity: digestLen)
        
        CC_MD5(str, strLen, result)
        
        let hash = NSMutableString()
        
        for i in 0..<digestLen {
            hash.appendFormat("%02x", result[i])
        }
        
        result.deallocate(capacity: digestLen)
        
        return String(format: hash as String)
    }
    
}

// MARK: - 字符串转颜色值
extension String {
    
    // #EC6800 -> (236, 104, 0)
    func parseToRGB() -> UIColor {
        var str: String = self.lowercased()
        var values: [Int] = [0, 0, 0]
        str = str.substring(prefix: "#", containPrefix: false) ?? str
        var radixStr: String = ""
        for (index, char) in str.enumerated() {
            let valueIndex: Int = index / 2
            if valueIndex < values.count {
                radixStr += "\(char)"
                if index % 2 == 1, let radixInt = Int(radixStr, radix: 16) {
                    values[valueIndex] = radixInt
                    radixStr = ""
                }
            }
        }
        return UIColor(r: values[0], g: values[1], b: values[2])
    }
    
}

// MARK: - 截取子串
public extension String {
    
    public func substring(between startString: String, and endString: String?, options: String.CompareOptions = .caseInsensitive) -> String? {
        let range = self.range(of: startString, options: options)
        if let startIndex = range?.upperBound {
            let string = self.substring(from: startIndex)
            if let endString = endString {
                let range = string.range(of: endString, options: .caseInsensitive)
                if let startIndex = range?.lowerBound {
                    return string.substring(to: startIndex)
                }
            }
            return string
        }
        return nil
    }
    
    public func substring(prefix: String, options: String.CompareOptions = .caseInsensitive, containPrefix: Bool = true) -> String? {
        let range = self.range(of: prefix, options: options)
        if let startIndex = range?.upperBound {
            var resultString = self.substring(from: startIndex)
            if containPrefix {
                resultString = "\(prefix)\(resultString)"
            }
            return resultString
        }
        return nil
    }
    
    public func substring(suffix: String, options: String.CompareOptions = .caseInsensitive, containSuffix: Bool = false) -> String? {
        let range = self.range(of: suffix, options: options)
        if let startIndex = range?.lowerBound {
            var resultString = self.substring(to: startIndex)
            if containSuffix {
                resultString = "\(resultString)\(suffix)"
            }
            return resultString
        }
        return nil
    }
    
    public func splitFirst(_ split: String, options: String.CompareOptions = .caseInsensitive) -> [String] {
        let range = self.range(of: split, options: options)
        if let splitIndex = range?.lowerBound {
            let right = self.substring(from: splitIndex)
            let left = self.substring(to: splitIndex)
            return [left, right]
        }
        return []
    }
    
    public func substring(from: Int) -> String? {
        guard count > from && from >= 0 else { return nil }
        let index = self.index(self.startIndex, offsetBy: from)
        return self.substring(from: index)
    }
    
    public func substring(to: Int) -> String? {
        guard count > to && to >= 0 else { return nil }
        let index = self.index(self.startIndex, offsetBy: to)
        return self.substring(to: index)
    }
    
    public func substring(with range: Range<Int>) -> String? {
        guard count > range.lowerBound && range.lowerBound >= 0 else { return nil }
        guard count > range.upperBound && range.upperBound >= 0 else { return nil }
        let lower = self.index(self.startIndex, offsetBy: range.lowerBound)
        let upper = self.index(self.startIndex, offsetBy: range.upperBound)
        let range = Range(uncheckedBounds: (lower, upper))
        return self.substring(with: range)
    }
    
    public func substring(_ lower: Int, _ upper: Int) -> String? {
        guard count > lower && lower >= 0 else { return nil }
        guard count > upper && upper >= 0 else { return nil }
        let lowerIndex = self.index(self.startIndex, offsetBy: lower)
        let upperIndex = self.index(lowerIndex, offsetBy: upper)
        let range = Range(uncheckedBounds: (lowerIndex, upperIndex))
        return self.substring(with: range)
    }
}

// MARK: - 字符串处理
public extension String {
    
    public func attributesText(_ attributes: [String: Any]?) -> NSAttributedString {
        return NSAttributedString(string: self, attributes: attributes)
    }
    
    public func getTextOfLines(width: CGFloat, attributes: [String: Any]?) -> [String] {
        let attStr = NSAttributedString(string: self, attributes: attributes)
        let frameSetter = CTFramesetterCreateWithAttributedString(attStr as CFAttributedString)
        let path = CGMutablePath()
        path.addRect(CGRect(x: 0, y: 0, width: width, height: CGFloat.greatestFiniteMagnitude))
        let frame = CTFramesetterCreateFrame(frameSetter, CFRangeMake(0, 0), path, nil)
        let lines = CTFrameGetLines(frame) as NSArray
        var textOfLines: [String] = []
        for line in lines {
            // swiftlint:disable:next force_cast
            let lineRange = CTLineGetStringRange(line as! CTLine)
            let range = NSRange(location: lineRange.location, length: lineRange.length)
            let lineString = (self as NSString).substring(with: range)
            textOfLines.append(lineString as String)
        }
        return textOfLines
    }
    
    public func truncatingTailByChar(maxLine: Int, width: CGFloat, attributes: [String: Any]?) -> String {
        let textOfLines = self.getTextOfLines(width: width, attributes: attributes)
        var resultText: String = ""
        var maxTextLine = maxLine
        for (index, text) in textOfLines.enumerated() {
            if text == "\n" {
                resultText += text
                maxTextLine += 1
                continue
            }
            if index == maxTextLine - 1 {
                var truncatingText: String = text
                if let lastChar = text.last, textOfLines.count > maxTextLine {
                    let lastText = String(lastChar)
                    if lastText.isEmptyCharacter || lastText.isEnglishCharacter || lastText.isNumberCharacter {
                        truncatingText = text.substring(to: text.count - 2) ?? text
                    } else {
                        truncatingText = text.substring(to: text.count - 1) ?? text
                    }
                    resultText += truncatingText + "..."
                } else {
                    resultText += truncatingText
                }
                break
            } else {
                resultText += text
            }
        }
        return resultText
    }
}

// MARK: - 计算高度、宽度、行距
public extension String {
    
    public func heightForLabel(width: CGFloat, font: UIFont, lineSpacing: CGFloat = 5, alignment: NSTextAlignment = .left) -> CGFloat {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = lineSpacing
        paragraphStyle.alignment = alignment
        let attributes: [String: Any] = [
            NSFontAttributeName: font,
            NSParagraphStyleAttributeName: paragraphStyle
        ]
        let textSize = textSizeForLabel(width: width, height: CGFloat(Float.greatestFiniteMagnitude), attributes: attributes)
        return textSize.height
    }
    
    public func heightForLabel(width: CGFloat, attributes: [String: Any]) -> CGFloat {
        let textSize = textSizeForLabel(width: width, height: CGFloat(Float.greatestFiniteMagnitude), attributes: attributes)
        return textSize.height
    }
    
    public func widthForLabel(height: CGFloat, font: UIFont) -> CGFloat {
        let labelTextAttributes = [NSFontAttributeName: font]
        let textSize = textSizeForLabel(width: CGFloat(Float.greatestFiniteMagnitude), height: height, attributes: labelTextAttributes)
        return textSize.width
    }
    
    public func widthForLabel(height: CGFloat, attributes: [String: Any]) -> CGFloat {
        let textSize = textSizeForLabel(width: CGFloat(Float.greatestFiniteMagnitude), height: height, attributes: attributes)
        return textSize.width
    }
    
    public func textSizeForLabel(width: CGFloat, height: CGFloat, font: UIFont, lineSpacing: CGFloat = 5, alignment: NSTextAlignment = .left) -> CGSize {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = lineSpacing
        paragraphStyle.alignment = alignment
        let attributes: [String: Any] = [
            NSFontAttributeName: font,
            NSParagraphStyleAttributeName: paragraphStyle
        ]
        let textSize = textSizeForLabel(width: width, height: height, attributes: attributes)
        return textSize
    }
    
    public func textSizeForLabel(size: CGSize, attributes: [String: Any]) -> CGSize {
        let textSize = textSizeForLabel(width: size.width, height: size.height, attributes: attributes)
        return textSize
    }
    
    public func textSizeForLabel(width: CGFloat, height: CGFloat, attributes: [String: Any]) -> CGSize {
        let defaultOptions: NSStringDrawingOptions = [.usesLineFragmentOrigin, .usesFontLeading]
        let maxSize = CGSize(width: width, height: height)
        let rect = self.boundingRect(with: maxSize, options: defaultOptions, attributes: attributes, context: nil)
        
        let textWidth: CGFloat = CGFloat(ceil(rect.width) + 1)
        let textHeight: CGFloat = CGFloat(ceil(rect.height) + 1)
        return CGSize(width: textWidth, height: textHeight)
    }
}

public extension NSAttributedString {
    
    public func heightForLabel(width: CGFloat) -> CGFloat {
        let textSize = textSizeForLabel(width: width, height: CGFloat(Float.greatestFiniteMagnitude))
        return textSize.height
    }
    
    public func widthForLabel(height: CGFloat) -> CGFloat {
        let textSize = textSizeForLabel(width: CGFloat(Float.greatestFiniteMagnitude), height: height)
        return textSize.width
    }
    
    public func textSizeForLabel(width: CGFloat, height: CGFloat) -> CGSize {
        let defaultOptions: NSStringDrawingOptions = [.usesLineFragmentOrigin, .usesFontLeading]
        let maxSize = CGSize(width: width, height: height)
        let rect = self.boundingRect(with: maxSize, options: defaultOptions, context: nil)
        let textWidth: CGFloat = CGFloat(ceil(rect.width) + 1)
        let textHeight: CGFloat = CGFloat(ceil(rect.height) + 1)
        return CGSize(width: textWidth, height: textHeight)
    }
}

// MARK: - 通过正则表达式替换匹配
public extension String {
    public func replacingStringOfRegularExpression(pattern: String, template: String) -> String {
        var content = self
        content = content.replacingOccurrences(of: pattern, with: template, options: .regularExpression, range: nil)
        return content
    }
    
    public func matches(pattern: String) -> [NSTextCheckingResult] {
        do {
            let range = NSRange(location: 0, length: count)
            let expression = try NSRegularExpression(pattern: pattern, options: .caseInsensitive)
            let matchResults = expression.matches(in: self, options: .reportCompletion, range: range)
            return matchResults
        } catch {
            debugLog(error)
        }
        return []
    }
    
    public func firstMatch(pattern: String) -> NSTextCheckingResult? {
        do {
            let range = NSRange(location: 0, length: count)
            let expression = try NSRegularExpression(pattern: pattern, options: .caseInsensitive)
            let match = expression.firstMatch(in: self, options: .reportCompletion, range: range)
            return match
            
        } catch {
            debugLog(error)
        }
        return nil
    }
}

// MARK: - 字符判断
public extension String {
    
    public var urlEncoding: String {
        return addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed) ?? self
    }
    
    /// HTML 字符转义
    public var htmlEntityDecode: String {
        
        guard contains("&") else {
            return self
        }
        
        var text = replacingOccurrences(of: "&quot;", with: "\"")
        text = text.replacingOccurrences(of: "&apos;", with: "'")
        text = text.replacingOccurrences(of: "&lt;", with: "<")
        text = text.replacingOccurrences(of: "&gt;", with: ">")
        text = text.replacingOccurrences(of: "&amp;", with: "&")
        text = text.replacingOccurrences(of: "&nbsp;", with: "")
        
        return text
    }
    
    public var englishCharacterCount: Int {
        var englishCount: Int = 0
        for character in self {
            let characterString = String(character)
            if characterString.isEnglishCharacter || characterString.isNumberCharacter {
                englishCount += 1
            }
        }
        return englishCount
    }
    
    public var chineseCharacterCount: Int {
        let currentNumber = self.count - Int(Float(englishCharacterCount/2) + 0.5)
        return currentNumber
    }
    
    public var isEmptyCharacter: Bool {
        let resetText = self.trimmingCharacters(in: .whitespacesAndNewlines)
        return resetText.isEmpty ? true : false
    }
    
    public var isEnglishCharacter: Bool {
        for char in self.utf8 {
            if char > 64 && char < 91 || char > 96 && char < 123 {
                return true
            }
            return false
        }
        return false
    }
    
    public var isNumberCharacter: Bool {
        for char in self.utf8 {
            if char > 47 && char < 58 {
                return true
            }
            return false
        }
        return false
    }
    
    public var isContainsEmoji: Bool {
        
        for scalar in self.unicodeScalars {
            switch scalar.value {
            case 0x1F000...0x2FFFF:
                return true
            default:
                break
            }
        }
        return false
    }
}
