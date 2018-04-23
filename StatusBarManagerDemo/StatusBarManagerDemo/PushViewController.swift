//
//  PushViewController.swift
//  StatusBarManagerDemo
//
//  Created by luhe liu on 2018/4/11.
//  Copyright © 2018年 com.liuting. All rights reserved.
//

import UIKit

class PushViewController: BasicViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        setupSubviews()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.backgroundColor = UIColor.black
    }
    
    fileprivate func setupSubviews() {
        
        self.view.backgroundColor = UIColor.black
        self.navigationItem.title = "Push"
        setStatusBar(isHidden: false, style: .lightContent)
        
        let button = UIButton(type: .system)
        button.frame = self.view.bounds
        button.setTitleColor(UIColor.red, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16)
        button.setTitle("Push 02", for: .normal)
        button.sizeToFit()
        button.center = self.view.center
        button.addTarget(self, action: #selector(PushViewController.pushToViewController), for: .touchUpInside)
        self.view.addSubview(button)
    }

    func pushToViewController() {
        let pushVC = Push02ViewController()
        self.navigationController?.pushViewController(pushVC, animated: true)
    }
}
