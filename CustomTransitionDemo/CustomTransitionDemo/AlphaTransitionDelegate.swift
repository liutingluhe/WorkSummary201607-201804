//
//  ArticleFigureTransitionDelegate.swift
//  ifanr
//
//  Created by 陈恩湖 on 2017/1/16.
//  Copyright © 2017年 ifanr. All rights reserved.
//

import UIKit

class AlphaTransitionDelegate: NSObject, UIViewControllerTransitioningDelegate, UIViewControllerAnimatedTransitioning {

    // 自定义属性，判断是 present 还是 dismiss
    fileprivate var isPresent: Bool = true

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
        
        // 渐变动画
        toView.alpha = 0
        UIView.animate(withDuration: duration, delay: 0, options: .curveEaseOut, animations: {
            toView.alpha = 1.0
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
        let containerView = transitionContext.containerView
        containerView.insertSubview(toView, at: 0)

        // 渐变动画
        fromView.alpha = 1.0
        UIView.animate(withDuration: duration, delay: 0, options: .curveEaseOut, animations: {
            fromView.alpha = 0
        }, completion: { (_) in
            fromView.removeFromSuperview()
            transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
        })
        
    }
}

