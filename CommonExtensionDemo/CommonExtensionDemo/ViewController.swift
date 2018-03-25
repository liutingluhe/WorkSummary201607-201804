//
//  ViewController.swift
//  CommonExtensionDemo
//
//  Created by luhe liu on 2018/3/25.
//  Copyright © 2018年 luhe liu. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    fileprivate var collectionView: UICollectionView!
    fileprivate var headerView: HeaderView!
    fileprivate lazy var testMethods: [String] = [
        "testNSDictionaryConvenience()",
        "testNSObjectClassName()",
        "testStringRegularExpression()",
        "testStringSubstr()",
        "testUIViewDisplayToImage()",
        "testArrayConvenience()"
    ]

    override func viewDidLoad() {
        super.viewDidLoad()
        setupCollectionView()
        setupHeaderView()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        headerView.printResponderController()
    }
    
    fileprivate func setupCollectionView() {
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.scrollDirection = .vertical
        collectionView = UICollectionView(frame: self.view.bounds, collectionViewLayout: flowLayout)
        collectionView.contentSize = CGSize(width: self.view.frame.size.width, height: self.view.frame.size.height + 1)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.alwaysBounceHorizontal = false
        collectionView.alwaysBounceVertical = true
        collectionView.showsVerticalScrollIndicator = false
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        collectionView.backgroundColor = UIColor.clear
        if #available(iOS 11.0, *) {
            collectionView.contentInsetAdjustmentBehavior = .never
        } else {
            self.automaticallyAdjustsScrollViewInsets = false
        }
        self.view.addSubview(collectionView)
        // MARK: 测试 UICollectionView 快速注册方法
        collectionView.registerForCell(TestCollectionViewCell.self)
    }
    
    fileprivate func setupHeaderView() {
        headerView = HeaderView(frame: CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: 100))
        self.view.addSubview(headerView)
    }
}

extension ViewController: UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return testMethods.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueCell(TestCollectionViewCell.self, indexPath: indexPath)
        cell.titleLabel.text = testMethods.safeIndex(indexPath.row)
        cell.backgroundColor = UIColor.red
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 10
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 10
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 120, left: 0, bottom: 10, right: 0)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        var cellHeight: CGFloat = 0
        let cellWidth: CGFloat = self.view.frame.size.width
        // MARK: 测试数组安全取值
        if let title = testMethods.safeIndex(indexPath.row) {
            let titleWidth = cellWidth - 20
            // MARK: 测试根据字符串计算高度
            cellHeight = title.heightForLabel(width: titleWidth, font: TestCollectionViewCell.titleFont)
            cellHeight += 20
        }
        return CGSize(width: cellWidth, height: cellHeight)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        switch indexPath.row {
        case 0:
            testNSDictionaryConvenience()
        case 1:
            testNSObjectClassName()
        case 2:
            testStringRegularExpression()
        case 3:
            testStringSubstr()
        case 4:
            testUIViewDisplayToImage()
        case 5:
            testArrayConvenience()
        default:
            break
        }
    }
}

// MARK: - 测试分类方法
extension ViewController {
    
    /// 打印测试的开始和结束
    fileprivate func testPrint(_ testHandle: () -> Void, _ method: String = #function) {
        print("\n======= testing \(method) Begin =======\n")
        testHandle()
        print("\n======= testing \(method) End =======\n")
    }
    
    /// MARK: 测试字典取值
    fileprivate func testNSDictionaryConvenience() {
        testPrint({
            let testData: NSDictionary = [
                "bool_key": true,
                "int_key": 1,
                "int_key_2": 2,
                "int_key_3": 3,
                "string_key": "test",
                "double_key": 123.456,
                "dictionary_key": [ "a" : 1 , "b" : 2 ],
                "array_key": [1, 2, 3, 4]
            ]
            print("testData = \(testData)")
            let boolValue = testData.bool("bool_key")
            print("boolValue: bool_key = \(boolValue)")
            let intValue = testData.int("int_key", "int_key_2", "int_key_3")
            print("intValue: int_key = \(intValue)")
            let stringValue = testData.string("string_key")
            print("stringValue: string_key = \(String(describing: stringValue))")
            let doubleValue = testData.double("double_key")
            print("doubleValue: double_key = \(doubleValue)")
            let dictionaryValue = testData.dictionary("dictionary_key")
            print("dictionaryValue: dictionary_key = \(String(describing: dictionaryValue))")
            let arrayValue = testData.array("array_key", type: Int.self)
            print("arrayValue: array_key = \(arrayValue)")
            let defaultTestValue = testData.string("default_key", defaultValue: "key is not in NSDictionary")
            print("defaultTestValue: default_key = \(String(describing: defaultTestValue))")
        })
    }
    
