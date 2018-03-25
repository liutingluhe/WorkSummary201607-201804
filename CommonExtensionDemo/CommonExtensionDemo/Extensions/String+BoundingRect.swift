//
//  String+BoundingRect.swift
//  CommonExtensionDemo
//
//  Created by catch on 18/3/25.
//  Copyright © 2018年 执着·执念. All rights reserved.
//

import UIKit

extension String {

    /// 给定最大宽计算高度，传入字体、行距、对齐方式（便捷调用）
    func heightForLabel(width: CGFloat, font: UIFont, lineSpacing: CGFloat = 5, alignment: NSTextAlignment = .left) -> CGFloat {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = lineSpacing
        paragraphStyle.alignment = alignment
        let attributes: [String : Any] = [
            NSFontAttributeName: font,
            NSParagraphStyleAttributeName: paragraphStyle
        ]
        let textSize = textSizeForLabel(width: width, height: CGFloat(Float.greatestFiniteMagnitude), attributes: attributes)
        return textSize.height
    }
    
    /// 给定最大宽计算高度，传入属性字典（便捷调用）
    func heightForLabel(width: CGFloat, attributes: [String: Any]) -> CGFloat {
        let textSize = textSizeForLabel(width: width, height: CGFloat(Float.greatestFiniteMagnitude), attributes: attributes)
        return textSize.height
    }
    
    /// 给定最大高计算宽度，传入字体（便捷调用）
    func widthForLabel(height: CGFloat, font: UIFont) -> CGFloat {
        let labelTextAttributes = [NSFontAttributeName: font]
        let textSize = textSizeForLabel(width: CGFloat(Float.greatestFiniteMagnitude), height: height, attributes: labelTextAttributes)
        return textSize.width
    }
    
    /// 给定最大高计算宽度，传入属性字典（便捷调用）
    func widthForLabel(height: CGFloat, attributes: [String: Any]) -> CGFloat {
        let textSize = textSizeForLabel(width: CGFloat(Float.greatestFiniteMagnitude), height: height, attributes: attributes)
        return textSize.width
    }
    
    /// 给定最大宽高计算宽度和高度，传入字体、行距、对齐方式（便捷调用）
    func textSizeForLabel(width: CGFloat, height: CGFloat, font: UIFont, lineSpacing: CGFloat = 5, alignment: NSTextAlignment = .left) -> CGSize {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = lineSpacing
        paragraphStyle.alignment = alignment
        let attributes: [String : Any] = [
            NSFontAttributeName: font,
            NSParagraphStyleAttributeName: paragraphStyle
        ]
        let textSize = textSizeForLabel(width: width, height: height, attributes: attributes)
        return textSize
    }
    
    /// 给定最大宽高计算宽度和高度，传入属性字典（便捷调用）
    func textSizeForLabel(size: CGSize, attributes: [String: Any]) -> CGSize {
        let textSize = textSizeForLabel(width: size.width, height: size.height, attributes: attributes)
        return textSize
    }
    
    /// 给定最大宽高计算宽度和高度，传入属性字典（核心)
    func textSizeForLabel(width: CGFloat, height: CGFloat, attributes: [String: Any]) -> CGSize {
        let defaultOptions: NSStringDrawingOptions = [.usesLineFragmentOrigin, .usesFontLeading]
        let maxSize = CGSize(width: width, height: height)
        let rect = self.boundingRect(with: maxSize, options: defaultOptions, attributes: attributes, context: nil)
        let textWidth: CGFloat = CGFloat(Int(rect.width) + 1)
        let textHeight: CGFloat = CGFloat(Int(rect.height) + 1)
        return CGSize(width: textWidth, height: textHeight)
    }
}

extension NSAttributedString {
    
    /// 根据最大宽计算高度（便捷调用)
    func heightForLabel(width: CGFloat) -> CGFloat {
        let textSize = textSizeForLabel(width: width, height: CGFloat(Float.greatestFiniteMagnitude))
        return textSize.height
    }
    
    /// 根据最大高计算宽度（便捷调用)
    func widthForLabel(height: CGFloat) -> CGFloat {
        let textSize = textSizeForLabel(width: CGFloat(Float.greatestFiniteMagnitude), height: height)
        return textSize.width
    }
    
    /// 计算宽度和高度（核心)
    func textSizeForLabel(width: CGFloat, height: CGFloat) -> CGSize {
        let defaultOptions: NSStringDrawingOptions = [.usesLineFragmentOrigin, .usesFontLeading]
        let maxSize = CGSize(width: width, height: height)
        let rect = self.boundingRect(with: maxSize, options: defaultOptions, context: nil)
        let textWidth: CGFloat = CGFloat(Int(rect.width) + 1)
        let textHeight: CGFloat = CGFloat(Int(rect.height) + 1)
        return CGSize(width: textWidth, height: textHeight)
    }
}
