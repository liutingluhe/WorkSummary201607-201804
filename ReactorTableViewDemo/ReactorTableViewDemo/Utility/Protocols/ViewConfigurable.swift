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
public protocol ViewConfigurable: class {
    associatedtype ConfigType: ConfigurationType
    static var config: ConfigType { get }
}

// MARK: - 以下是一些常用配置项
public protocol ConfigurationType: class {
    func apply(to view: Any)
}

/// 布局配置
open class LayoutConfiguration {
    open lazy var padding: UIEdgeInsets = .zero
    open lazy var verticalPadding: CGFloat = 0
    open lazy var horizontalPadding: CGFloat = 0
    open lazy var size: CGSize = .zero
    open lazy var center: CGPoint = .zero
    open var rect: CGRect {
        return CGRect(x: padding.left, y: padding.top, width: size.width, height: size.height)
    }
}

/// Layer 配置项
open class LayerConfiguration: LayoutConfiguration, ConfigurationType {
    
    open lazy var zPosition: CGFloat = 0
    open lazy var anchorPoint: CGPoint = CGPoint(x: 0.5, y: 0.5)
    open lazy var anchorPointZ: CGFloat = 0
    open lazy var masksToBounds: Bool = false
    open lazy var opacity: Float = 1
    
    open func apply(to view: Any) {
        guard let layer = view as? CALayer else { return }
        layer.zPosition = self.zPosition
        layer.anchorPoint = self.anchorPoint
        layer.anchorPointZ = self.anchorPointZ
        layer.masksToBounds = self.masksToBounds
        layer.opacity = self.opacity
    }
}

/// ShapeLayer 配置项
open class ShapeLayerConfiguration: LayerConfiguration {
    open lazy var strokeStart: CGFloat = 0
    open lazy var strokeEnd: CGFloat = 1
    open lazy var lineWidth: CGFloat = 1
    open lazy var miterLimit: CGFloat = 10
    open lazy var fillRule: String = kCAFillRuleNonZero
    open lazy var lineCap: String = kCALineCapButt
    open lazy var lineJoin: String = kCALineJoinMiter
    open lazy var lineDashPhase: CGFloat = 0
    open var path: CGPath?
    open var lineDashPattern: [Int]?
    open var fillColor: UIColor?
    open var strokeColor: UIColor?
    
    open override func apply(to view: Any) {
        super.apply(to: view)
        guard let layer = view as? CAShapeLayer else { return }
        layer.fillColor = self.fillColor?.cgColor
        layer.strokeColor = self.strokeColor?.cgColor
        layer.strokeStart = self.strokeStart
        layer.strokeEnd = self.strokeEnd
        layer.lineWidth = self.lineWidth
        layer.miterLimit = self.miterLimit
        layer.fillRule = self.fillRule
        layer.lineCap = self.lineCap
        layer.lineJoin = self.lineJoin
        layer.lineDashPhase = self.lineDashPhase
        layer.lineDashPattern = self.lineDashPattern?.map({ NSNumber(value: $0) })
        layer.path = self.path
    }
}

/// View 配置项
open class ViewConfiguration: LayoutConfiguration, ConfigurationType {
    
    open lazy var backgroundColor: UIColor? = UIColor.clear
    open lazy var borderWidth: CGFloat = 0
    open lazy var borderColor: UIColor? = UIColor.clear
    open lazy var cornerRadius: CGFloat = 0
    open lazy var clipsToBounds: Bool = false
    open lazy var contentMode: UIViewContentMode = .scaleToFill
    
    open func apply(to view: Any) {
        guard let view = view as? UIView else { return }
        view.backgroundColor = self.backgroundColor
        view.layer.borderWidth = self.borderWidth
        view.layer.borderColor = self.borderColor?.cgColor
        view.layer.cornerRadius = self.cornerRadius
        view.clipsToBounds = self.clipsToBounds
        view.contentMode = self.contentMode
    }

}

/// Label 配置项
open class LabelConfiguration: ViewConfiguration {
    open lazy var numberOfLines: Int = 1
    open lazy var text: String = ""
    open lazy var textColor: UIColor? = UIColor.black
    open lazy var textBackgroundColor: UIColor = UIColor.clear
    open lazy var font: UIFont = UIFont.systemFont(ofSize: 14)
    open lazy var textAlignment: NSTextAlignment = .left
    open lazy var lineBreakMode: NSLineBreakMode = .byCharWrapping
    open lazy var lineSpacing: CGFloat = 0
    open lazy var characterSpacing: CGFloat = 0
    open lazy var baselineOffset: TimeInterval = 0
    open var underlineStyle: NSUnderlineStyle?
    open var underlineColor: UIColor?

