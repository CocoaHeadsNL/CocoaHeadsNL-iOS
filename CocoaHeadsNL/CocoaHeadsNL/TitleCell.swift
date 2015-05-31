import UIKit

class TitleCell: UITableViewCell {
    @IBOutlet weak var titleLabel: UILabel!

    var content: String? {
        didSet {
            self.titleLabel.text = content
        }
    }

    var date: NSDate? {
        didSet {
            if let date = date {
                var dateFormatter = NSDateFormatter()
                var dateFormat = NSDateFormatter.dateFormatFromTemplate("MMMMd", options: 0, locale: NSLocale.currentLocale())
                dateFormatter.dateFormat = dateFormat
                
                let dateString = dateFormatter.stringFromDate(date)
                dateFormatter.timeStyle = .ShortStyle
                let timeString = dateFormatter.stringFromDate(date)
                self.titleLabel.text = dateString + ", " + timeString
            } else {
                self.titleLabel.text = "-"
            }
        }
    }
}
