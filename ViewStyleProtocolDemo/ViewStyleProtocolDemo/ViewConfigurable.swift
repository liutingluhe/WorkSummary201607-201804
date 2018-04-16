//
//  ViewStyleConfigurable.swift
//  ViewStyleProtocolDemo
//
//  Created by luhe liu on 2018/4/12.
//  Copyright © 2018年 luhe liu. All rights reserved.
//

import UIKit
import Foundation

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
    
    lazy var backgroundColor: UIColor? = UIColor.clear
    lazy var borderWidth: CGFloat = 0
    lazy var borderColor: UIColor? = UIColor.clear
    lazy var cornerRadius: CGFloat = 0
    lazy var clipsToBounds: Bool = false
    lazy var contentMode: UIViewContentMode = .scaleToFill
    lazy var padding: UIEdgeInsets = .zero
    lazy var size: CGSize = .zero
}

/// Label 配置项
class LabelConfiguration: ViewConfiguration {
    lazy var numberOfLines: Int = 1
    lazy var textColor: UIColor? = UIColor.black
    lazy var textBackgroundColor: UIColor? = UIColor.clear
    lazy var font: UIFont? = UIFont.systemFont(ofSize: 14)
    lazy var textAlignment: NSTextAlignment = .left
    lazy var lineBreakMode: NSLineBreakMode = .byTruncatingTail
    lazy var lineSpacing: CGFloat = 0
    lazy var characterSpacing: CGFloat = 0
    
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
        if let textBackgroundColor = self.textBackgroundColor {
            attributes[NSBackgroundColorAttributeName] = textBackgroundColor
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
    
    lazy var titleFont: UIFont = UIFont.systemFont(ofSize: 14)
    lazy var titleColor = StateStyle<UIColor>()
    lazy var image = StateStyle<UIImage>()
    lazy var title = StateStyle<String>()
    lazy var backgroundImage = StateStyle<UIImage>()
    lazy var contentEdgeInsets: UIEdgeInsets = .zero
    lazy var imageEdgeInsets: UIEdgeInsets = .zero
    lazy var titleEdgeInsets: UIEdgeInsets = .zero
}

/// ImageView 配置项
class ImageConfiguration: ViewConfiguration {
    var image: UIImage?
}
