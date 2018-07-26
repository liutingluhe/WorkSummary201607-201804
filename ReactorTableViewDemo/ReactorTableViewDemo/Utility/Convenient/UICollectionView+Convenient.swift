//
//  UICollectionView+Convenient.swift
//  ReactorCollectionViewDemo
//
//  Created by luhe liu on 2018/6/4.
//  Copyright © 2018年 luhe liu. All rights reserved.
//

import UIKit

// MARK: - 注册和重用 Cell/Header/Footer
public extension UICollectionView {
    
    public func registerForCells<T: UICollectionViewCell>(_ cellClasses: [T.Type], isNib: Bool = true) {
        cellClasses.forEach { cellClass in
            registerForCell(cellClass, isNib: isNib)
        }
    }
    
    public func registerForCell<T: UICollectionViewCell>(_ cellClass: T.Type, identifier: String? = nil, isNib: Bool = true) {
        let nibName = cellClass.className
        let cellIdentifier = identifier ?? nibName
        if isNib {
            self.register(UINib(nibName: nibName, bundle: nil), forCellWithReuseIdentifier: cellIdentifier)
        } else {
            self.register(cellClass, forCellWithReuseIdentifier: cellIdentifier)
        }
    }
    
    public func registerForHeader<T: UICollectionReusableView>(_ cellClass: T.Type, identifier: String? = nil, isNib: Bool = true) {
        let nibName = cellClass.className
        let headerIdentifier = identifier ?? nibName
        if isNib {
            self.register(UINib(nibName: nibName, bundle: nil), forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: headerIdentifier)
        } else {
            self.register(cellClass, forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: headerIdentifier)
        }
    }
    
    public func registerForFooter<T: UICollectionReusableView>(_ cellClass: T.Type, identifier: String? = nil, isNib: Bool = true) {
        let nibName = cellClass.className
        let footerIdentifier = identifier ?? nibName
        if isNib {
            self.register(UINib(nibName: nibName, bundle: nil), forSupplementaryViewOfKind: UICollectionElementKindSectionFooter, withReuseIdentifier: footerIdentifier)
        } else {
            self.register(cellClass, forSupplementaryViewOfKind: UICollectionElementKindSectionFooter, withReuseIdentifier: footerIdentifier)
        }
    }
    
    public func dequeueCell<T: UICollectionViewCell>(_ cellClass: T.Type, reuseIdentifier: String? = nil, indexPath: IndexPath) -> T {
        let identifier: String = reuseIdentifier ?? cellClass.className
        // swiftlint:disable:next force_cast
        return self.dequeueReusableCell(withReuseIdentifier: identifier, for: indexPath) as! T
    }
    
    public func dequeueSupplementaryView<T: UICollectionReusableView>(_ viewClass: T.Type, kind: String, indexPath: IndexPath) -> T {
        let identifier = viewClass.className
        // swiftlint:disable:next force_cast
        return dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: identifier, for: indexPath) as! T
    }
}

// MARK: - 便捷工具
public extension UICollectionView {
    public func safeScrollToItem(at indexPath: IndexPath = IndexPath(row: 0, section: 0), at position: UICollectionViewScrollPosition = .top, animated: Bool = true) {
        guard let dataSource = self.dataSource else { return }
        let sectionCount: Int = dataSource.numberOfSections?(in: self) ?? 0
        guard sectionCount > indexPath.section else { return }
        guard dataSource.collectionView(self, numberOfItemsInSection: indexPath.section) > indexPath.row else { return }
        scrollToItem(at: indexPath, at: position, animated: animated)
    }
}
