//
//  HeaderView.swift
//  CommonExtensionDemo
//
//  Created by luhe liu on 2018/3/25.
//  Copyright © 2018年 luhe liu. All rights reserved.
//

import UIKit

class HeaderView: UIView {
    
    fileprivate var view: UIView!

    override init(frame: CGRect) {
        super.init(frame: frame)
        xibSetup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        xibSetup()
    }

    fileprivate func xibSetup() {
        // MARK: 测试从 xib 加载视图
        view = loadViewFromNib()
        view.frame = bounds
        view.autoresizingMask = [UIViewAutoresizing.flexibleWidth, UIViewAutoresizing.flexibleHeight]
        addSubview(view)
        self.backgroundColor = UIColor.clear
    }
    
    func printResponderController() {
        // MARK: 测试当前视图所在的控制器
        print("headerView printResponder \(String(describing: self.responderController))")
    }
}
