import UIKit

class MeetupDataSource: DetailDataSource {
    var meetup: Meetup {
        return object as! Meetup
    }

    override var title: String? {
        return meetup.name
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 6
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        switch indexPath.row {
        case 0:
            return logoCellWithFile(meetup.logoImage, forTableView: tableView)
        case 1:
            return mapViewCellWithLocation(meetup.geoLocation, name: meetup.locationName, forTableView: tableView)
        case 2:
            return titleCellWithText(meetup.name, forTableView: tableView)
        case 3:
            let text = String("Number of Cocoaheads: \(meetup.yes_rsvp_count)")
            return titleCellWithText(text, forTableView: tableView)
        case 4:
            return titleCellWithDate(meetup.time, forTableView: tableView)
        case 5:
            return webViewCellWithHTML(meetup.meetup_description, forTableView: tableView)
        default:
            fatalError("This should not happen.")
        }
    }
}
