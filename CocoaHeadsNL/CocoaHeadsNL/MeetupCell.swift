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

    let circleLayer: CAShapeLayer = {
        let circleLayer = CAShapeLayer()
        circleLayer.contentsScale = UIScreen.mainScreen().scale
        circleLayer.position = CGPoint(x: 16, y: 16)
        circleLayer.path = UIBezierPath(ovalInRect: CGRect(x: 0, y: 0, width: 56, height: 56)).CGPath
        circleLayer.lineWidth = 2
        return circleLayer
    }()

    let trackLayer: CAShapeLayer = {
        let trackLayer = CAShapeLayer()
        trackLayer.contentsScale = UIScreen.mainScreen().scale
        trackLayer.position = CGPoint(x: 43, y: 0)
        trackLayer.path = UIBezierPath(rect: CGRect(x: 0, y: 0, width: 2, height: 132)).CGPath
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
        logoImageView.image = UIImage(named: "MeetupPlaceholder")
    }

    func configureCellForMeetup(meetup: Meetup, isFirst: Bool) {
        titleLabel.text = meetup.name

        if let date = meetup.time {
            let timeText = MeetupCell.dateFormatter.stringFromDate(date)
            timeLabel.text = String(format: "%@ - %@", timeText, meetup.locationName ?? "Location unknown")

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

        trackLayer.position = CGPoint(x: 43, y: isFirst ? 43 : 0)

        // Loading large images and resizing them is pretty inefficient. 
        // It would be better if the server already gave us a -- transparent -- 
        // image of 44 pts high. Or we could cache these thumbnails locally.

        if let logoFile = meetup.logo {
            logoImageView.file = logoFile
            logoImageView.loadInBackground({ image, _ in
                if let image = image {
                    self.logoImageView.image = image.resizedImageWithBounds(CGSize(width: DBL_MAX, height: 44))
                }
            })
        }
    }
}
