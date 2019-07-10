import UIKit
import StoreKit
import CloudKit

class CompanyDataSource: DetailDataSource {
    weak var presenter: DetailViewController?

    var company: Company {
        return object as! Company // swiftlint:disable:this force_cast
    }

    override var title: String? {
        return company.name
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 1:
            return NSLocalizedString("Apps", comment: "Section title for app section in company details.")
        default:
            return nil
        }
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 4
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch (indexPath as NSIndexPath).row {
        case 0:
            return logoCellWithFile(company.logoImage, forTableView: tableView)
        case 1:
            return titleCellWithText(company.emailAddress, forTableView: tableView)
        case 2:
            return titleCellWithText(company.streetAddress, forTableView: tableView)
        case 3:
            return titleCellWithText(company.zipCode, forTableView: tableView)
        default:
            fatalError("This should not happen.")
        }
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if section == 1 {
            tableView.headerView(forSection: 1)?.backgroundColor = UIColor.gray
            return tableView.headerView(forSection: 1)
        } else {
            return UIView(frame: CGRect.zero)
        }
    }
}
