//
//  Identifiable.swift
//  CocoaHeadsNL
//
//  Created by Jeroen Leenarts on 10/01/2020.
//  Copyright © 2020 Stichting CocoaheadsNL. All rights reserved.
//

import UIKit

public protocol Identifiable: class {
    static var identifier: String { get }
}

public extension Identifiable {

    static var identifier: String {
        return String(describing: Self.self)
    }
}

extension UIStoryboard {

    public func instantiateViewController<T: Identifiable>(type: T.Type) -> T where T: UIViewController {
        return instantiateViewController(withIdentifier: type.identifier) as! T // swiftlint:disable:this force_cast
    }
}
