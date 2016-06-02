import UIKit

class TitleCell: UITableViewCell {
    @IBOutlet weak var titleLabel: UILabel!

    var content: String? {
        didSet {
            self.titleLabel.text = content
        }
    }

    lazy var dateFormatter: NSDateFormatter = {
        let dateFormatter = NSDateFormatter()
        let dateFormat = NSDateFormatter.dateFormatFromTemplate("MMMMd",
                                                                options: 0,
                                                                locale: NSLocale.currentLocale())
        dateFormatter.dateFormat = dateFormat
        return dateFormatter
    }()

    lazy var timeFormatter: NSDateFormatter = {
        let dateFormatter = NSDateFormatter()
        dateFormatter.timeStyle = .ShortStyle
        return dateFormatter
    }()

    var date: NSDate? {
        didSet {
            if let date = date {
                let dateString = dateFormatter.stringFromDate(date)
                let timeString = timeFormatter.stringFromDate(date)
                self.titleLabel.text = dateString + ", " + timeString
            } else {
                self.titleLabel.text = "-"
            }
        }
    }
}
