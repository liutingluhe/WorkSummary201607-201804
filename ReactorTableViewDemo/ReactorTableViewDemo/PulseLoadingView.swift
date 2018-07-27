//
//  PulseLoadingView.swift
//  ReactorCollectionViewDemo
//
//  Created by luhe liu on 2018/6/25.
//  Copyright © 2018年 luhe liu. All rights reserved.
//

import UIKit

struct PulseLoadingStyle {
    var maxHeight: CGFloat = 25.0
    var lineColor: UIColor = UIColor.black
    var lineHeightRatios: [CGFloat] = [0.7, 0.8, 0.9, 1.0, 0.9, 0.8, 0.7]
    var beginTimeOffsets: [Double] = [-0.6, -0.4, -0.2, 0, -0.2, -0.4, -0.6]
    var duration: Double = 0.8
    let animationKeyTimes: [NSNumber] = [0, 0.5, 1]
    let animationValues: [Double] = [1.0, 0.4, 1]
    let timingFunctionPoints: [Float] = [0.85, 0.25, 0.37, 0.85]
    var lineWidth: CGFloat = 1.5
    var lineCount: Int = 7
    var lineSpace: CGFloat = 4.0
    
    lazy var lineHeights: [CGFloat] = {
        let middleHeight = self.maxHeight
        var heights = [CGFloat]()
        let ratios: [CGFloat] = self.lineHeightRatios
        
        ratios.forEach { ratio in
            heights.append(middleHeight * ratio)
        }
        return heights
    }()
    
    init() { }
}

class PulseLoadingView: RxBasicLoadingView {

    fileprivate var lineShapeLayers = [CAShapeLayer]()
    
    fileprivate lazy var animation: CAKeyframeAnimation = {
        let duration: CFTimeInterval = self.style.duration
        let points = self.style.timingFunctionPoints
        let timingFunction = CAMediaTimingFunction(controlPoints: points[0], points[1], points[2], points[3])
        let animation = CAKeyframeAnimation(keyPath: "transform.scale.y")
        animation.keyTimes = self.style.animationKeyTimes
        animation.timingFunctions = [timingFunction, timingFunction]
        animation.values = self.style.animationValues
        animation.duration = duration
        animation.repeatCount = Float.greatestFiniteMagnitude
        animation.isRemovedOnCompletion = false
        return animation
    }()
    
    var style: PulseLoadingStyle = PulseLoadingStyle()
    
    init(frame: CGRect, style: PulseLoadingStyle = PulseLoadingStyle()) {
        self.style = style
        super.init(frame: frame)
    }
    
    required init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    deinit {
        stopAnimating()
    }
    
    override func setupSubviews() {
        
        self.layer.sublayers = nil
        setupLineLayers()
    }
    
    fileprivate func setupLineLayers() {
        
        let lineWidth: CGFloat = self.style.lineWidth
        let lineCount: Int = self.style.lineCount
        let lineSpace: CGFloat = self.style.lineSpace
        let totalWidth: CGFloat = (lineWidth + lineSpace) * CGFloat(lineCount) - lineSpace
        
        var x: CGFloat = (self.bounds.size.width - totalWidth) / 2
        
        for index in 0..<lineCount {
            
            let lineLayer = CAShapeLayer()
            let roundedRect = CGRect(x: 0, y: 0, width: lineWidth, height: self.style.lineHeights[index])
            let path = UIBezierPath(roundedRect: roundedRect, cornerRadius: lineWidth / 2)
            lineLayer.fillColor = self.style.lineColor.cgColor
            lineLayer.backgroundColor = nil
            lineLayer.path = path.cgPath
            
            let y = ceil((self.bounds.size.height - self.style.lineHeights[index]) / 2)
            
            let frame = CGRect(x: x, y: y, width: lineWidth, height: self.style.maxHeight)
            
            x += lineWidth + lineSpace
            
            lineLayer.frame = frame
            self.layer.addSublayer(lineLayer)
            lineShapeLayers.append(lineLayer)
        }
    }
    
    override func startAnimating() {
        for (index, lineLayer) in lineShapeLayers.enumerated() {
            animation.beginTime = CACurrentMediaTime() + self.style.beginTimeOffsets[index]
            lineLayer.add(animation, forKey: "animation")
            lineLayer.isHidden = false
        }
    }
    
    override func stopAnimating() {
        lineShapeLayers.forEach {
            $0.removeAllAnimations()
            $0.isHidden = true
        }
    }
}
