//
//  ViewController.swift
//  TransitionDemo
//
//  Created by luhe liu on 2018/4/8.
//  Copyright © 2018年 com.ifanr. All rights reserved.
//

import UIKit

let screenBounds = UIScreen.main.bounds
let screenWidth = ceil(UIScreen.main.bounds.size.width)
let screenHeight = ceil(UIScreen.main.bounds.size.height)

class ViewController: UIViewController {
    
    // 自定义的转场代理
    fileprivate var alphaTransitionDelegate = AlphaTransitionDelegate()
    fileprivate var cardTransitionDelegate = CardTransitionDelegate(topForShow: 40)
    fileprivate var rippleTransitionDelegate = RippleTransitionDelegate()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupSubviews()
    }

    fileprivate func setupSubviews() {
        
        let buttonSize = CGSize(width: 200, height: 50)
        let buttonPadding: CGFloat = 30
        // AlphaTransition Button
        var buttonFrame = CGRect(x: (screenWidth - buttonSize.width) * 0.5,
                                 y: buttonPadding,
                                 width: buttonSize.width,
                                 height: buttonSize.height)
        addAlphaTransitionButton(frame: buttonFrame)
        
        // CardTransition Button
        buttonFrame.origin.y += buttonSize.height + buttonPadding
        addCardTransitionButton(frame: buttonFrame)
        
        // RippleTransition Button
        buttonFrame.origin.y += buttonSize.height + buttonPadding
        addRippleTransitionButton(frame: buttonFrame)
        rippleTransitionDelegate.startOrigin = buttonFrame.origin
    }
}

// MARK: - AlphaTransition
extension ViewController {
    
    fileprivate func addAlphaTransitionButton(frame: CGRect) {
        let button = UIButton(type: .custom)
        button.frame = frame
        button.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        button.setTitleColor(UIColor.red, for: .normal)
        button.setTitle("Present AlphaTransition", for: .normal)
        button.backgroundColor = UIColor.darkGray
        button.addTarget(self, action: #selector(ViewController.presentToAlphaTransitionViewControler), for: .touchUpInside)
        self.view.addSubview(button)
    }
    
    func presentToAlphaTransitionViewControler() {
        
        let alphaVc = AlphaTransitionViewController()
        alphaVc.transitioningDelegate = alphaTransitionDelegate
        self.transitioningDelegate = alphaTransitionDelegate
        self.present(alphaVc, animated: true, completion: nil)
    }
}

// MARK: - CardTransition
extension ViewController {
    
    fileprivate func addCardTransitionButton(frame: CGRect) {
        let button = UIButton(type: .custom)
        button.frame = frame
        button.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        button.setTitleColor(UIColor.red, for: .normal)
        button.setTitle("Present CardTransition", for: .normal)
        button.backgroundColor = UIColor.darkGray
        button.addTarget(self, action: #selector(ViewController.presentToCardTransitionViewControler), for: .touchUpInside)
        self.view.addSubview(button)
    }
    
    func presentToCardTransitionViewControler() {
        
        let cardVc = CardTransitionViewController()
        // 注意!：卡片转场因为可以看到后面的控制器，需要设置为 overFullScreen 转场类型
        cardVc.modalPresentationStyle = .overFullScreen
        cardVc.transitioningDelegate = cardTransitionDelegate
        self.transitioningDelegate = cardTransitionDelegate
        self.present(cardVc, animated: true, completion: nil)
    }
}

// MARK: - RippleTransition
extension ViewController {
    
    fileprivate func addRippleTransitionButton(frame: CGRect) {
        let button = UIButton(type: .custom)
        button.frame = frame
        button.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        button.setTitleColor(UIColor.red, for: .normal)
        button.setTitle("Present RippleTransition", for: .normal)
        button.backgroundColor = UIColor.darkGray
        button.addTarget(self, action: #selector(ViewController.presentToRippleTransitionViewControler), for: .touchUpInside)
        self.view.addSubview(button)
    }
    
    func presentToRippleTransitionViewControler() {
        
        let rippleVc = RippleTransitionViewController()
        rippleVc.transitioningDelegate = rippleTransitionDelegate
        self.transitioningDelegate = rippleTransitionDelegate
        self.present(rippleVc, animated: true, completion: nil)
    }
}

