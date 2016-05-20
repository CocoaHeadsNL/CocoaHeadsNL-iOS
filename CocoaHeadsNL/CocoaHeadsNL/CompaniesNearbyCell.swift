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
                    
                    let priority = DISPATCH_QUEUE_PRIORITY_DEFAULT
                    dispatch_async(dispatch_get_global_queue(priority, 0)) {
                        // do task
                        
                        if let imgView = self?.imageView, data = data {
                            let logo = UIImage(data: data)
                            
                            dispatch_async(dispatch_get_main_queue()) {
                                // update UI
                                imgView.image =  logo
                            }
                        }
                        
                    }
                }
                dataTask.resume()

            }
            
            if let compName = company.name {
            self.textLabel.text = compName
            self.textLabel.font = UIFont.systemFontOfSize(10)
            self.textLabel.textAlignment = .Center
                
            }
        }
    }


}
