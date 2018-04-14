//
//  AlphaTransitionViewController.swift
//  TransitionDemo
//
//  Created by luhe liu on 2018/4/8.
//  Copyright © 2018年 com.ifanr. All rights reserved.
//

import UIKit

class AlphaTransitionViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        setupSubviews()
    }
    
    fileprivate func setupSubviews() {
        self.view.backgroundColor = UIColor.red
        self.navigationItem.title = "Alpha"
        
        let titleLabel = UILabel(frame: self.view.bounds)
        titleLabel.text = "AlphaTransitionViewController"
        titleLabel.font = UIFont.systemFont(ofSize: 15)
        titleLabel.textColor = UIColor.blue
        titleLabel.textAlignment = .center
        self.view.addSubview(titleLabel)
        
        guard self.transitioningDelegate is AlphaTransitionDelegate else { return }
        let dismissButton = UIButton(type: .custom)
        dismissButton.frame.size = CGSize(width: 200, height: 50)
        dismissButton.center.x = self.view.center.x
        dismissButton.center.y = self.view.center.y + 50
        dismissButton.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        dismissButton.setTitleColor(UIColor.blue, for: .normal)
        dismissButton.setTitle("Dismiss AlphaTransition", for: .normal)
        dismissButton.backgroundColor = UIColor.darkGray
        dismissButton.addTarget(self, action: #selector(AlphaTransitionViewController.dismissButtonAction), for: .touchUpInside)
        self.view.addSubview(dismissButton)
    }
    
    func dismissButtonAction() {
        self.dismiss(animated: true, completion: nil)
    }
}
