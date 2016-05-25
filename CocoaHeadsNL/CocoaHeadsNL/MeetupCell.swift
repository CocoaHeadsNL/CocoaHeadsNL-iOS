//
//  MeetupCell.swift
//  CocoaHeadsNL
//
//  Created by Matthijs Hollemans on 25-05-15.
//  Copyright (c) 2016 Stichting CocoaheadsNL. All rights reserved.
//

import Foundation
import UIKit

private let dateFormatter = NSDateFormatter()

class MeetupCell: UITableViewCell {
    static let Identifier = "meetupCell"

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var logoImageView: UIImageView!
    @IBOutlet weak var dateContainer: UIView!
    @IBOutlet weak var calendarView: UIView!
    @IBOutlet weak var dayLabel: UILabel!
    @IBOutlet weak var monthLabel: UILabel!
    @IBOutlet weak var rsvpLabel: UILabel!

    required init?(coder aDecoder: NSCoder) {
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
    }

    func configureCellForMeetup(meetup: Meetup, row: Int) {
        titleLabel.text = meetup.name

        if let date = meetup.time {
            dateFormatter.dateStyle = .NoStyle
            dateFormatter.timeStyle = .ShortStyle
            let timeText = dateFormatter.stringFromDate(date)
            timeLabel.text = String(format: "%@ %@", meetup.location ?? "Location unknown", timeText)

            dateFormatter.dateFormat = "dd"
            dayLabel.text = dateFormatter.stringFromDate(date)

            dateFormatter.dateFormat = "MMM"
            monthLabel.text = dateFormatter.stringFromDate(date).uppercaseString

            if date.timeIntervalSinceNow > 0 {
                dayLabel.textColor = UIColor.blackColor()
                calendarView.backgroundColor = UIColorWithRGB(232, green: 88, blue: 80)


                if let yesRsvp = meetup.yes_rsvp_count?.intValue {

                    rsvpLabel.text = "\(yesRsvp) CocoaHeads going"

                    if let rsvpLimit = meetup.rsvp_limit?.intValue where rsvpLimit > 0 {
                        rsvpLabel.text = rsvpLabel.text! + "\n\(rsvpLimit - yesRsvp) seats available"
                    }
                } else {
                    rsvpLabel.text = ""
                }
            } else {
                dayLabel.textColor = UIColor(white: 0, alpha: 0.65)
                calendarView.backgroundColor = UIColorWithRGB(169, green: 166, blue: 166)

                if let yesRsvp = meetup.yes_rsvp_count?.intValue {

                rsvpLabel.text = "\(yesRsvp) CocoaHeads had a blast"
                }
            }
        }

        self.logoImageView.image =  meetup.smallLogoImage
    }

    override func setHighlighted(highlighted: Bool, animated: Bool) {
        super.setHighlighted(highlighted, animated: animated)
        monthLabel.textColor = highlighted ? UIColor.blackColor() : UIColor.whiteColor()
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        monthLabel.textColor = selected ? UIColor.blackColor() : UIColor.whiteColor()
    }
}
