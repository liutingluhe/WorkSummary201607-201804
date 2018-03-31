//
//  CollectionViewWaterFlowLayout.swift
//  ifanr
//
//  Created by 陈恩湖 on 13/11/2017.
//  Copyright © 2017 ifanr. All rights reserved.
//

import UIKit

/// 定义瀑布流代理，用于计算每个瀑布流卡片高度、顶部视图大小、底部视图大小，配置行间距、列间距、缩进属性
@objc protocol CollectionViewDelegateWaterLayout {
    // cell 大小
    func collectionView(_ collectionView: UICollectionView, limitSize: CGSize, sizeForItemAt indexPath: IndexPath) -> CGSize
    // 组缩进
    @objc optional func collectionView(_ collectionView: UICollectionView, insetForSectionAt section: Int) -> UIEdgeInsets
    // 行间距
    @objc optional func collectionView(_ collectionView: UICollectionView, rowSpacingForSectionAt section: Int) -> CGFloat
    // 列间距
    @objc optional func collectionView(_ collectionView: UICollectionView, columnSpacingForSectionAt section: Int) -> CGFloat
    // 顶部视图大小
    @objc optional func collectionView(_ collectionView: UICollectionView, referenceSizeForHeaderInSection section: Int) -> CGSize
    // 底部视图大小
    @objc optional func collectionView(_ collectionView: UICollectionView, referenceSizeForFooterInSection section: Int) -> CGSize
}

/// 自定义瀑布流 CollectionView 布局
class CollectionViewWaterFlowLayout: UICollectionViewLayout {

    fileprivate var layoutAttributes = [UICollectionViewLayoutAttributes]()
    fileprivate var waterLengths: [Int: CGFloat] = [:]
    fileprivate var waterCount: Int = 1
    fileprivate var updateIndexPaths: [IndexPath] = []
    weak var delegate: CollectionViewDelegateWaterLayout?
    var rowSpacing: CGFloat = 0
    var columnSpacing: CGFloat = 0
    var scrollDirection: UICollectionViewScrollDirection = .vertical
    var sectionInset: UIEdgeInsets = .zero
    
