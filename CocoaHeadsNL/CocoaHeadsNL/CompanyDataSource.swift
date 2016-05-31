import UIKit
import StoreKit
import Crashlytics

class CompanyDataSource: DetailDataSource {
    let fetchLinks = FetchAffiliateLinks()
    weak var presenter: DetailViewController?

    var company: Company {
        return object as! Company
    }

    override var title: String? {
        return company.name
    }

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        if company.hasApps {
            return 2
        } else {
            return 1
        }
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 4
        } else {
            return fetchLinks.apps.count
        }
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if indexPath.section == 1 {
            return affiliateCellWithLink(fetchLinks.apps[indexPath.row], forTableView: tableView)
        }

        switch indexPath.row {
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

    private func affiliateCellWithLink(affiliateLink: AffiliateLink, forTableView tableView: UITableView) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("affiliateCell") as! AffiliateCell
        cell.productName = affiliateLink.productName
        cell.affiliateId = affiliateLink.affiliateId
        return cell
    }

    func fetchAffiliateLinks() {
        if company.hasApps {
            fetchLinks.fetchLinksForCompany(company) {
                self.tableView.reloadData()
            }
        }
    }

    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if section == 1 {
            tableView.headerViewForSection(1)?.backgroundColor = UIColor.grayColor()
            return tableView.headerViewForSection(1)
        } else {
            return UIView(frame: CGRect.zero)
        }
    }

    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath.section == 1 {

            if let vc = presenter {

                let affiliateLink = self.fetchLinks.apps[indexPath.row]
                let affiliateToken = "1010l8D"
                    if let affiliateId = affiliateLink.affiliateId {
                        let parameters = [SKStoreProductParameterITunesItemIdentifier :
                            affiliateId, SKStoreProductParameterAffiliateToken : affiliateToken]

                        vc.showStoreView(parameters, indexPath: indexPath)

                        Answers.logContentViewWithName("Show appstore",
                                                       contentType: "App",
                                                       contentId: "\(affiliateLink.productCreator!) \(affiliateLink.productName)",
                                                       customAttributes: nil)
                }
            }
        }
    }
}
