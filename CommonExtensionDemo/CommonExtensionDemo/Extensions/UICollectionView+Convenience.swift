//
//  UICollectionView+Convenience.swift
//  CommonExtensionDemo
//
//  Created by catch on 18/3/25.
//  Copyright © 2018年 执着·执念. All rights reserved.
//

import UIKit

extension UICollectionView {
    
    /// 批量注册 Cell
    func registerForCells<T: UICollectionReusableView>(_ cellClasses: [T.Type], isNib: Bool = true) {
        cellClasses.forEach { cellClass in
            registerForCell(cellClass, isNib: isNib)
        }
    }
    
    /// 注册 Cell
    func registerForCell<T: UICollectionReusableView>(_ cellClass: T.Type, identifier: String? = nil, isNib: Bool = true) {
        let nibName = cellClass.className
        let cellIdentifier = identifier ?? nibName
        if isNib {
            self.register(UINib(nibName: nibName, bundle: nil), forCellWithReuseIdentifier: cellIdentifier)
        } else {
            self.register(cellClass, forCellWithReuseIdentifier: cellIdentifier)
        }
    }
    
    /// 注册顶部视图
    func registerForHeader<T: UICollectionReusableView>(_ cellClass: T.Type, identifier: String? = nil, isNib: Bool = true) {
        let nibName = cellClass.className
        let headerIdentifier = identifier ?? nibName
        if isNib {
            self.register(UINib(nibName: nibName, bundle: nil), forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: headerIdentifier)
        } else {
            self.register(cellClass, forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: headerIdentifier)
        }
    }
    
    /// 注册底部视图
    func registerForFooter<T: UICollectionReusableView>(_ cellClass: T.Type, identifier: String? = nil, isNib: Bool = true) {
        let nibName = cellClass.className
        let footerIdentifier = identifier ?? nibName
        if isNib {
            self.register(UINib(nibName: nibName, bundle: nil), forSupplementaryViewOfKind: UICollectionElementKindSectionFooter, withReuseIdentifier: footerIdentifier)
        } else {
            self.register(cellClass, forSupplementaryViewOfKind: UICollectionElementKindSectionFooter, withReuseIdentifier: footerIdentifier)
        }
    }
    
    /// 从缓存池取出 Cell
    func dequeueCell<T: UICollectionReusableView>(_ cellClass: T.Type, reuseIdentifier: String? = nil, indexPath: IndexPath) -> T {
        let identifier: String = reuseIdentifier ?? cellClass.className
        if let cell = dequeueReusableCell(withReuseIdentifier: identifier, for: indexPath) as? T {
            return cell
        } else {
            return T()
        }
    }
    
    /// 从缓存池取出顶部或者底部实体
    func dequeueSupplementaryView<T: UICollectionReusableView>(_ viewClass: T.Type, kind: String, indexPath: IndexPath) -> T {
        let identifier = viewClass.className
        if let cell = dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: identifier, for: indexPath) as? T {
            return cell
        } else {
            return T()
        }
    }
    
    /// 滑动到第一个 Cell 位置，通过增加判断，防止奔溃
    func scrollToFirstCell(animated: Bool = true) {
        guard self.numberOfSections > 0 else { return }
        guard let count = self.dataSource?.collectionView(self, numberOfItemsInSection: 0) else { return }
        if count > 0 {
            if let flowLayout = self.collectionViewLayout as? UICollectionViewFlowLayout {
                if flowLayout.scrollDirection == .horizontal {
                    scrollToItem(at: IndexPath(row: 0, section: 0), at: .left, animated: animated)
                } else {
                    scrollToItem(at: IndexPath(row: 0, section: 0), at: .top, animated: animated)
                }
            }
        }
    }
}
