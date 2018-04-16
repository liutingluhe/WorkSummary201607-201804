//
//  ViewStyleConfigurable.swift
//  ViewStyleProtocolDemo
//
//  Created by luhe liu on 2018/4/12.
//  Copyright © 2018年 luhe liu. All rights reserved.
//

import UIKit

// MARK: - 视图可配置协议
public protocol ViewStyleConfigurable: class {
    associatedtype ViewStyle
    var viewStyle: ViewStyle? { get set }
    func updateStyle(_ viewStyle: ViewStyle)
}

/// 为实现该协议的类添加一个伪存储属性（利用 objc 的关联方法实现），用来保存样式配置表
fileprivate var viewStyleKey: String = "viewStyleKey"
extension ViewStyleConfigurable {
    
    var viewStyle: ViewStyle? {
        get {
            return objc_getAssociatedObject(self, &viewStyleKey) as? ViewStyle
        }
        set {
            objc_setAssociatedObject(self, &viewStyleKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            if let style = newValue {
                self.updateStyle(style)
            }
        }
    }
}

// MARK: - 以下是一些常用配置项
/// View 配置项
class ViewConfiguration {
    
    var backgroundColor: UIColor?
    var borderWidth: CGFloat = 0
    var borderColor: UIColor?
    var cornerRadius: CGFloat = 0
    var clipsToBounds: Bool = false
    var contentMode: UIViewContentMode = .scaleToFill
    var padding: UIEdgeInsets = .zero
    var size: CGSize = .zero
}

/// Label 配置项
class LabelConfiguration: ViewConfiguration {
    var numberOfLines: Int = 1
    var textColor: UIColor?
    var font: UIFont?
    var textAlignment: NSTextAlignment = .left
    var lineBreakMode: NSLineBreakMode = .byTruncatingTail
    var lineSpacing: CGFloat = 0
    var characterSpacing: CGFloat = 0
    
    // 属性表，用于属性字符串使用
    var attributes: [String: Any]? {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = self.lineSpacing
        paragraphStyle.lineBreakMode = self.lineBreakMode
        paragraphStyle.alignment = self.textAlignment
        var attributes: [String: Any] = [
            NSParagraphStyleAttributeName: paragraphStyle,
            NSKernAttributeName: self.characterSpacing
        ]
        if let font = self.font {
            attributes[NSFontAttributeName] = font
        }
        if let textColor = self.textColor {
            attributes[NSForegroundColorAttributeName] = textColor
        }
        return attributes
    }
}

/// Button 配置项
class ButtonConfiguration: ViewConfiguration {
    
    class StateStyle<T> {
        var normal: T?
        var highlighted: T?
        var selected: T?
        var disabled: T?
    }
    
    var titleColor = StateStyle<UIColor>()
    var titleFont: UIFont?
    var image = StateStyle<UIImage>()
    var title = StateStyle<String>()
    var backgroundImage = StateStyle<UIImage>()
    var contentEdgeInsets: UIEdgeInsets = .zero
    var imageEdgeInsets: UIEdgeInsets = .zero
    var titleEdgeInsets: UIEdgeInsets = .zero
}

/// ImageView 配置项
class ImageConfiguration: ViewConfiguration {
    var image: UIImage?
}
