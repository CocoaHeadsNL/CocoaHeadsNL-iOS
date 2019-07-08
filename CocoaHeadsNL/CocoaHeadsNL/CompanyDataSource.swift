import UIKit
import StoreKit

class CompanyDataSource: DetailDataSource {
    let fetchLinks = FetchAffiliateLinks()
    weak var presenter: DetailViewController?

    var company: Company {
        return object as! Company
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
        if (company.affiliateLinks?.count ?? 0) > 0 {
            return 2
        } else {
            return 1
        }
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 4
        } else {
            return fetchLinks.apps.count
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if (indexPath as NSIndexPath).section == 1 {
            return affiliateCellWithLink(fetchLinks.apps[(indexPath as NSIndexPath).row], forTableView: tableView)
        }

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

    fileprivate func affiliateCellWithLink(_ affiliateLink: AffiliateLink, forTableView tableView: UITableView) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "affiliateCell") as! AffiliateCell
        cell.productName = affiliateLink.productName
        cell.affiliateId = affiliateLink.affiliateId
        return cell
    }

    func fetchAffiliateLinks() {
        if company.affiliateLinks?.count ?? 0 > 0 {
            fetchLinks.fetchLinksForCompany(company) {
                self.tableView.reloadData()
            }
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

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if (indexPath as NSIndexPath).section == 1 {

            if let vc = presenter {

                let affiliateLink = self.fetchLinks.apps[(indexPath as NSIndexPath).row]
                let affiliateToken = "1010l8D"
                    if let affiliateId = affiliateLink.affiliateId {
                        let parameters = [SKStoreProductParameterITunesItemIdentifier: affiliateId, SKStoreProductParameterAffiliateToken: affiliateToken]

                        vc.showStoreView(parameters as [String : AnyObject], indexPath: indexPath)
                }
            }
        }
    }
}