    // MARK: 测试类名输出
    fileprivate func testNSObjectClassName() {
        testPrint({
            print("ViewController.className = \(ViewController.className)")
            print("self.className = \(self.className)")
            print("TestCollectionViewCell.className = \(TestCollectionViewCell.className)")
            print("headerView.className = \(headerView.className)")
        })
    }
    
    // MARK: 测试字符串正则替换
    fileprivate func testStringRegularExpression() {
        testPrint({
            testMethods.forEach({ (str) in
                // 正则去掉头部 test 和后面的 ()
                let newStr = str.replacingStringOfRegularExpression(pattern: "(test|\\(\\))", template: "")
                print("str = \(str) newStr = \(newStr)")
            })
        })
    }
    
    // MARK: 测试字符串截取
    fileprivate func testStringSubstr() {
        testPrint({
            testMethods.forEach({ (str) in
                
                let toIndex: Int = 4
                let subStrToIndex = str.substring(to: toIndex)
                print("str = \(str), subStrToIndex = \(String(describing: subStrToIndex)), toIndex = \(toIndex)")
                
                let fromIndex: Int = 4
                let subStrFromIndex = str.substring(from: fromIndex)
                print("str = \(str), subStrFromIndex = \(String(describing: subStrFromIndex)), fromIndex = \(fromIndex)")
                
                let lower: Int = 3
                let len: Int = 4
                let subStrRange = str.substring(lower, len)
                print("str = \(str), subStrRange = \(String(describing: subStrRange)), lower = \(lower), len = \(len)")
                
                let betweenStart = "test"
                let betweenEnd = "()"
                let subStrBetween = str.substring(between: betweenStart, and: betweenEnd)
                print("str = \(str), subStrBetween(\(betweenStart)...\(betweenEnd)) = \(String(describing: subStrBetween))")
                
                let prefix = "testUIView"
                let subStrPrefix = str.substring(prefix: prefix)
                print("str = \(str), subStrPrefix(\(prefix)...) = \(String(describing: subStrPrefix))")
                
                let suffix = "b()"
                let subStrSuffix = str.substring(suffix: suffix)
                print("str = \(str), subStrSuffix(...\(suffix)) = \(String(describing: subStrSuffix))")
                
            })
        })
    }
    
    // MARK: 测试视图转图片
    fileprivate func testUIViewDisplayToImage() {
        testPrint({
            if let image = headerView.displayViewToImage() {
                let imageView = UIImageView(image: image)
                let randomValue = max(10, arc4random_uniform(UInt32(headerView.frame.size.height)))
                let imageViewHeight: CGFloat = CGFloat(randomValue)
                let imageViewWidth: CGFloat = imageViewHeight * headerView.frame.size.width / headerView.frame.size.height
                imageView.frame = CGRect(x: 0, y: 0, width: imageViewWidth, height: imageViewHeight)
                imageView.center = headerView.center
                self.view.addSubview(imageView)
                print("create UImageView \(imageView)")
            }
        })
    }

    // MARK: 测试数组分类方法
    fileprivate func testArrayConvenience() {
        testPrint({
            let limitCount: Int = 3
            let testLimitArray1 = [1, 2]
            let testLimitResult1 = testLimitArray1.limit(limitCount)
            print("array = \(testLimitArray1), limitCount = \(limitCount), result = \(testLimitResult1)")
            
            let testLimitArray2 = [1, 2, 3, 4]
            let testLimitResult2 = testLimitArray2.limit(limitCount)
            print("array = \(testLimitArray2), limitCount = \(limitCount), result = \(testLimitResult2)")
            
            let fullCount: Int = 5
            let testFullArray1 = [1, 2]
            let testFullResult1 = testFullArray1.full(fullCount)
            print("array = \(testFullArray1), fullCount = \(fullCount), result = \(testFullResult1)")
            
            let testFullArray2 = [1, 2, 3, 4, 5, 6]
            let testFullResult2 = testFullArray2.full(fullCount)
            print("array = \(testFullArray2), fullCount = \(fullCount), result = \(testFullResult2)")
            
            print("testMethods = \(testMethods)")
            testMethods.bilateralEnumerated(3, handler: { (index, str) in
                print("bilateralEnumerated \(index) = \(str)")
            })
        })
    }
}

