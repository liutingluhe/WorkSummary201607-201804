//
//  ViewController.swift
//  GIFImageLoadDemo
//
//  Created by luhe liu on 2018/5/13.
//  Copyright © 2018年 luhe liu. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var networkImageView: BasicGIFImageView!
    @IBOutlet weak var localImageView: BasicGIFImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // 加载网络 GIF 图片
        let testUrlStr = "https://images.ifanr.cn/wp-content/uploads/2018/05/2018-05-09-17_22_48.gif"
        networkImageView.showNetworkGIF(urlStr: testUrlStr)
        // 加载本地 GIF 图片
        localImageView.showLocalGIF(name: "test")
    }

}

