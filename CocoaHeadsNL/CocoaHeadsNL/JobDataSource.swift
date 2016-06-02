import UIKit

class JobDataSource: DetailDataSource {
    var job: Job {
        return object as! Job
    }

    override var title: String? {
        return job.title
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        switch indexPath.row {
        case 0:
            return logoCellWithFile(job.logoImage, forTableView: tableView)
        case 1:
            return titleCellWithText(job.title, forTableView: tableView)
        case 2:
            return webViewCellWithHTML(job.content, forTableView: tableView)
        default:
            fatalError("This should not happen.")
        }
    }
}