    /// 初始化传入瀑布流的数量
    init(waterCount: Int = 1) {
        super.init()
        self.waterCount = max(1, waterCount)
        for index in 0..<waterCount {
            waterLengths[index] = 0.0
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    /// 布局后的内容大小
    override var collectionViewContentSize: CGSize {
        var totalSize: CGSize = .zero
        if scrollDirection == .vertical {
            totalSize.height = layoutAttributes.map({ $0.frame.origin.y + $0.frame.size.height }).sorted(by: { $0 > $1 }).first ?? 0.0
            if let collectionView = collectionView {
                totalSize.width = collectionView.frame.size.width
            }
        } else {
            totalSize.width = layoutAttributes.map({ $0.frame.origin.x + $0.frame.size.width }).sorted(by: { $0 > $1 }).first ?? 0.0
            if let collectionView = collectionView {
                totalSize.height = collectionView.frame.size.height
            }
        }
        return totalSize
    }
    
    /// reloadData 后，系统在布局前会调用
    override func prepare() {
        super.prepare()
        guard let collectionView = collectionView else { return }
        
        // 清空瀑布流长度和布局数据
        layoutAttributes.removeAll()
        for index in 0..<waterLengths.count {
            waterLengths[index] = 0.0
        }
        
        for sectionIndex in 0..<collectionView.numberOfSections {
            let cellCount = collectionView.numberOfItems(inSection: sectionIndex)
            if cellCount <= 0 { continue }
            // 设置行间距、列间距、组缩进
            rowSpacing = self.delegate?.collectionView?(collectionView, rowSpacingForSectionAt: sectionIndex) ?? 0.0
            columnSpacing = self.delegate?.collectionView?(collectionView, columnSpacingForSectionAt: sectionIndex) ?? 0.0
            sectionInset = self.delegate?.collectionView?(collectionView, insetForSectionAt: sectionIndex) ?? .zero
            // 获取该组的顶部视图布局
            let sectionIndexPath: IndexPath = IndexPath(row: 0, section: sectionIndex)
            if let headerLayoutAttribute = getSupplementaryViewLayoutAttribute(ofKind: UICollectionElementKindSectionHeader, at: sectionIndexPath) {
                layoutAttributes.append(headerLayoutAttribute)
            }
            // 获取该组的所有 cell 布局
            for cellIndex in 0..<cellCount {
                let cellIndexPath: IndexPath = IndexPath(row: cellIndex, section: sectionIndex)
                if let cellLayoutAttribute = getCellLayoutAttribute(at: cellIndexPath) {
                    layoutAttributes.append(cellLayoutAttribute)
                }
            }
            // 获取该组的底部视图布局
            if let footerLayoutAttribute = getSupplementaryViewLayoutAttribute(ofKind: UICollectionElementKindSectionFooter, at: sectionIndexPath) {
                layoutAttributes.append(footerLayoutAttribute)
            }
        }
 
    }
    
    /// 计算各个 cell 的布局
    fileprivate func getCellLayoutAttribute(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        guard let collectionView = collectionView else { return nil }
        let layoutAttribute = UICollectionViewLayoutAttributes(forCellWith: indexPath)
        
        // 计算瀑布流 cell 限制大小
        var limitSize = CGSize(width: CGFloat.greatestFiniteMagnitude, height: CGFloat.greatestFiniteMagnitude)
        if scrollDirection == .vertical {
            let interitemSpacingWidth: CGFloat = CGFloat(waterCount - 1) * columnSpacing
            let columnWidth: CGFloat = (collectionView.frame.size.width - sectionInset.left - sectionInset.right - interitemSpacingWidth) / CGFloat(waterCount)
            limitSize.width = columnWidth
        } else {
            let interitemSpacingHeight: CGFloat = CGFloat(waterCount - 1) * rowSpacing
            let columnHeight: CGFloat = (collectionView.frame.size.height - sectionInset.top - sectionInset.bottom - interitemSpacingHeight) / CGFloat(waterCount)
            limitSize.height = columnHeight
        }
        
        // 通过代理获取瀑布流 cell 大小
        if let layout = self.delegate {
            layoutAttribute.frame.size = layout.collectionView(collectionView, limitSize: limitSize, sizeForItemAt: indexPath)
        }
        
        // 找到最短的那一条，把该 cell 的位置放到该条后面，并更新瀑布流长度
        let minWater = waterLengths.sorted(by: { (first, second) in
            if first.value < second.value {
                return true
            } else if first.value == second.value {
                return first.key < second.key
            }
            return false
        }).first
        
        if let minWater = minWater {
            if scrollDirection == .vertical {
                layoutAttribute.frame.origin.x = sectionInset.left + CGFloat(minWater.key) * (limitSize.width + columnSpacing)
                layoutAttribute.frame.origin.y = minWater.value + rowSpacing
                waterLengths[minWater.key] = layoutAttribute.frame.origin.y + layoutAttribute.frame.size.height
            } else {
                layoutAttribute.frame.origin.y = sectionInset.top + CGFloat(minWater.key) * (limitSize.height + rowSpacing)
                layoutAttribute.frame.origin.x = minWater.value + columnSpacing
                waterLengths[minWater.key] = layoutAttribute.frame.origin.x + layoutAttribute.frame.size.width
            }
        }
        return layoutAttribute
    }
    
    /// 计算的顶部/底部视图的布局
    fileprivate func getSupplementaryViewLayoutAttribute(ofKind elementKind: String, at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        guard let collectionView = collectionView else { return nil }
        let layoutAttribute = UICollectionViewLayoutAttributes(forSupplementaryViewOfKind: elementKind, with: indexPath)
        var supplementarySize: CGSize = .zero
        if let delegate = self.delegate {
            if elementKind == UICollectionElementKindSectionHeader {
                supplementarySize = delegate.collectionView?(collectionView, referenceSizeForHeaderInSection: indexPath.section) ?? .zero
            } else if elementKind == UICollectionElementKindSectionFooter {
                supplementarySize = delegate.collectionView?(collectionView, referenceSizeForFooterInSection: indexPath.section) ?? .zero
            }
        }
        layoutAttribute.frame.size = supplementarySize
        
        if scrollDirection == .vertical {
            layoutAttribute.frame.origin.x = self.sectionInset.left
            let lastLayoutBottom: CGFloat = layoutAttributes.map({ $0.frame.origin.y + $0.frame.size.height }).sorted(by: { $0 > $1 }).first ?? 0.0
            if elementKind == UICollectionElementKindSectionHeader {
                layoutAttribute.frame.origin.y = lastLayoutBottom + self.sectionInset.top
            } else if elementKind == UICollectionElementKindSectionFooter {
                layoutAttribute.frame.origin.y = lastLayoutBottom + self.sectionInset.bottom
            }
        } else {
            layoutAttribute.frame.origin.y = self.sectionInset.top
            let lastLayoutRight: CGFloat = layoutAttributes.map({ $0.frame.origin.x + $0.frame.size.width }).sorted(by: { $0 > $1 }).first ?? 0.0
            if elementKind == UICollectionElementKindSectionHeader {
                layoutAttribute.frame.origin.x = lastLayoutRight + self.sectionInset.left
            } else if elementKind == UICollectionElementKindSectionFooter {
                layoutAttribute.frame.origin.x = lastLayoutRight + self.sectionInset.right
            }
        }
        
        return layoutAttribute
    }
    
    // 获取 Cell 视图的布局，要重写【在移动/删除的时候会调用该方法】
    override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        return layoutAttributes.filter({ $0.indexPath == indexPath && $0.representedElementCategory == .cell }).first
    }
    
    // 获取 SupplementaryView 视图的布局
    override func layoutAttributesForSupplementaryView(ofKind elementKind: String, at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        return layoutAttributes.filter({ $0.indexPath == indexPath && $0.representedElementKind == elementKind }).first
    }
    
    // 此方法应该返回当前屏幕正在显示的视图的布局属性集合，要重写
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        return layoutAttributes.filter({ rect.intersects($0.frame) })
    }
    
