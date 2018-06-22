//
//  LogoLoadingView.swift
//  ReactorCollectionViewDemo
//
//  Created by luhe liu on 2018/6/22.
//  Copyright © 2018年 luhe liu. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import ReactorKit

struct LogoLoadingStyle {
    
    enum LogoStyle {
        case white
        case black
    }
    
    var loadingSize: CGSize = CGSize(width: 32, height: 32)
    var logoSize: CGSize = CGSize(width: 22, height: 22)
    var logoStyle: LogoStyle = .black
    var opacity: Float = 0.3
    var backgroundColor: UIColor = UIColor.clear
    // 加载缺口宽度
    var gapWidth: Int = 5
    
    var logoWidth: CGFloat { return logoSize.width * 0.4 }
    var logoPointLeftTop: CGPoint { return CGPoint(x: 0, y: 0) }
    var logoPointRightTop: CGPoint { return CGPoint(x: logoWidth, y: 0)  }
    var logoPointRightBottom: CGPoint { return CGPoint(x: logoSize.width, y: logoSize.height)  }
    var logoPointLeftBottom: CGPoint { return CGPoint(x: logoSize.width - logoWidth, y: logoSize.height)  }
    var logoNormalPoints: [CGPoint] {
        return [logoPointRightBottom, logoPointLeftBottom, logoPointLeftTop, logoPointRightTop]
    }
    
    var borderPointLeftTop: CGPoint { return CGPoint(x: 0, y: 0) }
    var borderPointRightTop: CGPoint { return CGPoint(x: loadingSize.width, y: 0) }
    var borderPointRightBottom: CGPoint { return CGPoint(x: loadingSize.width, y: loadingSize.height) }
    var borderPointLeftBottom: CGPoint { return CGPoint(x: 0, y: loadingSize.height) }
    var borderNormalPoints: [CGPoint] {
        return [borderPointRightBottom, borderPointLeftBottom, borderPointLeftTop, borderPointRightTop]
    }
    
    static let commonSize: CGSize = CGSize(width: 50, height: 50)
    struct Color {
        static let blackLogo = UIColor.black
        static let whiteLogo = UIColor.white
        static let blackBorder = UIColor.black
        static let whiteBorder = UIColor.white
    }
    
    init(style: LogoStyle = .black) {
        self.logoStyle = style
    }
}

class LogoLoadingView: RxBasicLoadingView {
    
    fileprivate var logoView: UIView!
    fileprivate var logoShapeLayer: CAShapeLayer!
    fileprivate var borderView: UIView!
    fileprivate var borderShapeLayer: CAShapeLayer!
    fileprivate var timeSpeed: Int = 2
    fileprivate var timeCurrentStep: Int = 0
    fileprivate var style: LogoLoadingStyle = LogoLoadingStyle()
    var loadingHeight: CGFloat = 60
    
    init(style: LogoLoadingStyle = LogoLoadingStyle()) {
        self.style = style
        super.init(frame: CGRect(origin: .zero, size: LogoLoadingStyle.commonSize))
    }
    
    required init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func setupSubviews() {
        self.backgroundColor = style.backgroundColor
        self.layer.cornerRadius = self.frame.size.width * 0.5
        self.clipsToBounds = true
        
        setupLogoShapeLayer()
        
        setupBorderShapeLayer()
    }
    
    override func startAnimating() {
        self.isHidden = false
        timeCurrentStep = 0
        borderShapeLayer.strokeEnd = 1
        logoShapeLayer.strokeEnd = 1
    }
    
    override func stopAnimating() {
        self.isHidden = true
    }
    
    override func updateProgress(_ progress: CGFloat) {
        self.isHidden = false
        if isAnimated {
            updateLoadingAnimation()
        } else {
            updateScrollProgress(progress)
        }
        
    }
}

// MARK: - 子控件初始化
extension LogoLoadingView {
    
