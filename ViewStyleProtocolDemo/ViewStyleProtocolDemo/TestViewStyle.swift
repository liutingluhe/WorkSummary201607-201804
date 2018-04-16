//
//  TestViewStyle.swift
//  ViewStyleProtocolDemo
//
//  Created by luhe liu on 2018/4/12.
//  Copyright © 2018年 luhe liu. All rights reserved.
//

import UIKit
import SnapKit

/// 样式配置基类，通过策略设计模式实现
class TestViewStyle {
    lazy var nameLabel = LabelConfiguration()
    lazy var introLabel = LabelConfiguration()
    lazy var subscribeButton = ButtonConfiguration()
    lazy var imageView = ImageConfiguration()
}

/// 样式一
class TestViewStyle1: TestViewStyle {
    
    override init() {
        super.init()
        // 样式
        nameLabel.padding.left = 10
        nameLabel.padding.right = -14
        nameLabel.textColor = UIColor.black
        nameLabel.font = UIFont.systemFont(ofSize: 15)
        
        introLabel.lineSpacing = 10
        introLabel.padding.top = 10
        introLabel.numberOfLines = 0
        introLabel.textColor = UIColor.gray
        introLabel.font = UIFont.systemFont(ofSize: 13)
        introLabel.lineBreakMode = .byCharWrapping
        
        subscribeButton.padding.top = 10
        subscribeButton.size.height = 30
        subscribeButton.image.normal = UIImage(named: "subscribe")
        subscribeButton.image.selected = UIImage(named: "subscribed")
        subscribeButton.title.normal = "订阅"
        subscribeButton.title.selected = "已订"
        subscribeButton.titleColor.normal = UIColor.black
        subscribeButton.titleColor.selected = UIColor.yellow
        subscribeButton.titleFont = UIFont.systemFont(ofSize: 12)
        
        imageView.padding.left = 14
        imageView.padding.top = 20
        imageView.size.width = 60
        imageView.contentMode = .scaleAspectFill
        imageView.borderColor = UIColor.red
        imageView.borderWidth = 3
        imageView.cornerRadius = imageView.size.width * 0.5
        imageView.clipsToBounds = true
    }
}

/// 样式二
class TestViewStyle2: TestViewStyle {
    
    override init() {
        super.init()
        // 样式
        nameLabel.padding = UIEdgeInsets(top: 10, left: 14, bottom: 0, right: -14)
        nameLabel.textColor = UIColor.red
        nameLabel.font = UIFont.systemFont(ofSize: 17)
        
        introLabel.padding.top = 10
        introLabel.numberOfLines = 0
        introLabel.textColor = UIColor.purple
        introLabel.font = UIFont.systemFont(ofSize: 15)
        introLabel.lineBreakMode = .byCharWrapping
        introLabel.lineSpacing = 4
        
        subscribeButton.padding.top = 10
        subscribeButton.size.height = 30
        subscribeButton.image.normal = UIImage(named: "subscribe")
        subscribeButton.image.selected = UIImage(named: "subscribed")
        subscribeButton.title.normal = "订阅"
        subscribeButton.title.selected = "已订"
        subscribeButton.titleColor.normal = UIColor.black
        subscribeButton.titleColor.selected = UIColor.yellow
        subscribeButton.titleFont = UIFont.systemFont(ofSize: 12)
        
        imageView.padding.top = 20
        imageView.size.width = 60
        imageView.contentMode = .scaleAspectFill
        imageView.borderColor = UIColor.red
        imageView.borderWidth = 3
        imageView.clipsToBounds = true
        imageView.cornerRadius = imageView.size.width * 0.5

    }
}

/// 样式三
class TestViewStyle3: TestViewStyle {
    
    override init() {
        super.init()
        // 样式
        nameLabel.padding.top = 10
        nameLabel.padding.right = -30
        nameLabel.textColor = UIColor.black
        nameLabel.font = UIFont.systemFont(ofSize: 15)
        
        introLabel.padding.top = 10
        introLabel.numberOfLines = 0
        introLabel.textColor = UIColor.gray
        introLabel.font = UIFont.systemFont(ofSize: 13)
        introLabel.lineBreakMode = .byCharWrapping
        introLabel.lineSpacing = 10
        
        subscribeButton.size.height = 30
        subscribeButton.padding.left = 20
        subscribeButton.image.normal = nil
        subscribeButton.image.selected = nil
        subscribeButton.title.normal = "点赞"
        subscribeButton.title.selected = "已赞"
        subscribeButton.titleColor.normal = UIColor.green
        subscribeButton.titleColor.selected = UIColor.blue
        subscribeButton.titleFont = UIFont.systemFont(ofSize: 13)
        
        imageView.padding.left = -nameLabel.padding.right
        imageView.padding.top = 10
        imageView.size.width = 60
        imageView.contentMode = .scaleAspectFill
        imageView.borderColor = UIColor.blue
        imageView.borderWidth = 1
        imageView.clipsToBounds = false
    }
}
