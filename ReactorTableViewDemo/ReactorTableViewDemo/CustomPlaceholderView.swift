//
//  CustomPlaceholderView.swift
//  ReactorCollectionViewDemo
//
//  Created by luhe liu on 2018/6/21.
//  Copyright © 2018年 luhe liu. All rights reserved.
//

import UIKit
import ReactorKit
import RxSwift
import RxCocoa

class CustomPlaceholderView: RxBasicPlaceholderView {

    fileprivate var titleLabel: UILabel!
    fileprivate var imageView: UIImageView!
    fileprivate var respondedButton: UIButton!
    
    required init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    deinit {
        print("CustomPlaceholderView dealloc")
    }
    
    override func setupSubviews() {
        
        setupTitleLabel()
        
        setupImageView()
        
        setupRespondedButton()
        
    }
    
    override func updateSubviews() {
        var titleText = "占位显示"
        let showImage = UIImage(named: "blank_150x150")
        let totalHeight = UIScreen.main.bounds.size.height - 64
        if isNetworkError {
            titleText = "网络错误显示"
        }
        displaySubviews(title: titleText, image: showImage, totalHeight: totalHeight)
    }
}

extension CustomPlaceholderView {
    
    struct ViewSize {
        static let imageWidth: CGFloat = 150 * UIScreen.main.bounds.size.width / 414
        static let imageBottom: CGFloat = 24
    }
    
    struct Color {
        static let title = UIColor.black
    }
    
    struct Font {
        static let title = UIFont.systemFont(ofSize: 14)
    }
    
    fileprivate func setupTitleLabel() {
        titleLabel = UILabel(frame: self.bounds)
        titleLabel.textColor = Color.title
        titleLabel.font = Font.title
        titleLabel.textAlignment = .center
        titleLabel.numberOfLines = 0
        self.addSubview(titleLabel)
    }
    
    fileprivate func setupImageView() {
        imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: ViewSize.imageWidth, height: ViewSize.imageWidth))
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        self.addSubview(imageView)
    }
    
    fileprivate func setupRespondedButton() {
        respondedButton = UIButton(type: .custom)
        respondedButton.setTitle(nil, for: .normal)
        respondedButton.setImage(nil, for: .normal)
        self.addSubview(respondedButton)
    }
    
    fileprivate func displaySubviews(title: String?, image: UIImage?, totalHeight: CGFloat) {
        imageView.image = image
        titleLabel.frame = self.bounds
        titleLabel.text = title
        titleLabel.sizeToFit()
        
        let contentHeight: CGFloat = ViewSize.imageWidth + ViewSize.imageBottom + titleLabel.frame.size.height
        imageView.frame.origin.y = (totalHeight - contentHeight) * 0.5
        imageView.center.x = self.frame.size.width * 0.5
        titleLabel.frame.origin.y = imageView.frame.maxY + ViewSize.imageBottom
        titleLabel.center.x = imageView.center.x
        
        respondedButton.frame.size.width = max(titleLabel.frame.size.width, imageView.frame.size.width)
        respondedButton.frame.size.height = titleLabel.frame.maxY - imageView.frame.minY
        respondedButton.frame.origin.x = min(titleLabel.frame.minX, imageView.frame.minX)
        respondedButton.frame.origin.y = imageView.frame.minY
        self.frame.size.height = totalHeight
    }
}
