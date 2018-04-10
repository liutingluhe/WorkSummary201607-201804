//
//  RippleTransitionViewController.swift
//  TransitionDemo
//
//  Created by luhe liu on 2018/4/8.
//  Copyright © 2018年 com.ifanr. All rights reserved.
//

import UIKit

class RippleTransitionViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        setupSubviews()
    }
    
    fileprivate func setupSubviews() {
        self.view.backgroundColor = UIColor.blue
        
        let titleLabel = UILabel(frame: self.view.bounds)
        titleLabel.text = "RippleTransitionViewController"
        titleLabel.font = UIFont.systemFont(ofSize: 15)
        titleLabel.textColor = UIColor.orange
        titleLabel.textAlignment = .center
        self.view.addSubview(titleLabel)
        
        let dismissButton = UIButton(type: .custom)
        dismissButton.frame.size = CGSize(width: 200, height: 50)
        dismissButton.center.x = self.view.center.x
        dismissButton.center.y = self.view.center.y + 50
        dismissButton.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        dismissButton.setTitleColor(UIColor.orange, for: .normal)
        dismissButton.setTitle("Dismiss RippleTransition", for: .normal)
        dismissButton.backgroundColor = UIColor.darkGray
        dismissButton.addTarget(self, action: #selector(RippleTransitionViewController.dismissButtonAction), for: .touchUpInside)
        self.view.addSubview(dismissButton)
    }
    
    func dismissButtonAction() {
        self.dismiss(animated: true, completion: nil)
    }
    
}
