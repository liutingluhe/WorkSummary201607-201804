//
//  RxRowHeightLayoutable.swift
//  ReactorTableViewDemo
//
//  Created by luhe liu on 2018/7/26.
//  Copyright © 2018年 luhe liu. All rights reserved.
//
import UIKit
import RxSwift
import RxCocoa
import RxDataSources

/// 列表布局协议
public protocol RxRowHeightLayoutable {
    associatedtype DataSourceType: TableViewSectionedDataSource<RxBasicListModel> & RxTableViewDataSourceType
    var dataSource: DataSourceType { get }
    func getRowHeight(indexPath: IndexPath) -> CGFloat
    func getFooterHeight(section: Int) -> CGFloat
    func getHeaderHeight(section: Int) -> CGFloat
}

/// 协议默认实现
extension RxRowHeightLayoutable {
    public func getRowHeight(indexPath: IndexPath) -> CGFloat {

        if let section = dataSource.sectionModels.safeIndex(indexPath.section) {
            if let item = section.items.safeIndex(indexPath.row) {
                return item.cellSize.height
            }
        }
        return 0
    }
    
    public func getFooterHeight(section: Int) -> CGFloat {
        if let section = dataSource.sectionModels.safeIndex(section) {
            return section.model.footerSize.height
        }
        return 0
    }
    
    public func getHeaderHeight(section: Int) -> CGFloat {
        if let section = dataSource.sectionModels.safeIndex(section) {
            return section.model.headerSize.height
        }
        return 0
    }
}
