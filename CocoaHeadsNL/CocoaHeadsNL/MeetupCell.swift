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
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateStyle = .MediumStyle
        dateFormatter.timeStyle = .ShortStyle
        dateFormatter.dateFormat = "HH:mm a"
        return dateFormatter
    }()

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var logoImageView: PFImageView!
    @IBOutlet weak var dateContainer: UIView!
    @IBOutlet weak var dayLabel: UILabel!
    @IBOutlet weak var monthLabel: UILabel!
    @IBOutlet weak var widthConstraint: NSLayoutConstraint!

    let circleLayer: CAShapeLayer = {
        let circleLayer = CAShapeLayer()
        circleLayer.contentsScale = UIScreen.mainScreen().scale
        circleLayer.position = CGPoint(x: 8, y: 12)
        circleLayer.path = UIBezierPath(roundedRect: CGRect(x: 0, y: 0, width: 48, height: 48), cornerRadius: 6).CGPath
        circleLayer.lineWidth = 2
        return circleLayer
    }()

    let trackLayer: CAShapeLayer = {
        let trackLayer = CAShapeLayer()
        trackLayer.contentsScale = UIScreen.mainScreen().scale
        trackLayer.position = CGPoint(x: 8 + 48/2 - 1, y: 0)
        trackLayer.strokeColor = UIColor.clearColor().CGColor
        trackLayer.fillColor = UIColor.blackColor().CGColor
        return trackLayer
    }()

    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        self.layer.insertSublayer(circleLayer, atIndex: 0)
        self.layer.insertSublayer(trackLayer, atIndex: 0)
    }

    override func prepareForReuse() {
        super.prepareForReuse()

        titleLabel.text = ""
        timeLabel.text = ""
        dayLabel.text = ""
        monthLabel.text = ""

        logoImageView.file = nil

        if let image = UIImage(named: "MeetupPlaceholder") {
            logoImageView.image = image
            widthConstraint.constant = image.size.width
        }
    }

    func configureCellForMeetup(meetup: Meetup, row: Int) {
        titleLabel.text = meetup.name

        CATransaction.begin()
        CATransaction.setDisableActions(true)

        if let date = meetup.time {
            let timeText = MeetupCell.dateFormatter.stringFromDate(date)
            //timeLabel.text = String(format: "%@ - %@", timeText, meetup.locationName ?? "Location unknown")
            timeLabel.text = timeText

            let components = NSCalendar.currentCalendar().components(.CalendarUnitMonth | .CalendarUnitDay, fromDate: date)
            dayLabel.text = String(format: "%d", components.day)

            let months = ["JAN", "FEB", "MAR", "APR", "MAY", "JUN", "JUL", "AUG", "SEPT", "OCT", "NOV", "DEC"]
            monthLabel.text = months[components.month - 1]

            if date.timeIntervalSinceNow > 0 {
                circleLayer.strokeColor = UIColor.blackColor().CGColor
                circleLayer.fillColor = UIColor.whiteColor().CGColor
                dayLabel.textColor = UIColor.blackColor()
                monthLabel.textColor = UIColor.blackColor()
            } else {
                circleLayer.strokeColor = UIColor.blackColor().CGColor
                circleLayer.fillColor = UIColor.blackColor().CGColor
                dayLabel.textColor = UIColor.whiteColor()
                monthLabel.textColor = UIColor.whiteColor()
            }
        }

        if row == 0 {
            trackLayer.path = UIBezierPath(rect: CGRect(x: 0, y: 20, width: 2, height: 132 - 20)).CGPath
        } else {
            trackLayer.path = UIBezierPath(rect: CGRect(x: 0, y: 0, width: 2, height: 132)).CGPath
        }

        CATransaction.commit()

        // Loading large images and resizing them is pretty inefficient.
        // It would be better if the server already gave us a -- transparent -- 
        // image of 44 pts high. Or we could cache these thumbnails locally.

        if let logoFile = meetup.logo {
            logoImageView.file = logoFile
            logoImageView.loadInBackground({ image, _ in
                if let image = image {
                    let resizedImage = image.resizedImageWithBounds(CGSize(width: 100, height: 44))
                    self.logoImageView.image = resizedImage
                    self.widthConstraint.constant = resizedImage.size.width
                }
            })
        }
    }
}
