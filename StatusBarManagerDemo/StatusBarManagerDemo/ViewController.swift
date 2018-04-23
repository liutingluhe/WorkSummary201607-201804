//
//  ViewController.swift
//  StatusBarManagerDemo
//
//  Created by luhe liu on 2018/4/11.
//  Copyright © 2018年 com.liuting. All rights reserved.
//

import UIKit

class ViewController: BasicViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupSubviews()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.backgroundColor = UIColor.white
    }
    
    fileprivate func setupSubviews() {
        
        self.view.backgroundColor = UIColor.white
        self.navigationItem.title = "Home"
        setStatusBar(isHidden: false, style: .default)
        self.navigationController?.navigationBar.titleTextAttributes = [
            NSFontAttributeName: UIFont.systemFont(ofSize: 14),
            NSForegroundColorAttributeName: UIColor.red
        ]
        
        let button = UIButton(type: .system)
        button.frame = self.view.bounds
        button.setTitleColor(UIColor.red, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16)
        button.setTitle("Push", for: .normal)
        button.sizeToFit()
        button.center = self.view.center
        button.addTarget(self, action: #selector(ViewController.pushToViewController), for: .touchUpInside)
        self.view.addSubview(button)
    }
    
    func pushToViewController() {
        let pushVC = PushViewController()
        self.navigationController?.pushViewController(pushVC, animated: true)
        
        // 延时 3 秒后，对该控制器状态栏状态进行修改，看看会不会影响别的状态栏状态
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 3) {
            self.setStatusBar(isHidden: true)
        }
    }
}

