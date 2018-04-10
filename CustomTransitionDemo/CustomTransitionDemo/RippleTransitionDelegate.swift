//
//  ShrinkTransitionDelegate.swift
//  ifanr
//
//  Created by luhe liu on 2017/11/20.
//  Copyright © 2017年 ifanr. All rights reserved.
//
import UIKit

class RippleTransitionDelegate: NSObject, UIViewControllerTransitioningDelegate, UIViewControllerAnimatedTransitioning {
    
    // 自定义属性，判断是 present 还是 dismiss
    fileprivate var isPresent: Bool = true
    fileprivate weak var transitionContext: UIViewControllerContextTransitioning?
    // 起始点坐标
    var startOrigin: CGPoint = CGPoint.zero
    // 扩散半径
    fileprivate var radius: CGFloat = 0
    
    init(startOrigin: CGPoint = .zero) {
        super.init()
        self.startOrigin = startOrigin
        
        // 这里取扩散最大半径，即屏幕的对角线长
        let screenWidth = ceil(UIScreen.main.bounds.size.width)
        let screenHeight = ceil(UIScreen.main.bounds.size.height)
        self.radius = sqrt((screenWidth * screenWidth) + (screenHeight * screenHeight))
    }
    
    /// 代理方法，返回处理 present 转场动画的对象
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        self.isPresent = true
        return self
    }
    
    /// 代理方法，返回处理 dismiss 转场动画的对象
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        self.isPresent = false
        return self
    }
    
    /// 代理方法，返回 present 或者 dismiss 的转场时间
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        if self.isPresent { // present
            return 0.45
        } else { // dismiss
            return 0.40
        }
    }
    
    /// 代理方法，处理 present 或者 dismiss 的转场，这里分离出 2 个子方法分别处理 present 和 dismiss
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        self.transitionContext = transitionContext
        if self.isPresent { // present
            animateTransitionForPresent(using: transitionContext)
        } else { // dismiss
            animateTransitionForDismiss(using: transitionContext)
        }
    }
    
    /// 自定义方法，处理 present 转场
    fileprivate func animateTransitionForPresent(using transitionContext: UIViewControllerContextTransitioning) {
        guard let fromViewController = transitionContext.viewController(forKey: .from) else { return }
        guard let toViewController = transitionContext.viewController(forKey: .to) else { return }
        guard let fromView = fromViewController.view, let toView = toViewController.view else { return }
        
        let duration = self.transitionDuration(using: transitionContext)
        let containerView = transitionContext.containerView
        containerView.addSubview(fromView)
        containerView.addSubview(toView)
        
        // 计算动画图层开始和结束路径
        let startFrame = CGRect(origin: self.startOrigin, size: .zero)
        let maskStartPath = UIBezierPath(ovalIn: startFrame)
        let maskEndPath = UIBezierPath(ovalIn: startFrame.insetBy(dx: -self.radius, dy: -self.radius))
        
        // 创建动画图层， layer.mask 属性是表示显示的范围
        let maskLayer = CAShapeLayer()
        maskLayer.path = maskEndPath.cgPath
        toView.layer.mask = maskLayer
        
        // 为动画图层添加路径，从一个点开始扩散到整屏
        let maskLayerAnimation = CABasicAnimation(keyPath: "path")
        maskLayerAnimation.fromValue = maskStartPath.cgPath
        maskLayerAnimation.toValue = maskEndPath.cgPath
        maskLayerAnimation.duration = duration
        maskLayerAnimation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        maskLayerAnimation.delegate = self
        maskLayer.add(maskLayerAnimation, forKey: "ripple_push_animation")
        
    }
    
    /// 自定义方法，处理 dismiss 转场
    fileprivate func animateTransitionForDismiss(using transitionContext: UIViewControllerContextTransitioning) {
        guard let fromViewController = transitionContext.viewController(forKey: .from) else { return }
        guard let toViewController = transitionContext.viewController(forKey: .to) else { return }
        guard let fromView = fromViewController.view, let toView = toViewController.view else { return }
        
        let duration = self.transitionDuration(using: transitionContext)
        let containerView = transitionContext.containerView
        containerView.insertSubview(toView, at: 0)
        
        // 计算动画图层开始和结束路径
        let startFrame = CGRect(origin: self.startOrigin, size: .zero)
        let maskStartPath = UIBezierPath(ovalIn: startFrame.insetBy(dx: -self.radius, dy: -self.radius))
        let maskEndPath = UIBezierPath(ovalIn: startFrame)
        
        // 创建动画图层，layer.mask 属性是表示显示的范围
        let maskLayer = CAShapeLayer()
        maskLayer.path = maskEndPath.cgPath
        fromView.layer.mask = maskLayer
        
        // 为动画图层添加路径，从整屏收缩到一个点
        let maskLayerAnimation = CABasicAnimation(keyPath: "path")
        maskLayerAnimation.fromValue = maskStartPath.cgPath
        maskLayerAnimation.toValue = maskEndPath.cgPath
        maskLayerAnimation.duration = duration
        maskLayerAnimation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        maskLayerAnimation.delegate = self
        maskLayer.add(maskLayerAnimation, forKey: "ripple_dimiss_animation")
    }
}

extension RippleTransitionDelegate: CAAnimationDelegate {
    func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        // 把 layer.mask 赋值为 nil，是为了释放动画图层
        if let transitionContext = self.transitionContext {
            if let toViewController = transitionContext.viewController(forKey: .to) {
                toViewController.view.layer.mask = nil
            }
            if let fromViewController = transitionContext.viewController(forKey: .from) {
                fromViewController.view.layer.mask = nil
            }
            transitionContext.completeTransition(true)
        }
    }
}
