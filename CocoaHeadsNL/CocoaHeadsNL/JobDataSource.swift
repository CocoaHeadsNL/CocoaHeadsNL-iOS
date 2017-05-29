import UIKit

class JobDataSource: DetailDataSource {
    var job: Job {
        return object as! Job
    }

    override var title: String? {
        return job.title
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch (indexPath as NSIndexPath).row {
        case 0:
            return logoCellWithFile(job.logoImage, forTableView: tableView)
        case 1:
            return titleCellWithText(job.title, forTableView: tableView)
        case 2:
            return dataCellWithHTML(job.content, forTableView: tableView)
        default:
            fatalError("This should not happen.")
        }
    }
}
