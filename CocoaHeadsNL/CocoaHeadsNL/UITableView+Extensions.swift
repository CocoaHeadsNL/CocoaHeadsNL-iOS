//
//  UITableView+Extensions.swift
//  CocoaHeadsNL
//
//  Created by Jeroen Leenarts on 10/01/2020.
//  Copyright © 2020 Stichting CocoaheadsNL. All rights reserved.
//

import UIKit

extension UICollectionView {

    func register<T: Identifiable>(type: T.Type, ofKind kind: String, prefix: String = "") where T: UICollectionReusableView {
        register(type, forSupplementaryViewOfKind: kind, withReuseIdentifier: prefix + type.identifier)
    }

    func registerNib<T: Identifiable>(type: T.Type, prefix: String = "") where T: UICollectionViewCell {
        register(UINib(nibName: type.identifier, bundle: nil), forCellWithReuseIdentifier: prefix + type.identifier)
    }

    func dequeueReusableSupplementaryView<T: Identifiable>(ofKind kind: String, type: T.Type, for indexPath: IndexPath, prefix: String = "") -> T where T: UICollectionReusableView {

        return dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: prefix + type.identifier, for: indexPath) as! T // swiftlint:disable:this force_cast
    }

    func dequeueReusableCell<T: Identifiable>(type: T.Type, for indexPath: IndexPath, prefix: String = "") -> T where T: UICollectionViewCell {
        return dequeueReusableCell(withReuseIdentifier: prefix + type.identifier, for: indexPath) as! T // swiftlint:disable:this force_cast
    }
}

extension UITableView {

    func register<T: Identifiable>(type: T.Type, prefix: String = "") where T: UITableViewCell {
        register(type, forCellReuseIdentifier: prefix + type.identifier)
    }

    func dequeueReusableCell<T: Identifiable>(type: T.Type, for indexPath: IndexPath, prefix: String = "") -> T where T: UITableViewCell {
        return dequeueReusableCell(withIdentifier: prefix + type.identifier, for: indexPath) as! T // swiftlint:disable:this force_cast
    }

    func registerNib<T: Identifiable>(type: T.Type, prefix: String = "") where T: UITableViewCell {
        let nib = UINib(nibName: prefix + type.identifier, bundle: nil)
        register(nib, forCellReuseIdentifier: prefix + type.identifier)
    }

    func registerNib<T: Identifiable>(type: T.Type, prefix: String = "") where T: UITableViewHeaderFooterView {
        let nib = UINib(nibName: prefix + type.identifier, bundle: nil)
        register(nib, forHeaderFooterViewReuseIdentifier: prefix + type.identifier)
    }

    func dequeueReusableHeaderFooterView<T: Identifiable>(type: T.Type, prefix: String = "") -> T where T: UITableViewHeaderFooterView {
        return dequeueReusableHeaderFooterView(withIdentifier: prefix + type.identifier) as! T // swiftlint:disable:this force_cast
    }
}