    fileprivate func setupLogoShapeLayer() {
        
        logoView = createLayerView(size: style.logoSize)
        logoShapeLayer = CAShapeLayer()
        logoShapeLayer.frame = CGRect(origin: .zero, size: style.logoSize)
        logoShapeLayer.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        logoShapeLayer.position = CGPoint(x: logoView.frame.size.width * 0.5, y: logoView.frame.size.height * 0.5)
        logoShapeLayer.fillColor = UIColor.clear.cgColor
        logoShapeLayer.strokeColor = UIColor.white.cgColor
        logoShapeLayer.lineWidth = 1.5
        logoShapeLayer.strokeStart = 0
        logoShapeLayer.strokeEnd = 1.0
        updateLayerPath(logoShapeLayer, points: style.logoNormalPoints)
        logoView.layer.mask = logoShapeLayer
        self.addSubview(logoView)
    }
    
    fileprivate func setupBorderShapeLayer() {
        borderView = createLayerView(size: style.loadingSize, isBorder: true)
        borderShapeLayer = CAShapeLayer()
        borderShapeLayer.frame = CGRect(origin: .zero, size: style.loadingSize)
        borderShapeLayer.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        borderShapeLayer.position = CGPoint(x: borderView.frame.size.width / 2, y: borderView.frame.size.height / 2)
        borderShapeLayer.fillColor = UIColor.clear.cgColor
        borderShapeLayer.strokeColor = UIColor.white.cgColor
        borderShapeLayer.lineWidth = 1.5
        borderShapeLayer.strokeStart = 0
        borderShapeLayer.strokeEnd = 1.0
        updateLayerPath(borderShapeLayer, points: style.borderNormalPoints)
        
        borderView.layer.mask = borderShapeLayer
        self.addSubview(borderView)
    }
    
    fileprivate func createLayerView(size: CGSize, isBorder: Bool = false) -> UIView {
        let layerView = UIView()
        layerView.frame.size = CGSize(width: size.width + 2, height: size.height + 2)
        layerView.frame.origin.x = (self.frame.size.width - layerView.frame.size.width) * 0.5
        layerView.frame.origin.y = (self.frame.size.height - layerView.frame.size.height) * 0.5
        layerView.backgroundColor = UIColor.clear
        
        switch style.logoStyle {
        case .white:
            layerView.backgroundColor = isBorder ? LogoLoadingStyle.Color.whiteBorder : LogoLoadingStyle.Color.whiteLogo
        default:
            layerView.backgroundColor = isBorder ? LogoLoadingStyle.Color.blackBorder : LogoLoadingStyle.Color.blackLogo
        }
        return layerView
    }
    
    /// 图层的路径更新
    fileprivate func updateLayerPath(_ layer: CAShapeLayer, points: [CGPoint], isStroke: Bool = true) {
        let path = UIBezierPath()
        for (index, point) in points.enumerated() {
            if index == 0 {
                path.move(to: point)
            } else {
                path.addLine(to: point)
            }
        }
        if isStroke {
            if let firstPoint = points.first {
                path.addLine(to: firstPoint)
            }
        }
        layer.path = path.cgPath
    }
}

// MARK: - 动作响应
extension LogoLoadingView {
    
    struct LogoPointState {
        enum LogoPointDirection {
            case left, top, right, bottom
        }
        var point: CGPoint = .zero
        var direction: LogoPointDirection = .left
    }
    
    /// 加载中的动画
    fileprivate func updateLoadingAnimation() {
        let maxStep: Int = Int(style.logoWidth * 2 + style.logoSize.height * 2)
        
        // 头节点
        let startStep = (timeCurrentStep + timeSpeed) % maxStep
        let startState = getLogoPointState(startStep)
        
        // 尾节点
        let endStep = (startStep + maxStep - style.gapWidth) % maxStep
        let endState = getLogoPointState(endStep)
        
        // 中间折线
        var points: [CGPoint] = []
        switch startState.direction {
        case .top:
            points = [style.logoPointRightTop, style.logoPointRightBottom, style.logoPointLeftBottom, style.logoPointLeftTop]
        case .right:
            points = [style.logoPointRightBottom, style.logoPointLeftBottom, style.logoPointLeftTop, style.logoPointRightTop]
        case .bottom:
            points = [style.logoPointLeftBottom, style.logoPointLeftTop, style.logoPointRightTop, style.logoPointRightBottom]
        case .left:
            points = [style.logoPointLeftTop, style.logoPointRightTop, style.logoPointRightBottom, style.logoPointLeftBottom]
        }
        // 如果缺口刚好在角落，去掉角落的折线点
        if endState.direction != startState.direction {
            _ = points.popLast()
        }
        points.insert(startState.point, at: 0)
        points.append(endState.point)
        
        timeCurrentStep = startStep
        
        borderShapeLayer.opacity = style.opacity
        updateLayerPath(logoShapeLayer, points: points, isStroke: false)
    }
    
