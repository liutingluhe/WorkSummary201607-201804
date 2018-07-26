//
//  ScreenAdapter.swift
//  ifanr
//
//  Created by luhe liu on 2018/7/13.
//  Copyright © 2018年 com.ifanr. All rights reserved.
//

import UIKit

enum AdaptType<T> {
    case iPhoneHorizontal(small: T, normal: T, large: T)
    case iPhoneVertical(inch35: T, inch40: T, inch47: T, inchX: T, inch55: T)
    case iPad(common: T, pro: T)
    case iPhoneX(T, other: T)
    case screenScale(x2: T, x3: T)
    
    var value: T {
        return ScreenAdapter.shared.adapt(to: self)
    }
}

class ScreenAdapter {
    
    static let shared = ScreenAdapter()
    
    var addTopForInchX: CGFloat {
        return AdaptType<CGFloat>.iPhoneX(24, other: 0).value
    }
    
    var addBottomForInchX: CGFloat {
        return AdaptType<CGFloat>.iPhoneX(34, other: 0).value
    }
    
    struct DeviceDiaonal {
        static let iPhone4: Double = 3.5 // 主屏分辨率： 640 * 960
        static let iPhoneSE: Double = 4.0 // 主屏分辨率： 640 * 1136
        static let iPhone6: Double = 4.7 // 主屏分辨率： 750 * 1334
        static let iPhone6Plus: Double = 5.5 // 主屏分辨率： 1242 * 2208
        static let iPhoneX: Double = 5.8 // 主屏分辨率： 1125 * 2436
    }
    
    // 屏幕规格
    enum ScreenSpecs {
        enum PhoneInch {
            case inch35, inch40, inch47, inch55, inchX
        }
        enum PadInch {
            case common, pro
        }
        case iPhone(PhoneInch)
        case iPad(PadInch)
    }
    
    // 当前屏幕规格
    var screenSpecs: ScreenSpecs = .iPhone(.inch47)
    
    var isInchX: Bool {
        if case .iPhone(.inchX) = screenSpecs {
            return true
        }
        return false
    }
    
    var isiPhoneSE: Bool {
        if case .iPhone(.inch40) = screenSpecs {
            return true
        }
        return false
    }
    
    var isiPhone4: Bool {
        if case .iPhone(.inch35) = screenSpecs {
            return true
        }
        return false
    }
    
    // 当前屏幕尺寸
    var currentDiaonal: Double = DeviceDiaonal.iPhone6
    
    fileprivate init() {
        var width: CGFloat = screenWidth
        var height: CGFloat = screenHeight
        if screenWidth > screenHeight {
            let tmp = width
            width = height
            height = tmp
        }
        
        switch width {
        case 320:
            if height <= 480 {
                currentDiaonal = DeviceDiaonal.iPhone4
                screenSpecs = .iPhone(.inch35)
            } else {
                currentDiaonal = DeviceDiaonal.iPhoneSE
                screenSpecs = .iPhone(.inch40)
            }
            
        case 375:
            if height <= 667 {
                currentDiaonal = DeviceDiaonal.iPhone6
                screenSpecs = .iPhone(.inch47)
            } else {
                currentDiaonal = DeviceDiaonal.iPhoneX
                screenSpecs = .iPhone(.inchX)
            }
            
        case 414:
            currentDiaonal = DeviceDiaonal.iPhone6Plus
            screenSpecs = .iPhone(.inch55)
            
        case 768:
            screenSpecs = .iPad(.common)
            
        case 1024:
            screenSpecs = .iPad(.pro)
            
        default:
            break
        }
    }
    
    /// 由屏幕大小去控制不同的视图、文字大小或者样式
    ///
    /// - Parameter type: 自定义的设备类型（尺寸）
    /// - Returns: 由传进来的值 决定返回 具体的屏幕的适配值
    func adapt<T>(to type: AdaptType<T>) -> T {
        
        switch type {
        case let .screenScale(x2, x3):
            let scale = UIScreen.main.scale
            if scale >= 3 {
                return x3
            } else {
                return x2
            }
            
        case let .iPhoneHorizontal(small, normal, big):
            switch screenSpecs {
            case .iPhone(.inch35):
                return small
            case .iPhone(.inch40):
                return small
            case .iPhone(.inch47):
                return normal
            case .iPhone(.inch55):
                return big
            case .iPhone(.inchX):
                return normal
            default:
                return small
            }
            
        case let .iPhoneVertical(inch35, inch40, inch47, inchX, inch55):
            switch screenSpecs {
            case .iPhone(.inch35):
                return inch35
            case .iPhone(.inch40):
                return inch40
            case .iPhone(.inch47):
                return inch47
            case .iPhone(.inch55):
                return inch55
            case .iPhone(.inchX):
                return inchX
            default:
                return inch35
            }
            
        case let .iPad(common, pro):
            switch screenSpecs {
            case .iPad(.common):
                return common
            case .iPad(.pro):
                return pro
            default:
                return common
            }
            
        case let .iPhoneX(inchX, commonInch):
            switch screenSpecs {
            case .iPhone(.inchX):
                return inchX
            default:
                return commonInch
            }
        }
    }
}
