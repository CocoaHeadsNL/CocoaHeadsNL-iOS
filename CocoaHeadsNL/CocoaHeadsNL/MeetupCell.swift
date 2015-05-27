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
    @IBOutlet weak var separatorView: UIView!
    @IBOutlet weak var dateContainer: UIView!
    @IBOutlet weak var calendarImageView: UIImageView!
    @IBOutlet weak var dayLabel: UILabel!
    @IBOutlet weak var monthLabel: UILabel!

    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func prepareForReuse() {
        super.prepareForReuse()

        titleLabel.text = ""
        timeLabel.text = ""
        dayLabel.text = ""
        monthLabel.text = ""

        separatorView.hidden = false
        logoImageView.file = nil

        if let image = UIImage(named: "MeetupPlaceholder") {
            logoImageView.image = image
        }
    }

    func configureCellForMeetup(meetup: Meetup, row: Int) {
        titleLabel.text = meetup.name

        if let date = meetup.time {
            let timeText = MeetupCell.dateFormatter.stringFromDate(date)
            timeLabel.text = String(format: "%@ - %@", timeText, meetup.locationName ?? "Location unknown")

            let components = NSCalendar.currentCalendar().components(.CalendarUnitMonth | .CalendarUnitDay, fromDate: date)
            dayLabel.text = String(format: "%d", components.day)

            let months = ["JAN", "FEB", "MAR", "APR", "MAY", "JUN", "JUL", "AUG", "SEPT", "OCT", "NOV", "DEC"]
            monthLabel.text = months[components.month - 1]

            if date.timeIntervalSinceNow > 0 {
                dayLabel.textColor = UIColor.blackColor()
                calendarImageView.image = UIImage(named: "CalendarFuture")
            } else {
                dayLabel.textColor = UIColor(white: 0, alpha: 0.65)
                calendarImageView.image = UIImage(named: "CalendarPast")
            }
        }

        if let logoFile = meetup.smallLogo {
            logoImageView.file = logoFile
            logoImageView.loadInBackground(nil)
        }
    }
}
