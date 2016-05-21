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
                
                let request = NSURLRequest(URL: companyLogo.fileURL)
                let dataTask = NSURLSession.sharedSession().dataTaskWithRequest(request) { [weak self] data, response, error in
                    
                        if let imgView = self?.imageView, data = data {
                            let logo = UIImage(data: data)
                                imgView.image =  logo

                        }
                    }
                dataTask.resume()

            }
            
            if let compName = company.name {
                
            self.textLabel.text = compName

                
            }
        }
    }


}
