import UIKit

class TitleCell: UITableViewCell {
    @IBOutlet weak var titleLabel: UILabel!

    var content: String? {
        didSet {
            self.titleLabel.text = content
        }
    }

    lazy var dateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        let dateFormat = DateFormatter.dateFormat(fromTemplate: "MMMMd",
                                                                options: 0,
                                                                locale: Locale.current)
        dateFormatter.dateFormat = dateFormat
        return dateFormatter
    }()

    lazy var timeFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.timeStyle = .short
        return dateFormatter
    }()

    var date: Date? {
        didSet {
            if let date = date {
                let dateString = dateFormatter.string(from: date)
                let timeString = timeFormatter.string(from: date)
                self.titleLabel.text = dateString + ", " + timeString
            } else {
                self.titleLabel.text = "-"
            }
        }
    }
}

extension TitleCell: Identifiable {}
