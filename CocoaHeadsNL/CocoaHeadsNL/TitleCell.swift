import UIKit

class  TitleCell: UITableViewCell {
    @IBOutlet weak var titleLabel: UILabel!

    enum CellMode {
        case Line1
        case Line2
        case Line3
    }

    var cellMode = CellMode.Line1

    var selectedObject: PFObject? {
        didSet{
            if selectedObject == oldValue {
                return
            }

            if let company = selectedObject as? Company {
                switch cellMode {
                case .Line1:
                    if let email = company.emailAddress {
                        self.titleLabel.text = email
                    }
                case .Line2:
                    if let address = company.streetAddress {
                        self.titleLabel.text = address
                    }
                case .Line3:
                    if let zipcode = company.zipCode {
                        self.titleLabel.text = zipcode
                    }
                }
            } else if let meetup = selectedObject as? Meetup {
                switch cellMode {
                case .Line1:
                    if let nameOfHost = meetup.name {
                        titleLabel.text = nameOfHost
                    }
                case .Line2:
                    titleLabel.text = String("Number of Cocoaheads: \(meetup.yes_rsvp_count)")
                case .Line3:
                    if let date = meetup.time {
                        var dateFormatter = NSDateFormatter()
                        dateFormatter.dateStyle = .MediumStyle
                        dateFormatter.timeStyle = .ShortStyle
                        dateFormatter.dateFormat = "d MMMM, HH:mm a"
                        self.titleLabel.text = dateFormatter.stringFromDate(date)
                    }
                }
            } else if let job = selectedObject as? Job {
                switch cellMode {
                case .Line1:
                    if let jobTitle = job.title {
                        self.titleLabel.text = jobTitle
                    }
                case .Line2:
                    self.titleLabel.text = ""
                case .Line3:
                    self.titleLabel.text = ""
                }

            }
        }
    }
}

