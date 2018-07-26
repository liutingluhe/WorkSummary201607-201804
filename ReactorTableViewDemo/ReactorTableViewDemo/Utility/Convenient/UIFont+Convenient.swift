//
//  UIFont+Convenient.swift
//  ifanr
//
//  Created by luhe liu on 2018/6/26.
//  Copyright © 2018年 com.ifanr. All rights reserved.
//

import UIKit

public extension UIFont {
    
    public enum FontWeight: String {
        case light = "-Light"
        case regular = "-Regular"
        case medium = "-Medium"
        case semibold = "-Semibold"
        case bold = "-Bold"
        case heavy = "-Heavy"
    }
    
    public static func customFont(fontName: String, weight: UIFont.FontWeight, fontSize: CGFloat) -> UIFont {
        if let customFont = UIFont(name: "\(fontName)\(weight.rawValue)", size: fontSize) {
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
            return UIFont.systemFont(ofSize: fontSize, weight: systemWeight)
        } else {
            return UIFont.systemFont(ofSize: fontSize)
        }
    }
}

