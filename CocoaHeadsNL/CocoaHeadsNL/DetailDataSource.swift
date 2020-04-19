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

    func logoCellWithFile(_ logo: UIImage, forTableView tableView: UITableView, forRowAt indexPath: IndexPath) -> LogoCell {
        let cell = tableView.dequeueReusableCell(type: LogoCell.self, for: indexPath)
        cell.logoImageView.image = logo
        cell.logoImageView.contentMode = .scaleAspectFit
        return cell
    }

    func onlineCell(forRowAt indexPath: IndexPath) -> OnlineCell {
        let cell = tableView.dequeueReusableCell(type: OnlineCell.self, for: indexPath)
        return cell
    }

    func mapViewCellWithLocation(_ location: CLLocation?, name: String?, forTableView tableView: UITableView, forRowAt indexPath: IndexPath) -> MapViewCell {
        let cell = tableView.dequeueReusableCell(type: MapViewCell.self, for: indexPath)
        cell.geoLocation = location
        cell.locationName = name
        return cell
    }

    func titleCellWithText(_ text: String?, forTableView tableView: UITableView, forRowAt indexPath: IndexPath) -> TitleCell {
        let cell = tableView.dequeueReusableCell(type: TitleCell.self, for: indexPath)
        cell.content = text
        return cell
    }

    func titleCellWithDate(_ date: Date?, forTableView tableView: UITableView, forRowAt indexPath: IndexPath) -> TitleCell {
        let cell = tableView.dequeueReusableCell(type: TitleCell.self, for: indexPath)
        cell.date = date
        return cell
    }

    func dataCellWithHTML(_ html: String?, forTableView tableView: UITableView, forRowAt indexPath: IndexPath) -> HTMLDataCell {
        let cell = tableView.dequeueReusableCell(type: HTMLDataCell.self, for: indexPath)
        cell.html = html
        return cell
    }

    func buttonCell(_ urlString: String?, title: String, forTableView tableView: UITableView, forRowAt indexPath: IndexPath) -> ButtonCell {
        let cell = tableView.dequeueReusableCell(type: ButtonCell.self, for: indexPath)
        cell.title = title
        cell.urlString = urlString
        return cell
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }

    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return CGFloat(88)
    }
}
