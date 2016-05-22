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

    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        fatalError("Subclass must implement this")
    }

    func logoCellWithFile(file: CKAsset?, forTableView tableView: UITableView) -> LogoCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("logoCell") as! LogoCell
        cell.logoFile = file
        return cell
    }

    func mapViewCellWithLocation(location: CLLocation?, name: String?, forTableView tableView: UITableView) -> MapViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("mapViewCell") as! MapViewCell
        cell.geoLocation = location
        cell.locationName = name
        return cell
    }

    func titleCellWithText(text: String?, forTableView tableView: UITableView) -> TitleCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("titleCell") as! TitleCell
        cell.content = text
        return cell
    }

    func titleCellWithDate(date: NSDate?, forTableView tableView: UITableView) -> TitleCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("titleCell") as! TitleCell
        cell.date = date
        return cell
    }

    func webViewCellWithHTML(html: String?, forTableView tableView: UITableView) -> WebViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("webViewCell") as! WebViewCell
        cell.html = html
        return cell
    }
}
