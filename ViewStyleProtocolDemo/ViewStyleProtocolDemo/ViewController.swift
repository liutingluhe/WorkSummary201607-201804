//
//  ViewController.swift
//  ViewStyleProtocolDemo
//
//  Created by luhe liu on 2018/4/12.
//  Copyright © 2018年 luhe liu. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    fileprivate var testView: TestView!
    @IBOutlet weak var button1: UIButton!
    @IBOutlet weak var button2: UIButton!
    @IBOutlet weak var button3: UIButton!
    fileprivate lazy var viewStyle1: TestViewStyle = TestViewStyle1()
    fileprivate lazy var viewStyle2: TestViewStyle = TestViewStyle2()
    fileprivate lazy var viewStyle3: TestViewStyle = TestViewStyle3()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 初始化
        testView = TestView(frame: CGRect(x: 0, y: 100, width: self.view.frame.size.width, height: 200))
        // 配置样式
        testView.viewStyle = TestViewStyle1()
        self.view.addSubview(testView)
        
        // 更换样式配置
        testView.viewStyle = TestViewStyle2()
        
        let model = TestModel()
        model.name = "执着丶执念"
        model.avatarImage = UIImage(named: "name1")
        model.intro = "一个 iOS 开发工程师，求关注，求赞，哈哈哈哈哈哈哈哈哈哈哈"
        model.didSubscribed = false
        testView.setModel(model)
        
        clickButton1(button1)
    }

    // 下面3个按钮点击切换视图样式
    @IBAction func clickButton1(_ sender: Any) {
        button1.isSelected = true
        button2.isSelected = false
        button3.isSelected = false
        testView.viewStyle = viewStyle1
    }
    
    @IBAction func clickButton2(_ sender: Any) {
        button1.isSelected = false
        button2.isSelected = true
        button3.isSelected = false
        testView.viewStyle = viewStyle2
    }
    
    @IBAction func clickButton3(_ sender: Any) {
        button1.isSelected = false
        button2.isSelected = false
        button3.isSelected = true
        testView.viewStyle = viewStyle3
    }

}

