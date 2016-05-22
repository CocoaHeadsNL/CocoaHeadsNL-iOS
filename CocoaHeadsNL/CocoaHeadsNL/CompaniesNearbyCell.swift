//
//  CompaniesNearbyCell.swift
//  CocoaHeadsNL
//
//  Created by Bart Hoffman on 10/03/16.
//  Copyright © 2016 Stichting CocoaheadsNL. All rights reserved.
//

import UIKit

class CompaniesNearbyCell: UICollectionViewCell {

    @IBOutlet weak var textLabel: UILabel!
    @IBOutlet weak var imageView: UIImageView!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.imageView?.image = UIImage(named: "MeetupPlaceholder")
    }

    func updateFromObject(company: Company) {

        if let companyLogo = company.smallLogo {

            if let data = NSData(contentsOfURL: companyLogo.fileURL) {
                self.imageView?.image =  UIImage(data: data)!
            }
        }

        if let compName = company.name {
            self.textLabel.text = compName
        }
    }
}
