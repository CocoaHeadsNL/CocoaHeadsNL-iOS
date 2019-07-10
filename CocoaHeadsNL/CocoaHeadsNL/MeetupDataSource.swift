import UIKit
import MapKit

class MeetupDataSource: DetailDataSource {
    var meetup: Meetup {
        return object as! Meetup // swiftlint:disable:this force_cast
    }

    override var title: String? {
        return meetup.name
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 7
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.row {
        case 1:
            if let mapCell = tableView.cellForRow(at: indexPath) as? MapViewCell {
                mapCell.openMapWithCoordinate()
            }
            tableView.deselectRow(at: indexPath, animated: true)
        default:
            tableView.deselectRow(at: indexPath, animated: true)
        }

    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.row {
        case 0:
            return logoCellWithFile(meetup.logoImage, forTableView: tableView)
        case 1:
            let geoLocation = CLLocation(latitude: meetup.latitude, longitude: meetup.longitude)
            return mapViewCellWithLocation(geoLocation, name: meetup.locationName, forTableView: tableView)
        case 2:
            return titleCellWithText(meetup.name, forTableView: tableView)
        case 3:
            let text = String("Number of Cocoaheads: \(meetup.yesRsvpCount)")
            return titleCellWithText(text, forTableView: tableView)
        case 4:
            return titleCellWithDate(meetup.time, forTableView: tableView)
        case 5:
            return buttonCell(meetup.meetupUrl, title: "Open Meetup", forTableView: tableView)
        case 6:
            return dataCellWithHTML(meetup.meetupDescription, forTableView: tableView)
        default:
            fatalError("This should not happen.")
        }
    }
}
