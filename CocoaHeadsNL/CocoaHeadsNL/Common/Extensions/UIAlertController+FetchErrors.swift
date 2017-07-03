//
//  UIAlertController+FetchErrors.swift
//  CocoaHeadsNL
//
//  Created by Bruno Scheele on 18/01/2017.
//  Copyright © 2017 Stichting CocoaheadsNL. All rights reserved.
//

import UIKit

extension UIAlertController {
    /// Returns a UIAlertController with the .alert style for a failed fetch request.
    ///
    /// - Parameter fetching: What failed to fetch. Will be prefixed with 'the list of ' (e.g. 'the list of <jobs>')
    /// - Returns: A UIAlertController to display.
    static func fetchErrorDialog(whileFetching fetching:String, error: Error) -> UIAlertController {
        let title = NSLocalizedString("Fetch failed")
        let message = String(format: NSLocalizedString("There was a problem fetching the list of %@; please try again.\n%@"), fetching, error.localizedDescription)
        let okButtonTitle = NSLocalizedString("OK")
        
        let ac = UIAlertController(title: title, message: message, preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: okButtonTitle, style: .default, handler: nil))
        return ac
    }
}
