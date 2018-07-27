//
//  RxTableViewLayoutSource.swift
//  ReactorTableViewDemo
//
//  Created by luhe liu on 2018/7/26.
//  Copyright © 2018年 luhe liu. All rights reserved.
//

import UIKit


/// 列表布局配置对象，用来配置列表布局属性
open class RxTableViewLayoutSource {
    public typealias HeightForRowFactory = (IndexPath) -> CGFloat
    public typealias SectionHeightFactory = (Int) -> CGFloat
    
    open var heightForRow: Layout<IndexPath, CGFloat> = Layout<IndexPath, CGFloat>()
    open var heightForHeader: Layout<Int, CGFloat>  = Layout<Int, CGFloat>()
    open var heightForFooter: Layout<Int, CGFloat>  = Layout<Int, CGFloat>()
    open var estimatedHeightForRow: Layout<IndexPath, CGFloat> = Layout<IndexPath, CGFloat>()
    open var estimatedHeightForHeader: Layout<Int, CGFloat>  = Layout<Int, CGFloat>()
    open var estimatedHeightForFooter: Layout<Int, CGFloat>  = Layout<Int, CGFloat>()
    
    /// 配置 Cell 大小
    open var configureHeightForRow: HeightForRowFactory? {
        didSet {
            if let configureHeightForRow = configureHeightForRow {
                heightForRow.factory = configureHeightForRow
            }
        }
    }
    
    /// 配置顶部控件大小
    open var configureHeaderHeight: SectionHeightFactory? {
        didSet {
            if let configureHeaderHeight = configureHeaderHeight {
                heightForHeader.factory = configureHeaderHeight
            }
        }
    }
    
    /// 配置底部控件大小
    open var configureFooterHeight: SectionHeightFactory? {
        didSet {
            if let configureFooterHeight = configureFooterHeight {
                heightForFooter.factory = configureFooterHeight
            }
        }
    }
    
    /// 配置 Cell 大小
    open var configureEstimatedHeightForRow: HeightForRowFactory? {
        didSet {
            if let configureEstimatedHeightForRow = configureEstimatedHeightForRow {
                estimatedHeightForRow.factory = configureEstimatedHeightForRow
            }
        }
    }
    
    /// 配置顶部控件大小
    open var configureHeaderEstimatedHeight: SectionHeightFactory? {
        didSet {
            if let configureHeaderEstimatedHeight = configureHeaderEstimatedHeight {
                estimatedHeightForHeader.factory = configureHeaderEstimatedHeight
            }
        }
    }
    
    /// 配置底部控件大小
    open var configureFooterEstimatedHeight: SectionHeightFactory? {
        didSet {
            if let configureFooterEstimatedHeight = configureFooterEstimatedHeight {
                estimatedHeightForFooter.factory = configureFooterEstimatedHeight
            }
        }
    }
}
