//
//  PushViewController.swift
//  ScreenEdgePanGestureDemo
//
//  Created by luhe liu on 2018/4/11.
//  Copyright © 2018年 com.liuting. All rights reserved.
//

import UIKit

class PushViewController: UIViewController {
    
    fileprivate var scrollView: UIScrollView!

    override func viewDidLoad() {
        super.viewDidLoad()

        setupSubviews()
    }
    
    fileprivate func setupSubviews() {
        
        self.navigationItem.title = "Push"
        self.view.backgroundColor = UIColor.black
        
        // 创建一个 scrollView 来演示手势冲突的情况
        scrollView = UIScrollView(frame: self.view.bounds)
        scrollView.alwaysBounceHorizontal = true
        scrollView.alwaysBounceVertical = false
        scrollView.showsVerticalScrollIndicator = false
        scrollView.showsHorizontalScrollIndicator = true
        scrollView.isPagingEnabled = true
        self.view.addSubview(scrollView)
        
        let count: Int = 5
        for index in 0..<count {
            let view = UIView(frame: self.view.bounds)
            view.frame.origin.x = CGFloat(index) * self.view.bounds.size.width
            let redRandom: CGFloat = CGFloat(arc4random_uniform(255)) / 255.0
            let greenRandom: CGFloat = CGFloat(arc4random_uniform(255)) / 255.0
            let blueRandom: CGFloat = CGFloat(arc4random_uniform(255)) / 255.0
            view.backgroundColor = UIColor(red: redRandom, green: greenRandom, blue: blueRandom, alpha: 1.0)
            scrollView.addSubview(view)
        }
        scrollView.contentSize = CGSize(width: self.view.bounds.size.width * CGFloat(count), height: 0)
    }

}
