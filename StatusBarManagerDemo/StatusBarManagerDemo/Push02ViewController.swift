//
//  Push02ViewController.swift
//  StatusBarManagerDemo
//
//  Created by luhe liu on 2018/4/23.
//  Copyright © 2018年 com.liuting. All rights reserved.
//

import UIKit

class Push02ViewController: BasicViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        setupSubviews()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.backgroundColor = UIColor.blue
    }
    
    fileprivate func setupSubviews() {
        
        self.view.backgroundColor = UIColor.blue
        self.navigationItem.title = "Push 02"
        setStatusBar(isHidden: false, style: .lightContent)
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "home", style: .done, target: self, action: #selector(Push02ViewController.pushToRootViewController))
    }

    func pushToRootViewController() {
        // 测试 popToRootViewController 后，状态树是否正确
        self.navigationController?.popToRootViewController(animated: true)
    }
}
