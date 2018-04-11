//
//  ViewController.swift
//  ScreenAdapterDemo
//
//  Created by luhe liu on 2018/4/11.
//  Copyright © 2018年 com.liuting. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    fileprivate var showButton: UIButton!
    fileprivate var titleLabel: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupSubviews()
    }
    
    fileprivate func setupSubviews() {
        showButton = UIButton(type: .system)
        showButton.frame = self.view.bounds
        showButton.setTitleColor(UIColor.red, for: .normal)
        showButton.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        showButton.setTitle("Change ScreenSpecs", for: .normal)
        showButton.sizeToFit()
        showButton.center.x = self.view.center.x
        showButton.center.y = self.view.center.y + 50
        showButton.addTarget(self, action: #selector(ViewController.changeScreenSpecs), for: .touchUpInside)
        self.view.addSubview(showButton)
        
        titleLabel = UILabel(frame: self.view.bounds)
        titleLabel.textColor = UIColor.blue
        titleLabel.numberOfLines = 0
        titleLabel.textAlignment = .center
        self.view.addSubview(titleLabel)
        
        updateSubviews()
    }
    
    fileprivate func updateSubviews() {
        let fontSize: CGFloat = AdaptType<CGFloat>.iPhoneVertical(
            inch35: 13, inch40: 15, inch47: 17, inch55: 19, inch58: 21
        ).value
        titleLabel.bounds = self.view.bounds
        titleLabel.font = UIFont.systemFont(ofSize: fontSize)
        titleLabel.text = "Title label \n-\n\(ScreenAdapter.shared.screenSpecs)"
        titleLabel.sizeToFit()
        
        let padding: CGFloat = AdaptType<CGFloat>.iPhoneVertical(
            inch35: 20, inch40: 30, inch47: 40, inch55: 50, inch58: 60
        ).value
        titleLabel.center.x = self.view.center.x
        titleLabel.center.y = self.view.center.y - padding
    }
    
    // 这里为了测试不同屏幕显示情况，手动修改屏幕规格，并刷新视图
    func changeScreenSpecs() {
        
        switch ScreenAdapter.shared.screenSpecs {
        case .iPhone(.inch35):
            ScreenAdapter.shared.screenSpecs = .iPhone(.inch40)
        case .iPhone(.inch40):
            ScreenAdapter.shared.screenSpecs = .iPhone(.inch47)
        case .iPhone(.inch47):
            ScreenAdapter.shared.screenSpecs = .iPhone(.inch55)
        case .iPhone(.inch55):
            ScreenAdapter.shared.screenSpecs = .iPhone(.inch58)
        case .iPhone(.inch58):
            ScreenAdapter.shared.screenSpecs = .iPhone(.inch35)
        default:
            break
        }
        
        updateSubviews()
    }

}

