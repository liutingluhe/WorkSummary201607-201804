//
//  ViewController.swift
//  ArchiveWithMirror
//
//  Created by luhe liu on 2018/3/18.
//  Copyright © 2018年 luhe liu. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        test()
    }

    fileprivate func test() {
        // 创建一个模型
        let model = WriterModel()
        model.name = "执着执念"
        model.age = 24
        model.createAt = Date().timeIntervalSince1970
        model.isWriter = true
        model.writerName = "哈哈"
        model.type = .black
        model.object = UserModel()
        
        // 归档
        print("====== archivedData ======")
        let data = NSKeyedArchiver.archivedData(withRootObject: model)
        print("name=\(model.name)")
        print("tag=\(model.age)")
        print("is_writer=\(model.isWriter)")
        print("craete_at=\(model.createAt)")
        print("writerName=\(model.writerName)")
        print("type=\(model.type)")
        print("object=\(model.object)")
        
        // 解档
        print("\n====== unarchiveObject ======")
        if let unarchiveModel = NSKeyedUnarchiver.unarchiveObject(with: data) as? WriterModel {
            print("name=\(unarchiveModel.name)")
            print("tag=\(unarchiveModel.age)")
            print("is_writer=\(unarchiveModel.isWriter)")
            print("craete_at=\(unarchiveModel.createAt)")
            print("writerName=\(unarchiveModel.writerName)")
            print("type=\(unarchiveModel.type)")
            print("object=\(unarchiveModel.object)")
        } else {
            print("unarchiveModel error")
        }
    }

}
