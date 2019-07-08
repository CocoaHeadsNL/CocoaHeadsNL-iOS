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
            UIApplication.shared.open(url, options: [:], completionHandler: { (_) in
            })
        }
    }

    fileprivate func selectURL() -> URL? {
        guard let urlString = urlString else {
            //TODO: show warning
            return nil
        }

        guard let url = URL(string: urlString) else {
            //TODO: show warning
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
