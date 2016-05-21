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
    
    var jobItem = Job()
    

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        self.textLabel.text = ""
        self.imageView.image = nil
    }
    
    func updateFromObject(object: NSObject?)
    {
        if let job = object as? Job {

            if let logoFile = job.logo {
                
                let request = NSURLRequest(URL: logoFile.fileURL)
                let dataTask = NSURLSession.sharedSession().dataTaskWithRequest(request) { [weak self] data, response, error in

                        if let imgView = self?.imageView, data = data {
                            let logo = UIImage(data: data)
                            imgView.image =  logo

                        }
                }
                dataTask.resume()
            }
            
            if let title = job.title {
                
                self.textLabel.text = title
            }
            
            contentView.layer.borderWidth = (2.0 / UIScreen.mainScreen().scale) / 2
            contentView.layer.borderColor = UIColor.grayColor().CGColor
        }
    }
}
