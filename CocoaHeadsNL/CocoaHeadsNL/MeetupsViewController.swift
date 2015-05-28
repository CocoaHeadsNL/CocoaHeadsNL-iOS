//
//  MeetupsViewController
//  CocoaHeadsNL
//
//  Created by Jeroen Leenarts on 09-03-15.
//  Copyright (c) 2015 Stichting CocoaheadsNL. All rights reserved.
//

import Foundation

class MeetupsViewController: PFQueryTableViewController {
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        self.parseClassName = "Meetup"
        self.pullToRefreshEnabled = true
        self.paginationEnabled = true
        self.objectsPerPage = 50
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        //self.tableView.registerClass(MeetupCell.self, forCellReuseIdentifier: MeetupCell.Identifier)
        let nib = UINib(nibName: "MeetupCell", bundle: nil)
        self.tableView.registerNib(nib, forCellReuseIdentifier: MeetupCell.Identifier)

        let backItem = UIBarButtonItem(title: "Events", style: .Plain, target: nil, action: nil)
        self.navigationItem.backBarButtonItem = backItem

        self.loadObjects()
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.tableView.reloadData()
    }

    //MARK: - Segues

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "ShowDetail" {
            if let indexPath = self.tableView.indexPathForCell(sender as! UITableViewCell) {
                let detailViewController = segue.destinationViewController as! DetailTableViewController
                detailViewController.selectedObject = self.objectAtIndexPath(indexPath)
            }
        }
    }

    //MARK: - UITableViewDataSource
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath, object: PFObject?) -> PFTableViewCell {

        var cell = tableView.dequeueReusableCellWithIdentifier(MeetupCell.Identifier, forIndexPath: indexPath) as! MeetupCell

        if let meetup = object as? Meetup {
            cell.configureCellForMeetup(meetup, row: indexPath.row)
        }

        return cell
    }

    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 88
    }

    //MARK: - UITableViewDelegate
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        self.performSegueWithIdentifier("ShowDetail", sender: tableView.cellForRowAtIndexPath(indexPath))
    }

    //MARK: - Parse PFQueryTableViewController methods

    override func queryForTable() -> PFQuery {
        let meetupQuery = Meetup.query()!
        meetupQuery.orderByDescending("time")
        
        meetupQuery.cachePolicy = PFCachePolicy.CacheThenNetwork

        return meetupQuery
    }
}
