//
//  RxCollectionViewDelegateLayoutSource.swift
//  ifanr
//
//  Created by luhe liu on 17/8/9.
//  Copyright © 2017年 ifanr. All rights reserved.
//

import UIKit

/// 描述数据为空的协议，满足有个 zero 属性表示数据为空
public protocol Zeroable {
    static var zero: Self { get }
}

extension CGSize: Zeroable { }
extension CGRect: Zeroable { }
extension UIEdgeInsets: Zeroable { }

extension CGFloat: Zeroable {
    public static var zero: CGFloat {
        return 0.0
    }
}

/// 工具类，用于快捷配置布局
open class Layout<Input, Output: Zeroable> {
    open var factory: (Input) -> Output = { _ in
        return Output.zero
    }
    
    open func at(_ index: Input) -> Output {
        return factory(index)
    }
}

/// 列表布局配置对象，用来配置列表布局属性
open class CollectionViewLayoutSource {
    
    public typealias SizeForCellFactory = (IndexPath) -> CGSize
    public typealias SupplementaryViewSizeFactory = (Int) -> CGSize
    public typealias SpacingFactory = (Int) -> CGFloat
    public typealias EdgeInsetsFactory = (Int) -> UIEdgeInsets
    
    open var sizeForCell: Layout<IndexPath, CGSize> = Layout<IndexPath, CGSize>()
    open var sizeForHeader: Layout<Int, CGSize>  = Layout<Int, CGSize>()
    open var sizeForFooter: Layout<Int, CGSize>  = Layout<Int, CGSize>()
    open var insetForSection: Layout<Int, UIEdgeInsets>  = Layout<Int, UIEdgeInsets>()
    open var minLineSpacing: Layout<Int, CGFloat>  = Layout<Int, CGFloat>()
    open var minInteritemSpacing: Layout<Int, CGFloat>  = Layout<Int, CGFloat>()
    
    /// 配置 Cell 大小
    open var configureSizeForCell: SizeForCellFactory? {
        didSet {
            if let configureSizeForCell = configureSizeForCell {
                sizeForCell.factory = configureSizeForCell
            }
        }
    }
    
    /// 配置顶部控件大小
    open var configureHeaderSize: SupplementaryViewSizeFactory? {
        didSet {
            if let configureHeaderSize = configureHeaderSize {
                sizeForHeader.factory = configureHeaderSize
            }
        }
    }
    
    /// 配置底部控件大小
    open var configureFooterSize: SupplementaryViewSizeFactory? {
        didSet {
            if let configureFooterSize = configureFooterSize {
                sizeForFooter.factory = configureFooterSize
            }
        }
    }
    
    /// 配置最小行间距
    open var configureMinLineSpacing: SpacingFactory? {
        didSet {
            if let configureMinLineSpacing = configureMinLineSpacing {
                minLineSpacing.factory = configureMinLineSpacing
            }
        }
    }
    
    /// 配置最小列间距
    open var configureMinInteritemSpacing: SpacingFactory? {
        didSet {
            if let configureMinInteritemSpacing = configureMinInteritemSpacing {
                minInteritemSpacing.factory = configureMinInteritemSpacing
            }
        }
    }
    
    /// 配置组间距
    open var configureInsetForSection: EdgeInsetsFactory? {
        didSet {
            if let configureInsetForSection = configureInsetForSection {
                insetForSection.factory = configureInsetForSection
            }
        }
    }
}