    // 属性表，用于属性字符串使用
    open var attributes: [String: Any] {
        
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = self.lineSpacing - (self.font.lineHeight - self.font.pointSize)
        paragraphStyle.lineBreakMode = self.lineBreakMode
        paragraphStyle.alignment = self.textAlignment
        var attributes: [String: Any] = [
            NSParagraphStyleAttributeName: paragraphStyle,
            NSKernAttributeName: self.characterSpacing,
            NSFontAttributeName: self.font,
            NSBackgroundColorAttributeName: self.textBackgroundColor,
            NSBaselineOffsetAttributeName: NSNumber(value: self.baselineOffset)
        ]
        if let textColor = self.textColor {
            attributes[NSForegroundColorAttributeName] = textColor
        }
        if let underlineStyle = self.underlineStyle {
            attributes[NSUnderlineStyleAttributeName] = NSNumber(value: underlineStyle.rawValue)
            attributes[NSUnderlineColorAttributeName] = self.underlineColor
        }
        return attributes
    }
    
    open override func apply(to view: Any) {
        super.apply(to: view)
        guard let label = view as? UILabel else { return }
        label.numberOfLines = self.numberOfLines
        label.textAlignment = self.textAlignment
        label.lineBreakMode = self.lineBreakMode
        label.textColor = self.textColor
        label.font = self.font
        label.text = self.text
        label.attributedText = NSAttributedString(string: self.text, attributes: attributes)
    }
}

/// Button 配置项
open class ButtonConfiguration: ViewConfiguration {
    
    open class StateStyle<T> {
        open var normal: T?
        open var highlighted: T?
        open var selected: T?
        open var disabled: T?
    }
    
    public enum TextImageMode {
        case leftTextRightImage(space: CGFloat)
        case leftImageRightText(space: CGFloat)
        case upTextDownImage(space: CGFloat)
        case upImageDownText(space: CGFloat)
    }
    
    open lazy var title = LabelConfiguration()
    open lazy var image = ImageConfiguration()
    open lazy var titleColorState = StateStyle<UIColor>()
    open lazy var titleTextState = StateStyle<String>()
    open lazy var imageState = StateStyle<UIImage>()
    open lazy var backgroundImageState = StateStyle<UIImage>()
    open lazy var contentEdgeInsets: UIEdgeInsets = .zero
    open lazy var imageEdgeInsets: UIEdgeInsets = .zero
    open lazy var titleEdgeInsets: UIEdgeInsets = .zero
    
    open override func apply(to view: Any) {
        super.apply(to: view)
        guard let button = view as? UIButton else { return }
        if let titleLabel = button.titleLabel {
            self.title.apply(to: titleLabel)
        }
        if let imageView = button.imageView {
            self.image.apply(to: imageView)
        }
        button.setTitle(self.titleTextState.normal, for: .normal)
        button.setTitle(self.titleTextState.highlighted, for: .highlighted)
        button.setTitle(self.titleTextState.selected, for: .selected)
        button.setTitle(self.titleTextState.disabled, for: .disabled)
        button.setTitleColor(self.titleColorState.normal, for: .normal)
        button.setTitleColor(self.titleColorState.highlighted, for: .highlighted)
        button.setTitleColor(self.titleColorState.selected, for: .selected)
        button.setTitleColor(self.titleColorState.disabled, for: .disabled)
        button.setImage(self.imageState.normal, for: .normal)
        button.setImage(self.imageState.highlighted, for: .highlighted)
        button.setImage(self.imageState.selected, for: .selected)
        button.setImage(self.imageState.disabled, for: .disabled)
        button.setBackgroundImage(self.backgroundImageState.normal, for: .normal)
        button.setBackgroundImage(self.backgroundImageState.highlighted, for: .highlighted)
        button.setBackgroundImage(self.backgroundImageState.selected, for: .selected)
        button.setBackgroundImage(self.backgroundImageState.disabled, for: .disabled)
        button.contentEdgeInsets = self.contentEdgeInsets
        button.imageEdgeInsets = self.imageEdgeInsets
        button.titleEdgeInsets = self.titleEdgeInsets
    }
    
