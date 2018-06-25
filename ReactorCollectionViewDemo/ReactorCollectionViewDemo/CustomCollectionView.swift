//
//  CustomCollectionView.swift
//  ReactorCollectionViewDemo
//
//  Created by luhe liu on 2018/5/31.
//  Copyright © 2018年 luhe liu. All rights reserved.
//

import UIKit
import ReactorKit
import RxSwift
import RxCocoa

class CustomCollectionView: RxBasicCollectionView {
    
    override init(frame: CGRect, layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()) {
        super.init(frame: frame, layout: layout)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    deinit {
        print("CustomCollectionView dealloc")
    }
    
    override func setupSubviews() {
        self.headerRefreshClass = CustomHeaderRefreshView.self
        self.footerRefreshClass = CustomFooterRefreshView.self
        self.placeholderView = CustomPlaceholderView(frame: self.bounds)
        defaultHeaderRefreshHeight = 60
        loadFirstInset = 60
        defaultFooterRefreshHeight = 60
        preloadNextInset = self.frame.size.height * 0.5
    }
}
