//
//  CardTransitionDelegate.swift
//  ifanr
//
//  Created by luhe liu on 2017/11/16.
//  Copyright © 2017年 ifanr. All rights reserved.
//
import UIKit

class CardTransitionDelegate: NSObject, UIViewControllerTransitioningDelegate, UIViewControllerAnimatedTransitioning {
    
    // 自定义属性，判断是 present 还是 dismiss
    fileprivate var isPresent: Bool = true
    fileprivate weak var maskBackgroundView: UIView?
    fileprivate weak var source: UIViewController?
    fileprivate weak var presented: UIViewController?
    // 动画卡片距离顶部的距离
    fileprivate var topForShow: CGFloat = 40

    init(topForShow: CGFloat) {
        super.init()
        self.topForShow = topForShow
    }
    
    /// 代理方法，返回处理 present 转场动画的对象
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        // presented - 被弹出控制器，presenting - 根控制器(Navigation/Tab/View)，source - 源控制器
        // 因为使用了 overFullScreen，source 不会调用 viewWillDisappear 和 viewDidDisappear，这里手动触发
        source.viewWillDisappear(false)
        source.viewDidDisappear(false)
        self.source = source
        self.presented = presented
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
            return 0.45
        }
    }
    
    /// 代理方法，处理 present 或者 dismiss 的转场，这里分离出 2 个子方法分别处理 present 和 dismiss
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
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
        
        // 灰色背景控件
        let maskBackgroundView = UIView(frame: containerView.bounds)
        maskBackgroundView.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.5)
        maskBackgroundView.alpha = 0.0
        maskBackgroundView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(CardTransitionDelegate.clickMaskViewAction(_:))))
        self.maskBackgroundView = maskBackgroundView
        fromView.addSubview(maskBackgroundView)
        containerView.addSubview(toView)
        
        // 动画开始，底层控制器往后缩小，灰色背景渐变出现，顶层控制器从下往上出现
        let tranformScale = (UIScreen.main.bounds.height - self.topForShow) / UIScreen.main.bounds.height
        let tranform = CGAffineTransform(scaleX: tranformScale, y: tranformScale)
        toView.frame.origin.y = UIScreen.main.bounds.height
        UIView.animate(withDuration: duration, delay: 0, options: .curveEaseOut, animations: {
            toView.frame.origin.y = self.topForShow
            maskBackgroundView.alpha = 1.0
            fromView.transform = tranform
        }, completion: { (_) in
            transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
        })
        
    }
    
    /// 自定义方法，处理 dismiss 转场
    fileprivate func animateTransitionForDismiss(using transitionContext: UIViewControllerContextTransitioning) {
        guard let fromViewController = transitionContext.viewController(forKey: .from) else { return }
        guard let toViewController = transitionContext.viewController(forKey: .to) else { return }
        guard let fromView = fromViewController.view, let toView = toViewController.view else { return }
        
        let duration = self.transitionDuration(using: transitionContext)

        // 动画还原
        UIView.animate(withDuration: duration, delay: 0, options: .curveEaseOut, animations: {
            fromView.frame.origin.y = UIScreen.main.bounds.height
            self.maskBackgroundView?.alpha = 0.0
            toView.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
        }, completion: { (_) in
            self.maskBackgroundView?.removeFromSuperview()
            // 注意！：因为外面使用了 overFullScreen ，dismiss 会丢失视图，需要自己手动加上
            UIApplication.shared.keyWindow?.insertSubview(toView, at: 0)
            // 因为使用了 overFullScreen，导致 source 没法正常调用 viewWillAppear 和 viewDidAppear，这里手动触发
            if let source = self.source {
                source.viewWillAppear(false)
                source.viewDidAppear(false)
            }
            transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
        })
    }
    
    /// 点击灰色背景事件处理
    func clickMaskViewAction(_ gestureRecognizer: UITapGestureRecognizer) {
        self.presented?.dismiss(animated: true, completion: nil)
    }
}
