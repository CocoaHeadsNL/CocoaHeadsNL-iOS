//
//  CompanyCollectionViewCell.swift
//  CocoaHeadsNL
//
//  Created by Bart Hoffman on 29/05/15.
//  Copyright (c) 2015 Stichting CocoaheadsNL. All rights reserved.
//

import Foundation

class CompanyCollectionViewCell: PFCollectionViewCell {
    
    override func updateFromObject(object: PFObject?) {
        
        if let company = object as? Company {
            
            if let companyLogo = company.logo {
                imageView.file = companyLogo
                imageView.frame = CGRect(x: 0, y: 5, width: 140, height: 70)
                imageView.image = UIImage(named: "CocoaHeadsNLLogo")
                imageView.contentMode = .ScaleAspectFit
                imageView.loadInBackground({[weak self] (image, error) -> Void in
                    if error == nil {
                        self?.layoutIfNeeded()
                    }
                })
            
            }
            
            if let place = company.place {
                textLabel.text = place
                textLabel.font = UIFont.systemFontOfSize(8)
                textLabel.textAlignment = .Center
            }
        
            contentView.layer.borderWidth = 0.5
            contentView.layer.borderColor = UIColor.grayColor().CGColor
        }
    }
    
}
