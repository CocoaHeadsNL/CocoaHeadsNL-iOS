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
    
    func updateFromObject(object: NSObject?) {
        
        if let company = object as? Company {
            
            if let companyLogo = company.smallLogo {
             
                self.imageView?.image = UIImage(named: "MeetupPlaceholder")

                if let data = NSData(contentsOfURL: companyLogo.fileURL) {
                    self.imageView?.image =  UIImage(data: data)!
                    self.setNeedsLayout()
                }


            }
            
            if let compName = company.name {
            self.textLabel.text = compName
            self.textLabel.font = UIFont.systemFontOfSize(10)
            self.textLabel.textAlignment = .Center
                
            }
        }
    }


}
