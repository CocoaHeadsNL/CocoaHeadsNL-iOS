//
//  CompanyCollectionViewCell.swift
//  CocoaHeadsNL
//
//  Created by Bart Hoffman on 29/05/15.
//  Copyright (c) 2015 Stichting CocoaheadsNL. All rights reserved.
//

import Foundation

class CompanyCloseCollectionViewCell: PFCollectionViewCell {
    
    override func updateFromObject(object: PFObject?) {
        
        if let company = object as? Company {
            
            if let companyLogo = company.logo {
                imageView.file = companyLogo
                imageView.frame = CGRect(x: 0, y: 0, width: self.contentView.frame.width, height: 70)
                imageView.image = UIImage(named: "CocoaHeadsNLLogo")
                imageView.contentMode = .ScaleAspectFit
                imageView.loadInBackground().continueWithSuccessBlock({[weak self] (task: BFTask!) -> AnyObject! in
                    self?.setNeedsLayout()
                    return nil
                    })
            }
            
            if let place = company.place {
                textLabel.text = place
                textLabel.font = UIFont.systemFontOfSize(8)
                textLabel.textAlignment = .Center
            }
        
            contentView.layer.borderWidth = (2.0 / UIScreen.mainScreen().scale) / 2
            contentView.layer.borderColor = UIColor.grayColor().CGColor
        }
    }
    
}
