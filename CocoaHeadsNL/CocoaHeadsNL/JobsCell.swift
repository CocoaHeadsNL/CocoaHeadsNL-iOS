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
            self.imageView.image = job?.logoImage
            
            self.textLabel.text = job?.title
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
