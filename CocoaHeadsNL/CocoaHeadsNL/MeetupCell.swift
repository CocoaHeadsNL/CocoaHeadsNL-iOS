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

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var logoImageView: UIImageView!
    @IBOutlet weak var dateContainer: UIView!
    @IBOutlet weak var monthBackgroundView: UIView!
    @IBOutlet weak var dayBackgroundView: UIView!
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
            timeLabel.text = String(format: "%@ %@", meetup.location ?? NSLocalizedString("Location unknown"), timeText)

            dateFormatter.dateFormat = "dd"
            dayLabel.text = dateFormatter.string(from: date as Date)

            dateFormatter.dateFormat = "MMM"
            monthLabel.text = dateFormatter.string(from: date as Date).uppercased()
            dateFormatter.dateFormat = "MMMM"
            monthLabel.accessibilityLabel = dateFormatter.string(from: date as Date)

            if meetup.isToday || meetup.isUpcoming {
                dayLabel.textColor = UIColor(named: "DayLabelColor")
                monthBackgroundView.backgroundColor = meetup.isToday ? UIColor(named: "DayBackgroundViewColorToday") : UIColor(named: "DayBackgroundViewColor")

                if meetup.yesRsvpCount > 0 {

                    rsvpLabel.text = "\(meetup.yesRsvpCount) " + NSLocalizedString("CocoaHeads going")

                    if meetup.rsvpLimit > 0 {
                        let text = rsvpLabel.text! + "\n\(meetup.rsvpLimit - meetup.yesRsvpCount) "
                        rsvpLabel.text = text + NSLocalizedString("seats available")
                    }
                } else {
                    rsvpLabel.text = ""
                }
            } else {
                dayLabel.textColor = UIColor(named: "DayLabelColorHistory")
                monthBackgroundView.backgroundColor = UIColor(named: "DayBackgroundViewColorHistory")

                rsvpLabel.text = "\(meetup.yesRsvpCount) \(NSLocalizedString("CocoaHeads had a blast"))"
            }
        }

        self.logoImageView.image = meetup.smallLogoImage
    }

    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        super.setHighlighted(highlighted, animated: animated)

        if highlighted {
            monthBackgroundView.backgroundColor = .gray
            dayBackgroundView.backgroundColor = UIColor(white: 1, alpha: 0.4)
        }
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        if selected {
            monthBackgroundView.backgroundColor = .gray
            dayBackgroundView.backgroundColor = UIColor(white: 1, alpha: 0.4)
        }
    }
}

extension MeetupCell: Identifiable {}
