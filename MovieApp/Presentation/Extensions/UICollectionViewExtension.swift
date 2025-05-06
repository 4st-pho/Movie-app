//
//  UICollectionViewExtension.swift
//  MovieApp
//
//  Created by MACBOOK PRO on 3/5/25.
//

import Foundation
import UIKit

extension UICollectionView {
    func register(cellType: UICollectionViewCell.Type) {
        let className = cellType.className
        register(cellType, forCellWithReuseIdentifier: className)
    }

    func register(cellTypes: [UICollectionViewCell.Type]) {
        cellTypes.forEach(register(cellType:))
    }
    
    func register(nibType: UICollectionViewCell.Type) {
        let className = nibType.className
        let nib = UINib(nibName: className, bundle: nil)
        register(nib, forCellWithReuseIdentifier: className)
    }
    
    func register(nibTypes: [UICollectionViewCell.Type]) {
        nibTypes.forEach { register(nibType: $0) }
    }

    func register(sectionHeaderViewType viewType: UICollectionReusableView.Type) {
        register(reusableViewType: viewType, ofKind: Self.elementKindSectionHeader)
    }

    func register(sectionHeaderViewTypes viewTypes: [UICollectionReusableView.Type]) {
        register(reusableViewTypes: viewTypes, ofKind: Self.elementKindSectionHeader)
    }

    func register(sectionFooterViewType viewType: UICollectionReusableView.Type) {
        register(reusableViewType: viewType, ofKind: Self.elementKindSectionFooter)
    }

    func register(sectionFooterViewTypes viewTypes: [UICollectionReusableView.Type]) {
        register(reusableViewTypes: viewTypes, ofKind: Self.elementKindSectionFooter)
    }

    var widestCellWidth: CGFloat {
        let insets = contentInset.left + contentInset.right
        return bounds.width - insets
    }
}

public extension UICollectionView {
    func register(reusableViewType: UICollectionReusableView.Type, ofKind kind: String) {
        let className = reusableViewType.className
        register(reusableViewType, forSupplementaryViewOfKind: kind, withReuseIdentifier: className)
    }

    func register(reusableViewTypes: [UICollectionReusableView.Type], ofKind kind: String) {
        reusableViewTypes.forEach { register(reusableViewType: $0, ofKind: kind) }
    }

    func dequeueReusableCell<T: UICollectionViewCell>(with type: T.Type,
                                                      for indexPath: IndexPath) -> T {
        dequeueReusableCell(withReuseIdentifier: type.className, for: indexPath) as! T
    }

    func dequeueReusableView<T: UICollectionReusableView>(with type: T.Type,
                                                          for indexPath: IndexPath,
                                                          ofKind kind: String) -> T {
        dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: type.className, for: indexPath) as! T
    }
}
