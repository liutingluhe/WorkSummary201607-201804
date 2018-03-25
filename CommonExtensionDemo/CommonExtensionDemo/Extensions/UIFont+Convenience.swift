//
//  UIFont+Convenience.swift
//  CommonExtensionDemo
//
//  Created by catch on 18/3/25.
//  Copyright © 2018年 执着·执念. All rights reserved.
//

import UIKit

enum FontWeight: String {
    case light = "Light"
    case regular = "Regular"
    case medium = "Medium"
    case semibold = "Semibold"
    case bold = "Bold"
    case heavy = "Heavy"
}

enum FontType: String {
    case PingFangSC = "PingFangSC"
    case SFProText = "SFProText"
}

extension UIFont {
    
    static func heavyFont(ofSize fontSize: CGFloat, type: FontType = .PingFangSC) -> UIFont {
        return customFont(type, weight: .heavy, fontSize: fontSize)
    }
    
    static func regularFont(ofSize fontSize: CGFloat, type: FontType = .PingFangSC) -> UIFont {
        return customFont(type, weight: .regular, fontSize: fontSize)
    }
    
    static func boldFont(ofSize fontSize: CGFloat, type: FontType = .PingFangSC) -> UIFont {
        return customFont(type, weight: .bold, fontSize: fontSize)
    }
    
    static func lightFont(ofSize fontSize: CGFloat, type: FontType = .PingFangSC) -> UIFont {
        return customFont(type, weight: .light, fontSize: fontSize)
    }
    
    static func mediumFont(ofSize fontSize: CGFloat, type: FontType = .PingFangSC) -> UIFont {
        return customFont(type, weight: .medium, fontSize: fontSize)
    }
    
    static func semiboldFont(ofSize fontSize: CGFloat, type: FontType = .PingFangSC) -> UIFont {
        return customFont(type, weight: .semibold, fontSize: fontSize)
    }
    
    /// 自定义字体
    static func customFont(_ type: FontType, weight: FontWeight, fontSize: CGFloat) -> UIFont {
        let realFontSize = fontSize
        if let customFont = UIFont(name: "\(type.rawValue)-\(weight.rawValue)", size: realFontSize) {
            return customFont
        }
        if #available(iOS 8.2, *) {
            var systemWeight: CGFloat = UIFontWeightRegular
            switch weight {
            case .light:
                systemWeight = UIFontWeightLight
            case .regular:
                systemWeight = UIFontWeightRegular
            case .medium:
                systemWeight = UIFontWeightMedium
            case .semibold:
                systemWeight = UIFontWeightSemibold
            case .bold:
                systemWeight = UIFontWeightBold
            case .heavy:
                systemWeight = UIFontWeightHeavy
            }
            return UIFont.systemFont(ofSize: realFontSize, weight: systemWeight)
        } else {
            return UIFont.systemFont(ofSize: realFontSize)
        }
    }
}