    open func setTextMode(_ mode: TextImageMode) {
        
        let text = self.titleTextState.normal ?? self.title.text
        let labelSize = text.textSizeForLabel(size: self.size, attributes: self.title.attributes)
        let labelWidth = labelSize.width
        let labelHeight = labelSize.height
        let imageWidth = self.image.size.width
        let imageHeight = self.image.size.height
        
        // labelWidthPadding 的作用是尽量让 titleLabel 的 width 更大些
        let labelWidthPadding = max((self.size.width - labelWidth) * 0.5, 0)
        let imageWidthPadding = max((self.size.width - imageWidth) * 0.5, 0)
        let controlsHeight = labelHeight + imageHeight
        let controlsWidth = labelWidth + imageWidth
        switch mode {
        case let .leftTextRightImage(space: space):
            self.imageEdgeInsets = UIEdgeInsets(top: 0, left: labelWidth + space * 0.5, bottom: 0, right: -labelWidth - space * 0.5)
            self.titleEdgeInsets = UIEdgeInsets(top: 0, left: -imageWidth - space * 0.5, bottom: 0, right: imageWidth + space * 0.5)
        
        case let .leftImageRightText(space: space):
            self.imageEdgeInsets = UIEdgeInsets(top: 0, left: -space * 0.5, bottom: 0, right: space * 0.5)
            self.titleEdgeInsets = UIEdgeInsets(top: 0, left: space * 0.5, bottom: 0, right: -space * 0.5)
        
        case let .upTextDownImage(space: space):
            let labelVerticalInset: CGFloat = (controlsHeight - labelHeight + space) * 0.5
            let labelHorizontalInset: CGFloat = (controlsWidth - labelWidth) * 0.5
            let imageVerticalInset: CGFloat = (controlsHeight - imageHeight + space) * 0.5
            let imageHorizontalInset: CGFloat = (controlsWidth - imageWidth) * 0.5
            self.titleEdgeInsets = UIEdgeInsets(
                top: -labelVerticalInset,
                left: -labelHorizontalInset - labelWidthPadding,
                bottom: labelVerticalInset,
                right: labelHorizontalInset - labelWidthPadding
            )
            self.imageEdgeInsets = UIEdgeInsets(
                top: imageVerticalInset,
                left: imageHorizontalInset - imageWidthPadding,
                bottom: -imageVerticalInset,
                right: -imageHorizontalInset - imageWidthPadding
            )
        
        case let .upImageDownText(space: space):
            let imageVerticalInset: CGFloat = (controlsHeight - imageHeight + space) * 0.5
            let imageHorizontalInset: CGFloat = (controlsWidth - imageWidth) * 0.5
            let labelVerticalInset: CGFloat = (controlsHeight - labelHeight + space) * 0.5
            let labelHorizontalInset: CGFloat = (controlsWidth - labelWidth) * 0.5
            self.imageEdgeInsets = UIEdgeInsets(
                top: -imageVerticalInset,
                left: imageHorizontalInset - imageWidthPadding,
                bottom: imageVerticalInset,
                right: -imageHorizontalInset - imageWidthPadding
            )
            self.titleEdgeInsets = UIEdgeInsets(
                top: labelVerticalInset,
                left: -labelHorizontalInset - labelWidthPadding,
                bottom: -labelVerticalInset,
                right: labelHorizontalInset - labelWidthPadding
            )
        }
    }
}

/// ImageView 配置项
open class ImageConfiguration: ViewConfiguration {
    open var image: UIImage?
    
    open override func apply(to view: Any) {
        super.apply(to: view)
        guard let imageView = view as? UIImageView else { return }
        imageView.image = self.image
    }
}

/// ScollView 滚动控件
open class ScrollConfiguration: ViewConfiguration {
    open var contentInset: UIEdgeInsets = .zero
    open var contentSize: CGSize = .zero
    open var isScrollEnabled: Bool = true
    open var showsVerticalScrollIndicator: Bool = false
    open var showsHorizontalScrollIndicator: Bool = false
    open var isAdjustsScrollViewInsets: Bool = false
    
    open override func apply(to view: Any) {
        super.apply(to: view)
        guard let scrollView = view as? UIScrollView else { return }
        scrollView.contentInset = self.contentInset
        scrollView.contentSize = self.contentSize
        scrollView.isScrollEnabled = self.isScrollEnabled
        scrollView.showsVerticalScrollIndicator = self.showsVerticalScrollIndicator
        scrollView.showsHorizontalScrollIndicator = self.showsHorizontalScrollIndicator
        if !self.isAdjustsScrollViewInsets {
            scrollView.removeAdjustmentBehavior()
        }
    }
}

/// TextView 配置项
open class TextViewConfiguration: ScrollConfiguration {
    
    var normal = LabelConfiguration()
    var link = LabelConfiguration()
    var textContainerInset: UIEdgeInsets = .zero
    var isEditable: Bool = false
    var isSelectable: Bool = true
    var allowsEditingTextAttributes: Bool = false
    var clearsOnInsertion: Bool = false
    
    open override func apply(to view: Any) {
        super.apply(to: view)
        guard let textView = view as? UITextView else { return }
        textView.text = normal.text
        textView.textColor = normal.textColor
        textView.font = normal.font
        textView.textAlignment = normal.textAlignment
        textView.typingAttributes = self.normal.attributes
        textView.linkTextAttributes = self.link.attributes
        textView.textContainerInset = self.textContainerInset
        textView.isEditable = self.isEditable
        textView.isSelectable = self.isSelectable
        textView.allowsEditingTextAttributes = self.allowsEditingTextAttributes
        textView.clearsOnInsertion = self.clearsOnInsertion
    }
}