    /// 获取某个进度点的位置和所在方位
    fileprivate func getLogoPointState(_ step: Int) -> LogoPointState {
        let logoSizeWidth: CGFloat = style.logoSize.width
        let logoSizeHeight: CGFloat = style.logoSize.height
        var state: LogoPointState = LogoPointState()
        var stepPoint: CGPoint = .zero
        let ratio: CGFloat = (logoSizeWidth - style.logoWidth) / logoSizeHeight
        switch CGFloat(step) {
        case let value where value >= 0 && value < style.logoWidth:
            let increaseValue = value
            stepPoint.x = logoSizeWidth - increaseValue
            stepPoint.y = logoSizeHeight
            state.direction = .bottom
        case let value where value >= style.logoWidth && value < style.logoWidth + logoSizeHeight:
            let increaseValue = value - style.logoWidth
            stepPoint.x = logoSizeWidth - style.logoWidth - ratio * increaseValue
            stepPoint.y = logoSizeHeight - increaseValue
            state.direction = .left
        case let value where value >= style.logoWidth + logoSizeHeight && value < style.logoWidth * 2 + logoSizeHeight:
            let increaseValue = value - style.logoWidth - logoSizeHeight
            stepPoint.x = increaseValue
            stepPoint.y = 0
            state.direction = .top
        case let value where value >= style.logoWidth * 2 + logoSizeHeight && value <= style.logoWidth * 2 + logoSizeHeight * 2:
            let increaseValue = value - style.logoWidth * 2 - logoSizeHeight
            stepPoint.x = style.logoWidth + ratio * increaseValue
            stepPoint.y = increaseValue
            state.direction = .right
        default:
            return state
        }
        stepPoint.x = max(0, min(stepPoint.x, logoSizeWidth))
        stepPoint.y = max(0, min(stepPoint.y, logoSizeHeight))
        state.point = stepPoint
        return state
    }
    
    /// 滑动时进度条动画
    fileprivate func updateScrollProgress(_ progress: CGFloat) {
        
        let borderMinProgress: CGFloat = (loadingHeight - style.loadingSize.height) * 0.5 / loadingHeight
        let borderMaxProgress: CGFloat = 1.0 - borderMinProgress
        
        if progress <= borderMinProgress { // 准备显示
            CATransaction.begin()
            CATransaction.setDisableActions(true)
            borderShapeLayer.strokeEnd = 0
            logoShapeLayer.strokeEnd = 0
            CATransaction.commit()
        } else if progress <= borderMaxProgress { // 外框左下部分
            borderShapeLayer.opacity = 1.0
            let endValue: CGFloat = (progress - borderMinProgress) / (borderMaxProgress - borderMinProgress)
            borderShapeLayer.strokeEnd = endValue * 0.5
            logoShapeLayer.strokeEnd = 0
        } else { // 外框右上和logo
            let loadingLength: CGFloat = style.loadingSize.width + style.loadingSize.height
            let logoLength: CGFloat = (style.logoWidth + style.logoSize.height) * 2
            let totalLength: CGFloat = loadingLength + logoLength
            
            let endValue: CGFloat = (progress - borderMaxProgress) / (1 - borderMaxProgress)
            let currentLength: CGFloat = totalLength * endValue
            if currentLength < loadingLength {
                borderShapeLayer.opacity = 1.0
                borderShapeLayer.strokeEnd = 0.5 + currentLength / loadingLength
                logoShapeLayer.strokeEnd = 0
            } else {
                borderShapeLayer.opacity = style.opacity
                updateLayerPath(logoShapeLayer, points: style.logoNormalPoints)
                borderShapeLayer.strokeEnd = 1
                logoShapeLayer.strokeEnd = (currentLength - loadingLength) / logoLength
            }
        }
    }
}
