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
    
    private var imageLoaded = false
    
    var job: Job? {
        didSet {
            if job?.link != oldValue?.link {
                imageView.image = UIImage(named: "CocoaHeadsNLLogo")
                imageLoaded = false
            }
            
            self.textLabel.text = job?.title
            if  let url = job?.logo?.fileURL where !imageLoaded {
                dispatch_async(dispatch_get_global_queue(QOS_CLASS_USER_INITIATED, 0)) {
                    let contentsOfURL = NSData(contentsOfURL: url)
                    dispatch_async(dispatch_get_main_queue()) {
                        if self.job?.logo?.fileURL == url {
                            if let imageData = contentsOfURL {
                                self.imageLoaded = true
                                self.imageView?.image = UIImage(data: imageData)
                            }
                        } else {
                            // just so you can see in the console when this happens
                            print("ignored data returned from url \(url)")
                        }
                    }
                }
            }
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        
        // Initialization code
        contentView.layer.borderWidth = (2.0 / UIScreen.mainScreen().scale) / 2
        contentView.layer.borderColor = UIColor.grayColor().CGColor
   }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        self.textLabel.text = ""
        //self.imageView.image = nil
    }
}
