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
                dateFormatter.dateStyle = .MediumStyle
                dateFormatter.timeStyle = .ShortStyle
                dateFormatter.dateFormat = "d MMMM, HH:mm a"
                self.titleLabel.text = dateFormatter.stringFromDate(date)
            } else {
                self.titleLabel.text = "-"
            }
        }
    }
}
