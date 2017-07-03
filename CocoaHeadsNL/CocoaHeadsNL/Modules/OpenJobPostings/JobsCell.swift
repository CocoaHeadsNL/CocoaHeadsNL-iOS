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
    @IBOutlet weak var separator: UIView!

    fileprivate var imageLoaded = false

    var job: Job? {
        didSet {
            self.imageView.image = job?.logoImage
            self.textLabel.text = job?.title
        }
    }

    var rightHandSide = false {
        didSet {
            self.separator.isHidden = rightHandSide
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()

        // Show a darker background when the cell is tapped (just like the
        // table view cells in the Meetups tab).
        let selectedView = UIView()
        selectedView.backgroundColor = UIColor(red: 0.85, green: 0.85, blue: 0.85, alpha: 1)
        self.selectedBackgroundView = selectedView
    }

    override func prepareForReuse() {
        super.prepareForReuse()

        self.textLabel.text = ""
        //self.imageView.image = nil
    }
}
