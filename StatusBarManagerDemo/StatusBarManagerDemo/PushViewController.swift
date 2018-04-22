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
        self.navigationController?.navigationBar.titleTextAttributes = [
            NSFontAttributeName: UIFont.systemFont(ofSize: 14),
            NSForegroundColorAttributeName: UIColor.white
        ]
    }
    
    fileprivate func setupSubviews() {
        
        self.view.backgroundColor = UIColor.black
        self.navigationItem.title = "Push"
        StatusBarManager.shared.style = .lightContent
    }

}
