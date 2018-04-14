//
//  ArticleFigureTransitionDelegate.swift
//  ifanr
//
//  Created by 陈恩湖 on 2017/1/16.
//  Copyright © 2017年 ifanr. All rights reserved.
//

import UIKit

// MARK: - AlphaTransitionDelegate: UIViewControllerAnimatedTransitioning
class AlphaTransitionDelegate: NSObject, UIViewControllerAnimatedTransitioning {

    // 自定义属性，判断是出现还是消失
    fileprivate var isAppear: Bool = true
    
    /// UIViewControllerTransitioningDelegate 代理方法，返回转场动画时间
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        if self.isAppear {
            return 0.45
        } else {
            return 0.40
        }
    }
    
    /// UIViewControllerTransitioningDelegate 代理方法，处理转场执行动画
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        if self.isAppear {
            animateTransitionForAppear(using: transitionContext)
        } else {
            animateTransitionForDisappear(using: transitionContext)
        }
    }
    
    /// 自定义方法，处理出现的转场动画
    fileprivate func animateTransitionForAppear(using transitionContext: UIViewControllerContextTransitioning) {
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
    
    /// 自定义方法，处理消失的转场动画
    fileprivate func animateTransitionForDisappear(using transitionContext: UIViewControllerContextTransitioning) {
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

// MARK: - UITabBarControllerDelegate 分页转场代理
extension AlphaTransitionDelegate: UITabBarControllerDelegate {
    
    /// 返回处理 tabs 转场动画的对象
    func tabBarController(_ tabBarController: UITabBarController, animationControllerForTransitionFrom fromVC: UIViewController, to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        isAppear = true
        return self
    }
}

// MARK: - UINavigationControllerDelegate 导航转场代理
extension AlphaTransitionDelegate: UINavigationControllerDelegate {
    
    /// 返回处理 push/pop 转场动画的对象
    func navigationController(_ navigationController: UINavigationController, animationControllerFor operation: UINavigationControllerOperation, from fromVC: UIViewController, to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        switch operation {
        case .push:
            isAppear = true
        case .pop:
            isAppear = false
        default:
            return nil
        }
        return self
    }
}

// MARK: - UIViewControllerTransitioningDelegate 弹出转场代理
extension AlphaTransitionDelegate: UIViewControllerTransitioningDelegate {
    
    /// 返回处理 present 转场动画的对象
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        // presented 被弹出的控制器，presenting 根控制器，source 源控制器
        self.isAppear = true
        return self
    }
    
    /// 返回处理 dismiss 转场动画的对象
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        self.isAppear = false
        return self
    }
}

