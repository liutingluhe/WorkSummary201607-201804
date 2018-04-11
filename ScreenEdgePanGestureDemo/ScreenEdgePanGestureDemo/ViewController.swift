//
//  ViewController.swift
//  ScreenEdgePanGestureDemo
//
//  Created by luhe liu on 2018/4/10.
//  Copyright © 2018年 com.liuting. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        setupSubviews()
    }

    fileprivate func setupSubviews() {
        
        self.navigationItem.title = "Home"
        self.view.backgroundColor = UIColor.white
        
        let button = UIButton(type: .system)
        button.frame = CGRect(x: 0, y: 0, width: 300, height: 50)
        button.setTitleColor(UIColor.red, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        button.setTitle("Push ViewController", for: .normal)
        button.sizeToFit()
        button.center = self.view.center
        button.addTarget(self, action: #selector(ViewController.pushToViewController), for: .touchUpInside)
        self.view.addSubview(button)
    }
    
    func pushToViewController() {
        let pushVC = PushViewController()
        self.navigationController?.pushViewController(pushVC, animated: true)
    }
}

