//
//  RxCollectionViewDelegateLayoutSource.swift
//  ifanr
//
//  Created by luhe liu on 17/8/9.
//  Copyright © 2017年 ifanr. All rights reserved.
//

import UIKit

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

open class Layout<Input, Output: Zeroable> {
    open var factory: (Input) -> Output = { _ in
        return Output.zero
    }
    
    open func at(_ index: Input) -> Output {
        return factory(index)
    }
}

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
    
    open var configureSizeForCell: SizeForCellFactory? {
        didSet {
            if let configureSizeForCell = configureSizeForCell {
                sizeForCell.factory = configureSizeForCell
            }
        }
    }
    open var configureHeaderSize: SupplementaryViewSizeFactory? {
        didSet {
            if let configureHeaderSize = configureHeaderSize {
                sizeForHeader.factory = configureHeaderSize
            }
        }
    }
    open var configureFooterSize: SupplementaryViewSizeFactory? {
        didSet {
            if let configureFooterSize = configureFooterSize {
                sizeForFooter.factory = configureFooterSize
            }
        }
    }
    open var configureMinLineSpacing: SpacingFactory? {
        didSet {
            if let configureMinLineSpacing = configureMinLineSpacing {
                minLineSpacing.factory = configureMinLineSpacing
            }
        }
    }
    open var configureMinInteritemSpacing: SpacingFactory? {
        didSet {
            if let configureMinInteritemSpacing = configureMinInteritemSpacing {
                minInteritemSpacing.factory = configureMinInteritemSpacing
            }
        }
    }
    open var configureInsetForSection: EdgeInsetsFactory? {
        didSet {
            if let configureInsetForSection = configureInsetForSection {
                insetForSection.factory = configureInsetForSection
            }
        }
    }
}
