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
        guard let urlString = urlString else {
            //TODO show warning
            return
        }

        guard let url = URL(string: urlString) else {
            //TODO show warning
            return
        }
        
        let appUrlString = "meetup:/\(url.path)"

        let appUrl = URL(string: appUrlString)
        
        if appUrl != nil && UIApplication.shared.canOpenURL(appUrl!) {
            UIApplication.shared.openURL(appUrl!)
        } else if UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.openURL(url)
        }
    }
    
    var title: String? {
        didSet {
            self.titleButton.setTitle(title, for: .normal)
        }
    }
    
    var urlString: String?
}
