//
//  OnlineCell.swift
//  CocoaHeadsNL
//
//  Created by Jeroen Leenarts on 19/04/2020.
//  Copyright © 2020 Stichting CocoaheadsNL. All rights reserved.
//

import UIKit

class OnlineCell: UITableViewCell {

    @IBOutlet weak var onlineButton: UIButton!
    @IBAction func buttonPressed(_ sender: AnyObject) {
        if let url = URL(string: "https://youtube.com/stichtingcocoaheadsnl"), UIApplication.shared.canOpenURL(url) {
        UIApplication.shared.open(url, options: [:], completionHandler: { _ in
            })
        }
    }

}

extension OnlineCell: Identifiable {}
