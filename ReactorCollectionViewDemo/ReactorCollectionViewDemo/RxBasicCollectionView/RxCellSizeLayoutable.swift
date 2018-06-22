//
//  RxCellSizeLayoutable.swift
//  RxTodo
//
//  Created by luhe liu on 2018/5/17.
//  Copyright © 2018年 Suyeol Jeon. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import RxDataSources

/// 列表布局协议
public protocol RxCellSizeLayoutable {
    var dataSource: RxCollectionViewSectionedReloadDataSource<RxBasicListModel> { get }
    func getCellSize(indexPath: IndexPath) -> CGSize
    func getFooterSize(section: Int) -> CGSize
    func getHeaderSize(section: Int) -> CGSize
}

/// 协议默认实现
extension RxCellSizeLayoutable {
    public func getCellSize(indexPath: IndexPath) -> CGSize {
        if let section = dataSource.sectionModels.safeIndex(indexPath.section) {
            if let item = section.items.safeIndex(indexPath.row) {
                return item.cellSize
            }
        }
        return .zero
    }
    
    public func getFooterSize(section: Int) -> CGSize {
        if let section = dataSource.sectionModels.safeIndex(section) {
            return section.model.footerSize
        }
        return .zero
    }
    
    public func getHeaderSize(section: Int) -> CGSize {
        if let section = dataSource.sectionModels.safeIndex(section) {
            return section.model.headerSize
        }
        return .zero
    }
}
