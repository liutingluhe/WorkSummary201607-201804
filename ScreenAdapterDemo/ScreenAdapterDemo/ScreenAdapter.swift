//
//  ScreenAdapter.swift
//  ScreenAdapterDemo
//
//  Created by luhe liu on 2018/4/11.
//  Copyright © 2018年 com.liuting. All rights reserved.
//

import UIKit

/// 适配类型
enum AdaptType<T> {
    // iPhone 水平适配
    case iPhoneHorizontal(small: T, normal: T, large: T)
    // iPhone 垂直适配
    case iPhoneVertical(inch35: T, inch40: T, inch47: T, inch55: T, inch58: T)
    // iPad 适配
    case iPad(normal: T, pro: T)
    // iPhoneX 适配
    case iPhoneX(T, other: T)
    // Retina 适配
    case screenScale(x1: T, x2: T, x3: T)
    
    // 适配值
    var value: T {
        return ScreenAdapter.shared.adapt(to: self)
    }
}

/// 为 CGFloat 添加分类， 用于通用 iPhoneX 适配顶部状态栏高度和底部工具栏高度
extension CGFloat {
    
    var addTopForInchX: CGFloat {
        return AdaptType<CGFloat>.iPhoneX(24, other: 0).value
    }
    
    var addBottomForInchX: CGFloat {
        return AdaptType<CGFloat>.iPhoneX(34, other: 0).value
    }
}

/// 适配工具单例类
class ScreenAdapter {
    
    static let shared = ScreenAdapter()

    // 屏幕规格
    enum ScreenSpecs {
        
        enum iPhoneInch: Double {
            case inch35 = 3.5 // 主屏分辨率： 640 * 960
            case inch40 = 4.0 // 主屏分辨率： 640 * 1136
            case inch47 = 4.7 // 主屏分辨率： 750 * 1334
            case inch55 = 5.5 // 主屏分辨率： 1080 * 1920
            case inch58 = 5.8 // 主屏分辨率： 1125 * 2436
        }
        
        enum iPadInch {
            case normal, pro
        }
        
        case iPhone(iPhoneInch)
        case iPad(iPadInch)
        case unknown
    }
    
    // 当前屏幕规格
    var screenSpecs: ScreenSpecs = .iPhone(.inch47)
    
    // 是否为 iPhoneX
    var isInchX: Bool {
        if case .iPhone(.inch58) = screenSpecs {
            return true
        }
        return false
    }
    
    // 初始化计算屏幕宽高，得到对应的屏幕规格
    fileprivate init() {
        var screenWidth: CGFloat = ceil(UIScreen.main.bounds.size.width)
        var screenHeight: CGFloat = ceil(UIScreen.main.bounds.size.height)
        if screenWidth > screenHeight {
            let tmp: CGFloat = screenWidth
            screenWidth = screenHeight
            screenHeight = tmp
        }
        screenSpecs = .unknown
        switch screenWidth {
        case 320:
            if screenHeight <= 480 {
                screenSpecs = .iPhone(.inch35)
            } else if screenHeight == 568 {
                screenSpecs = .iPhone(.inch40)
            }
        case 375:
            if screenHeight <= 667 {
                screenSpecs = .iPhone(.inch47)
            } else if screenHeight == 812 {
                screenSpecs = .iPhone(.inch58)
            }
        case 414:
            screenSpecs = .iPhone(.inch55)
        case 768:
            screenSpecs = .iPad(.normal)
        case 1024:
            screenSpecs = .iPad(.pro)
        default:
            break
        }
    }
    
    /// 根据适配类型，得到对应屏幕规格下的值
    func adapt<T>(to type: AdaptType<T>) -> T {
        
        switch type {
        // iPhone 水平适配
        case let .iPhoneHorizontal(small, normal, big):
            switch screenSpecs {
            case .iPhone(.inch35): return small
            case .iPhone(.inch40): return small
            case .iPhone(.inch47): return normal
            case .iPhone(.inch58): return normal
            case .iPhone(.inch55): return big
            default: return small
            }
        // iPhone 垂直适配
        case let .iPhoneVertical(inch35, inch40, inch47, inch55, inch58):
            switch screenSpecs {
            case .iPhone(.inch35): return inch35
            case .iPhone(.inch40): return inch40
            case .iPhone(.inch47): return inch47
            case .iPhone(.inch55): return inch55
            case .iPhone(.inch58): return inch58
            default: return inch35
            }
        // iPad 适配
        case let .iPad(normal, pro):
            switch screenSpecs {
            case .iPad(.normal): return normal
            case .iPad(.pro): return pro
            default: return normal
            }
        // iPhoneX 适配
        case let .iPhoneX(inchX, commonInch):
            switch screenSpecs {
            case .iPhone(.inch58): return inchX
            default: return commonInch
            }
        // Retina 适配
        case let .screenScale(x1, x2, x3):
            switch UIScreen.main.scale {
            case 1: return x1
            case 2: return x2
            default: return x3
            }
        }
    }
}
