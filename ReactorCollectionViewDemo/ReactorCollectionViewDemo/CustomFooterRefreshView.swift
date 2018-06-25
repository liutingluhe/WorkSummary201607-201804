
//
//  CustomFooterRefreshView.swift
//  ReactorCollectionViewDemo
//
//  Created by luhe liu on 2018/5/30.
//  Copyright © 2018年 luhe liu. All rights reserved.
//

import UIKit
import ReactorKit
import RxSwift
import RxCocoa

class CustomFooterRefreshView: RxBasicFooterRefreshView {
    
    lazy var endLoadLabel: UILabel = {
        let endLoadLabel = UILabel(frame: CGRect(x: 0, y: 0, width: self.frame.size.width, height: 50))
        endLoadLabel.backgroundColor = UIColor.clear
        endLoadLabel.text = "- END -"
        endLoadLabel.textColor = UIColor.black
        endLoadLabel.font = UIFont.systemFont(ofSize: 11)
        endLoadLabel.textAlignment = .center
        endLoadLabel.isHidden = true
        return endLoadLabel
    }()
    
    required init(frame: CGRect, scrollView: UIScrollView?) {
        super.init(frame: frame, scrollView: scrollView)
        loadingClass = PulseLoadingView.self
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func setupSubviews() {
        self.addSubview(endLoadLabel)
    }
    
    deinit {
        print("CustomFooterRefreshView dealloc")
    }
    
    open override func updateLoadMoreState() {
        loadingView?.isHidden = !canLoadMore
        endLoadLabel.isHidden = canLoadMore
    }
    
}
