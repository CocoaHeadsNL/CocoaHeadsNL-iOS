//
//  ButtonCell.swift
//  CocoaHeadsNL
//
//  Created by Jeroen Leenarts on 29-09-16.
//  Copyright © 2016 Stichting CocoaheadsNL. All rights reserved.
//

import UIKit

class ButtonCell: UITableViewCell {

    @IBOutlet weak var titleButton: UIButton!
    @IBAction func buttonPressed(_ sender: AnyObject) {
        if let url = selectURL() {
            UIApplication.shared.open(url, options: convertToUIApplicationOpenExternalURLOptionsKeyDictionary([:]), completionHandler: { _ in
            })
        }
    }

    fileprivate func selectURL() -> URL? {
        guard let urlString = urlString else {
            return nil
        }

        guard let url = URL(string: urlString) else {
            return nil
        }

        let appUrlString = "meetup:/\(url.path)"

        let appUrl = URL(string: appUrlString)

        if appUrl != nil && UIApplication.shared.canOpenURL(appUrl!) {
            return appUrl
        } else if UIApplication.shared.canOpenURL(url) {
            return url
        } else {
            return nil
        }
    }

    var title: String? {
        didSet {
            self.titleButton.setTitle(title, for: .normal)
        }
    }

    var urlString: String?
}

// Helper function inserted by Swift 4.2 migrator.
private func convertToUIApplicationOpenExternalURLOptionsKeyDictionary(_ input: [String: Any]) -> [UIApplication.OpenExternalURLOptionsKey: Any] {
	return Dictionary(uniqueKeysWithValues: input.map { key, value in (UIApplication.OpenExternalURLOptionsKey(rawValue: key), value) })
}
