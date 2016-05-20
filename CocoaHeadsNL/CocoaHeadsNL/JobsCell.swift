//
//  JobsCell.swift
//  CocoaHeadsNL
//
//  Created by Bart Hoffman on 10/03/16.
//  Copyright © 2016 Stichting CocoaheadsNL. All rights reserved.
//

import UIKit

class JobsCell: UICollectionViewCell {
    
    @IBOutlet weak var textLabel: UILabel!
    @IBOutlet weak var imageView: UIImageView!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        self.textLabel.text = ""
    }
    
    func updateFromObject(object: NSObject?)
    {
        if let job = object as? Job {
            
            if let logoFile = job.logo {
                
                let request = NSURLRequest(URL: logoFile.fileURL)
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
            
            if let title = job.title {
                
                self.textLabel.frame = CGRectMake(0, 70, 140, 20)
                self.textLabel.text = title
                self.textLabel.font = UIFont.systemFontOfSize(8)
                self.textLabel.textAlignment = .Center
            }
            
            contentView.layer.borderWidth = (2.0 / UIScreen.mainScreen().scale) / 2
            contentView.layer.borderColor = UIColor.grayColor().CGColor
        }
    }

}
