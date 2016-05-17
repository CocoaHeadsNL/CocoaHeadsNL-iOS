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
    
    func updateFromObject(object: NSObject?)
    {
        if let job = object as? Job {
            
            let frameForImage = CGRect(x: 0, y: 0, width: self.contentView.frame.width, height: 70)
            self.imageView.frame = CGRectInset(frameForImage, 5, 5)
            self.imageView.clipsToBounds = true
            self.imageView.contentMode = .ScaleAspectFit
            self.imageView.image = UIImage(named: "CocoaHeadsNLLogo")
            
            if let logoFile = job.logo {
                if let data = NSData(contentsOfURL: logoFile.fileURL) {
                    self.imageView?.image =  UIImage(data: data)!
                    self.setNeedsLayout()
                }
                
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
