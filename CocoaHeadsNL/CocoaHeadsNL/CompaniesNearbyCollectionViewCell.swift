//
//  CompaniesNearbyCollectionViewCell.swift
//  CocoaHeadsNL
//
//  Created by Bart Hoffman on 29/05/15.
//  Copyright (c) 2015 Stichting CocoaheadsNL. All rights reserved.
//

import Foundation

class CompaniesNearbyCollectionViewCell: PFCollectionViewCell {
    
    override func updateFromObject(object: PFObject?) {
        
        if let company = object as? Company {
            
            if let companyLogo = company.smallLogo {
                imageView.file = companyLogo
                imageView.frame = CGRect(x: 0, y: 0, width: 66, height: 66)
                imageView.image = UIImage(named: "CocoaHeadsNLLogo")
                imageView.contentMode = .ScaleAspectFit
                imageView.loadInBackground().continueWithSuccessBlock({[weak self] (task: BFTask!) -> AnyObject! in
                    self?.setNeedsLayout()
                    return nil
                    })
            }
            
            if let compName = company.name {
                textLabel.text = compName
                textLabel.font = UIFont.systemFontOfSize(8)
                textLabel.textAlignment = .Center
            }
        
            contentView.layer.borderWidth = (2.0 / UIScreen.mainScreen().scale) / 2
            contentView.layer.borderColor = UIColor.grayColor().CGColor
        }
    }
    
}
