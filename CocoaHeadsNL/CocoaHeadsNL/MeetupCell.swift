//
//  MeetupCell.swift
//  CocoaHeadsNL
//
//  Created by Matthijs Hollemans on 25-05-15.
//  Copyright (c) 2015 Stichting CocoaheadsNL. All rights reserved.
//

import Foundation

class MeetupCell: PFTableViewCell {
    static let Identifier = "meetupCell"

    static let dateFormatter: NSDateFormatter = {
        println("YEAY")
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateStyle = .MediumStyle
        dateFormatter.timeStyle = .ShortStyle
        dateFormatter.dateFormat = "d MMMM, HH:mm a"
        return dateFormatter
    }()

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: .Subtitle, reuseIdentifier: reuseIdentifier)
    }

    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override func prepareForReuse() {
        super.prepareForReuse()

        if let textLabel = self.textLabel {
            textLabel.adjustsFontSizeToFitWidth = true
            textLabel.text = ""
        }

        if let detailTextLabel = self.detailTextLabel {
            detailTextLabel.text = ""
        }

        if let imageView = self.imageView {
            imageView.file = nil
            imageView.image = UIImage(named: "CocoaHeadsNLLogo")
            imageView.layer.contentsGravity = kCAGravityCenter
            imageView.contentMode = .ScaleAspectFit
        }
    }

    func configureCellForMeetup(meetup: Meetup) {
        if let textLabel = self.textLabel {
            textLabel.text = meetup.name
        }

        if let detailTextLabel = self.detailTextLabel, date = meetup.time {
            detailTextLabel.text = MeetupCell.dateFormatter.stringFromDate(date)
        }

        if let imageView = self.imageView, logoFile = meetup.logo {
            imageView.file = logoFile
            imageView.loadInBackground(nil)
        }
    }
}
