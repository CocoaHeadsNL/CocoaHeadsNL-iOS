import UIKit
import MapKit

class MeetupDataSource: DetailDataSource {
    var meetup: Meetup {
        return object as! Meetup
    }

    override var title: String? {
        return meetup.name
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 7
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch (indexPath as NSIndexPath).row {
        case 0:
            return logoCellWithFile(meetup.logoImage, forTableView: tableView)
        case 1:
            let geoLocation = CLLocation(latitude: meetup.latitude, longitude: meetup.longitude)
            return mapViewCellWithLocation(geoLocation, name: meetup.locationName, forTableView: tableView)
        case 2:
            return titleCellWithText(meetup.name, forTableView: tableView)
        case 3:
            let text = String("Number of Cocoaheads: \(meetup.yes_rsvp_count)")
            return titleCellWithText(text, forTableView: tableView)
        case 4:
            return titleCellWithDate(meetup.time, forTableView: tableView)
        case 5:
            return buttonCell(urlString: meetup.meetupUrl, title: "Change your RSVP", forTableView: tableView)
        case 6:
            return webViewCellWithHTML(meetup.meetup_description, forTableView: tableView)
        default:
            fatalError("This should not happen.")
        }
    }
}
