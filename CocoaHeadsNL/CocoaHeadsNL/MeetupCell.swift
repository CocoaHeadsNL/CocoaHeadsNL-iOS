//
//  MeetupCell.swift
//  CocoaHeadsNL
//
//  Created by Matthijs Hollemans on 25-05-15.
//  Copyright (c) 2016 Stichting CocoaheadsNL. All rights reserved.
//

import Foundation
import UIKit

private let dateFormatter = DateFormatter()

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

    func configureCellForMeetup(_ meetup: Meetup) {
        titleLabel.text = meetup.name

        if let date = meetup.time {
            dateFormatter.dateStyle = .none
            dateFormatter.timeStyle = .short
            let timeText = dateFormatter.string(from: date as Date)
            timeLabel.text = String(format: "%@ %@", meetup.location ?? "Location unknown", timeText)

            dateFormatter.dateFormat = "dd"
            dayLabel.text = dateFormatter.string(from: date as Date)

            dateFormatter.dateFormat = "MMM"
            monthLabel.text = dateFormatter.string(from: date as Date).uppercased()

            if date.timeIntervalSinceNow > 0 {
                dayLabel.textColor = UIColor.black
                calendarView.backgroundColor = UIColorWithRGB(232, green: 88, blue: 80)


                if meetup.yes_rsvp_count.int32Value > 0{

                    rsvpLabel.text = "\(meetup.yes_rsvp_count.int32Value) CocoaHeads going"

                    if meetup.rsvp_limit.int32Value > 0 {
                        rsvpLabel.text = rsvpLabel.text! + "\n\(meetup.rsvp_limit.int32Value - meetup.yes_rsvp_count.int32Value) seats available"
                    }
                } else {
                    rsvpLabel.text = ""
                }
            } else {
                dayLabel.textColor = UIColor(white: 0, alpha: 0.65)
                calendarView.backgroundColor = UIColorWithRGB(169, green: 166, blue: 166)

                rsvpLabel.text = "\(meetup.yes_rsvp_count.int32Value) CocoaHeads had a blast"
            }
        }

        self.logoImageView.image =  meetup.smallLogoImage
    }

    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        super.setHighlighted(highlighted, animated: animated)
        monthLabel.textColor = highlighted ? UIColor.black : UIColor.white
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        monthLabel.textColor = selected ? UIColor.black : UIColor.white
    }
}
