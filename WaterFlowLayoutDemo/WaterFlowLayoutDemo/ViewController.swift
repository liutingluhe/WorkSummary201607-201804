//
//  ViewController.swift
//  WaterFlowLayoutDemo
//
//  Created by luhe liu on 2018/3/31.
//  Copyright © 2018年 luhe liu. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    fileprivate var collectionView: UICollectionView!
    fileprivate var titles: [String] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        createTestData()
        setupCollectionView()
    }
    
    /// 构建测试数据
    fileprivate func createTestData() {
        let testStr = "执着_执念"
        let count: Int = 40
        for _ in 0..<count {
            let randomValue = Int(arc4random_uniform(50)) + 1
            var str = ""
            for _ in 0..<randomValue {
                str += testStr
            }
            titles.append(str)
        }
    }

    /// 配置 CollectionView，设置布局为自定义瀑布流布局
    fileprivate func setupCollectionView() {
        let waterLayout = CollectionViewWaterFlowLayout(waterCount: 2)
        waterLayout.scrollDirection = .vertical
        waterLayout.delegate = self
        collectionView = UICollectionView(frame: self.view.bounds, collectionViewLayout: waterLayout)
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.alwaysBounceHorizontal = false
        collectionView.alwaysBounceVertical = true
        collectionView.showsVerticalScrollIndicator = false
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.contentInset = UIEdgeInsets(top: 20, left: 0, bottom: 0, right: 0)
        collectionView.backgroundColor = UIColor.clear
        if #available(iOS 11.0, *) {
            collectionView.contentInsetAdjustmentBehavior = .never
        } else {
            self.automaticallyAdjustsScrollViewInsets = false
        }
        self.view.addSubview(collectionView)
        collectionView.registerForCell(WaterCollectionViewCell.self)
        
    }
}

// MARK: - UICollectionViewDelegate, UICollectionViewDataSource, CollectionViewDelegateWaterLayout
extension ViewController: UICollectionViewDelegate, UICollectionViewDataSource, CollectionViewDelegateWaterLayout {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return titles.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueCell(WaterCollectionViewCell.self, indexPath: indexPath)
        cell.titleLabel.attributedText = NSAttributedString(string: titles[indexPath.row], attributes: WaterCollectionViewCell.titleAttribute)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, limitSize: CGSize, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let titleSize: CGSize = titles[indexPath.row].textSizeForLabel(size: limitSize, attributes: WaterCollectionViewCell.titleAttribute)
        if limitSize.height > limitSize.width {
            return CGSize(width: limitSize.width, height: titleSize.height)
        } else {
            return CGSize(width: titleSize.width, height: limitSize.height)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let insertTitle = "点击删除"
        if titles[indexPath.row] != insertTitle {
            titles.insert(insertTitle, at: 0)
            collectionView.performBatchUpdates({
                let insertIndexPath = IndexPath(row: 0, section: 0)
                collectionView.insertItems(at: [insertIndexPath])
            })
        } else {
            titles.remove(at: indexPath.row)
            collectionView.performBatchUpdates({
                collectionView.deleteItems(at: [indexPath])
            })
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, rowSpacingForSectionAt section: Int) -> CGFloat {
        return 10
    }
    
    func collectionView(_ collectionView: UICollectionView, columnSpacingForSectionAt section: Int) -> CGFloat {
        return 10
    }
    
    func collectionView(_ collectionView: UICollectionView, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 10, bottom: 10, right: 10)
    }
}