    // collectionView 调用 performBatchUpdates 触发动画开始
    override func prepare(forCollectionViewUpdates updateItems: [UICollectionViewUpdateItem]) {
        super.prepare(forCollectionViewUpdates: updateItems)
        var willUpdateIndexPaths: [IndexPath] = []
        for updateItem in updateItems {
            switch updateItem.updateAction {
            case .insert:
                // 保持插入之后的列表索引
                if let indexPathAfterUpdate = updateItem.indexPathAfterUpdate {
                    willUpdateIndexPaths.append(indexPathAfterUpdate)
                }
            case .delete:
                // 保持删除之前的列表索引
                if let indexPathBeforeUpdate = updateItem.indexPathBeforeUpdate {
                    willUpdateIndexPaths.append(indexPathBeforeUpdate)
                }
            default:
                break
            }
        }
        self.updateIndexPaths = willUpdateIndexPaths
    }
    
    // 动画插入 cell 时调用
    override func initialLayoutAttributesForAppearingItem(at itemIndexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        if self.updateIndexPaths.contains(itemIndexPath) {
            if let attr = layoutAttributes.filter({ $0.indexPath == itemIndexPath }).first {
                attr.alpha = 0.0
                self.updateIndexPaths = self.updateIndexPaths.filter({ $0 != itemIndexPath })
                return attr
            }
        }
        return nil
    }
    
    // 动画删除 cell 时调用
    override func finalLayoutAttributesForDisappearingItem(at itemIndexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        if self.updateIndexPaths.contains(itemIndexPath) {
            if let attr = layoutAttributes.filter({ $0.indexPath == itemIndexPath }).first {
                attr.alpha = 0.0
                self.updateIndexPaths = self.updateIndexPaths.filter({ $0 != itemIndexPath })
                return attr
            }
        }
        return nil
    }
    
    // 结束动画
    override func finalizeCollectionViewUpdates() {
        super.finalizeCollectionViewUpdates()
        self.updateIndexPaths = []
    }
}
