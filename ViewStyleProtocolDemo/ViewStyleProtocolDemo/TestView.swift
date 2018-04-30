//
//  TestView.swift
//  ViewStyleProtocolDemo
//
//  Created by luhe liu on 2018/4/12.
//  Copyright © 2018年 luhe liu. All rights reserved.
//

import UIKit
import SnapKit

class TestView: UIView, ViewConfigurable {
    
    fileprivate var nameLabel: UILabel!
    fileprivate var introLabel: UILabel!
    fileprivate var subscribeButton: UIButton!
    fileprivate var imageView: UIImageView!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupSubviews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupSubviews()
    }
    
    fileprivate func setupSubviews() {
        
        nameLabel = UILabel(frame: self.bounds)
        self.addSubview(nameLabel)
        
        introLabel = UILabel(frame: self.bounds)
        self.addSubview(introLabel)
        
        subscribeButton = UIButton(type: .custom)
        subscribeButton.addTarget(self, action: #selector(TestView.buttonAction(_:)), for: .touchUpInside)
        self.addSubview(subscribeButton)
        
        imageView = UIImageView(frame: self.bounds)
        self.addSubview(imageView)
    }
    
    func buttonAction(_ sender: Any) {
        subscribeButton.isSelected = !subscribeButton.isSelected
    }
    
    /// 设置模型数据
    func setModel(_ model: TestModel? = nil) {
        if let model = model { // 有新数据
            nameLabel.text = model.name
            if let intro = model.intro {
                introLabel.attributedText = NSAttributedString(string: intro, attributes: viewStyle?.introLabel.attributes)
            }
            imageView.image = model.avatarImage
            subscribeButton.isSelected = model.didSubscribed
        }
    }
    
    /// 更新视图样式，不要直接调用，通过赋值 self.viewStyle 属性间接调用
    func bind(viewStyle: TestViewStyle) {
        
        /* 对外可配置属性 */
        // 名字
        nameLabel.textColor = viewStyle.nameLabel.textColor
        nameLabel.font = viewStyle.nameLabel.font
        
        // 介绍
        introLabel.numberOfLines = viewStyle.introLabel.numberOfLines
        if let text = introLabel.text {
            introLabel.attributedText = NSAttributedString(string: text, attributes: viewStyle.introLabel.attributes)
        }
        
        // 订阅按钮
        subscribeButton.setTitleColor(viewStyle.subscribeButton.titleColor.normal, for: .normal)
        subscribeButton.setTitleColor(viewStyle.subscribeButton.titleColor.selected, for: .selected)
        subscribeButton.setImage(viewStyle.subscribeButton.image.normal, for: .normal)
        subscribeButton.setImage(viewStyle.subscribeButton.image.selected, for: .selected)
        subscribeButton.setTitle(viewStyle.subscribeButton.title.normal, for: .normal)
        subscribeButton.setTitle(viewStyle.subscribeButton.title.selected, for: .selected)
        subscribeButton.titleLabel?.font = viewStyle.subscribeButton.titleFont
        
        // 头像
        imageView.layer.borderColor = viewStyle.imageView.borderColor.cgColor
        imageView.layer.borderWidth = viewStyle.imageView.borderWidth
        imageView.layer.cornerRadius = viewStyle.imageView.cornerRadius
        imageView.clipsToBounds = viewStyle.imageView.clipsToBounds
        imageView.contentMode = viewStyle.imageView.contentMode
        
        // 更新视图布局
        if let viewStyle1 = viewStyle as? TestViewStyle1 {
            updateLayoutForStyle1(viewStyle1)
        } else if let viewStyle2 = viewStyle as? TestViewStyle2 {
            updateLayoutForStyle2(viewStyle2)
        } else if let viewStyle3 = viewStyle as? TestViewStyle3 {
            updateLayoutForStyle3(viewStyle3)
        }
    }
    
    fileprivate func updateLayoutForStyle1(_ viewStyle: TestViewStyle1) {
        
        imageView.snp.remakeConstraints { (make) in
            make.left.equalTo(self.snp.left).offset(viewStyle.imageView.padding.left)
            make.top.equalTo(self.snp.top).offset(viewStyle.imageView.padding.top)
            make.width.equalTo(viewStyle.imageView.size.width)
            make.height.equalTo(self.imageView.snp.width)
        }
        
        nameLabel.snp.remakeConstraints { (make) in
            make.top.equalTo(self.imageView.snp.top)
            make.left.equalTo(self.imageView.snp.right).offset(viewStyle.nameLabel.padding.left)
            make.right.equalTo(self.snp.right).offset(viewStyle.nameLabel.padding.right)
        }
        
        introLabel.snp.remakeConstraints { (make) in
            make.top.equalTo(self.nameLabel.snp.bottom).offset(viewStyle.introLabel.padding.top)
            make.left.equalTo(self.nameLabel.snp.left)
            make.right.equalTo(self.nameLabel.snp.right)
        }
        
        subscribeButton.snp.remakeConstraints { (make) in
            make.top.equalTo(self.imageView.snp.bottom).offset(viewStyle.subscribeButton.padding.top)
            make.left.equalTo(self.imageView.snp.left)
            make.right.equalTo(self.imageView.snp.right)
            make.height.equalTo(viewStyle.subscribeButton.size.height)
        }
    }
    
    fileprivate func updateLayoutForStyle2(_ viewStyle: TestViewStyle2) {
        imageView.snp.remakeConstraints { (make) in
            make.centerX.equalTo(self.snp.centerX)
            make.top.equalTo(self.snp.top).offset(viewStyle.imageView.padding.top)
            make.width.equalTo(viewStyle.imageView.size.width)
            make.height.equalTo(self.imageView.snp.width)
        }
        
        subscribeButton.snp.remakeConstraints { (make) in
            make.left.equalTo(self.imageView.snp.left)
            make.right.equalTo(self.imageView.snp.right)
            make.centerX.equalTo(self.imageView.snp.centerX)
            make.top.equalTo(self.imageView.snp.bottom).offset(viewStyle.subscribeButton.padding.top)
            make.height.equalTo(viewStyle.subscribeButton.size.height)
        }
        
        nameLabel.snp.remakeConstraints { (make) in
            make.top.equalTo(self.subscribeButton.snp.bottom).offset(viewStyle.nameLabel.padding.top)
            make.left.equalTo(self.snp.left).offset(viewStyle.nameLabel.padding.left)
            make.right.equalTo(self.snp.right).offset(viewStyle.nameLabel.padding.right)
        }
        
        introLabel.snp.remakeConstraints { (make) in
            make.top.equalTo(self.nameLabel.snp.bottom).offset(viewStyle.introLabel.padding.top)
            make.left.equalTo(self.nameLabel.snp.left)
            make.right.equalTo(self.nameLabel.snp.right)
        }
    }
    
    fileprivate func updateLayoutForStyle3(_ viewStyle: TestViewStyle3) {
        imageView.snp.remakeConstraints { (make) in
            make.left.equalTo(self.snp.left).offset(viewStyle.imageView.padding.left)
            make.top.equalTo(self.snp.top).offset(viewStyle.imageView.padding.top)
            make.width.equalTo(viewStyle.imageView.size.width)
            make.height.equalTo(self.imageView.snp.width)
        }
        
        subscribeButton.snp.remakeConstraints { (make) in
            make.left.equalTo(self.imageView.snp.right).offset(viewStyle.subscribeButton.padding.left)
            make.centerY.equalTo(self.imageView.snp.centerY)
            make.width.equalTo(self.imageView.snp.width)
            make.height.equalTo(viewStyle.subscribeButton.size.height)
        }
        
        nameLabel.snp.remakeConstraints { (make) in
            make.left.equalTo(self.imageView.snp.left)
            make.top.equalTo(self.imageView.snp.bottom).offset(viewStyle.nameLabel.padding.top)
            make.right.equalTo(self.snp.right).offset(viewStyle.nameLabel.padding.right)
        }
        
        introLabel.snp.remakeConstraints { (make) in
            make.top.equalTo(self.nameLabel.snp.bottom).offset(viewStyle.introLabel.padding.top)
            make.left.equalTo(self.nameLabel.snp.left)
            make.right.equalTo(self.nameLabel.snp.right)
        }
    }
}
