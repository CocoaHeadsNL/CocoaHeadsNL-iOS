import UIKit
import CloudKit

/**
 * Base class for all data sources used by the Detail screen.
 * It has convenience methods for making specific types of cells.
 */
class DetailDataSource: NSObject, UITableViewDataSource, UITableViewDelegate {
    let object: AnyObject
    var tableView: UITableView!

    init(object: AnyObject) {
        self.object = object
    }

    var title: String? {
        return ""
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        fatalError("Subclass must implement this")
    }

    func logoCellWithFile(_ logo: UIImage, forTableView tableView: UITableView) -> LogoCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "logoCell") as! LogoCell
        cell.logoImageView.image = logo
        cell.logoImageView.contentMode = .scaleAspectFit
        return cell
    }

    func mapViewCellWithLocation(_ location: CLLocation?, name: String?, forTableView tableView: UITableView) -> MapViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "mapViewCell") as! MapViewCell
        cell.geoLocation = location
        cell.locationName = name
        return cell
    }

    func titleCellWithText(_ text: String?, forTableView tableView: UITableView) -> TitleCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "titleCell") as! TitleCell
        cell.content = text
        return cell
    }

    func titleCellWithDate(_ date: Date?, forTableView tableView: UITableView) -> TitleCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "titleCell") as! TitleCell
        cell.date = date
        return cell
    }

    func webViewCellWithHTML(_ html: String?, forTableView tableView: UITableView) -> WebViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "webViewCell") as! WebViewCell
        cell.html = html
        return cell
    }
}
