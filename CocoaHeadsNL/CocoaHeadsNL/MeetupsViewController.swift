//
//  MeetupsViewController
//  CocoaHeadsNL
//
//  Created by Jeroen Leenarts on 09-03-15.
//  Copyright (c) 2015 Stichting CocoaheadsNL. All rights reserved.
//

import Foundation
import UIKit
import CoreSpotlight
import CloudKit

class MeetupsViewController: UITableViewController, UIViewControllerPreviewingDelegate {

    var meetupsArray = [Meetup]()
    var searchedObjectId: String? = nil

    weak var activityIndicatorView: UIActivityIndicatorView!

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

    }

    override func viewDidLoad() {
        super.viewDidLoad()

        //self.tableView.registerClass(MeetupCell.self, forCellReuseIdentifier: MeetupCell.Identifier)
        let nib = UINib(nibName: "MeetupCell", bundle: nil)
        self.tableView.registerNib(nib, forCellReuseIdentifier: MeetupCell.Identifier)

        let backItem = UIBarButtonItem(title: "Events", style: .Plain, target: nil, action: nil)
        self.navigationItem.backBarButtonItem = backItem

        let calendarIcon = UIImage.calendarTabImageWithCurrentDate()
        self.navigationController?.tabBarItem.image = calendarIcon
        self.navigationController?.tabBarItem.selectedImage = calendarIcon

        //Inspect paste board for userInfo
        if let pasteBoard = UIPasteboard(name: searchPasteboardName, create: false) {
            let uniqueIdentifier = pasteBoard.string
            if let components = uniqueIdentifier?.componentsSeparatedByString(":") {
                if components.count > 1 {
                    let objectId = components[1]
                    displayObject(objectId)
                }
            }
        }


        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(MeetupsViewController.searchOccured(_:)), name: searchNotificationName, object: nil)

        if #available(iOS 9.0, *) {
            if traitCollection.forceTouchCapability == .Available {
                registerForPreviewingWithDelegate(self, sourceView: view)
            }
        } else {
            // Fallback on earlier versions
        }

        self.discover()
        self.subscribe()

        let activityIndicatorView = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.Gray)
        tableView.backgroundView = activityIndicatorView
        self.activityIndicatorView = activityIndicatorView

        activityIndicatorView.startAnimating()
    }

    override func viewWillAppear(animated: Bool) {
        self.fetchMeetups()
    }

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)

        if let searchedObjectId = searchedObjectId {
            self.searchedObjectId = nil
            displayObject(searchedObjectId)
        }
    }

    func discover() {

        let container = CKContainer.defaultContainer()

        container.requestApplicationPermission(CKApplicationPermissions.UserDiscoverability) { (status, error) in
            guard error == nil else { return }

            if status == CKApplicationPermissionStatus.Granted {
                // User allowed for searching on email
                container.fetchUserRecordIDWithCompletionHandler { (recordID, error) in
                    guard error == nil else { return }
                    guard let recordID = recordID else { return }

                    container.discoverUserInfoWithUserRecordID(recordID) { (info, fetchError) in
                        // TODO check for deprecation and save to userRecord?
                        print(info)
                    }
                }
            }
        }
    }

    func subscribe() {
        let publicDB = CKContainer.defaultContainer().publicCloudDatabase

        let subscription = CKSubscription(
            recordType: "Meetup",
            predicate: NSPredicate(value: true),
            options: .FiresOnRecordCreation
        )

        let info = CKNotificationInfo()

        info.alertBody = "New meetup has been added!"
        info.shouldBadge = true

        subscription.notificationInfo = info

        publicDB.saveSubscription(subscription) { record, error in }
    }

    //MARK: - 3D Touch

    func previewingContext(previewingContext: UIViewControllerPreviewing, viewControllerForLocation location: CGPoint) -> UIViewController? {
        //quick peek
        guard let indexPath = tableView.indexPathForRowAtPoint(location), cell = tableView.cellForRowAtIndexPath(indexPath) as? MeetupCell
            else { return nil }

        let vcId = "detailViewController"

        guard let detailVC = storyboard?.instantiateViewControllerWithIdentifier(vcId) as? DetailViewController
            else { return nil }

        if #available(iOS 9.0, *) {

            let meetup = self.meetupsArray[indexPath.row]
            detailVC.dataSource = MeetupDataSource(object: meetup )
            detailVC.presentingVC  = self

            previewingContext.sourceRect = cell.frame

            return detailVC

        } else {
            // Fallback on earlier versions
            return nil
        }
    }

    func previewingContext(previewingContext: UIViewControllerPreviewing, commitViewController viewControllerToCommit: UIViewController) {
        //push to detailView - pop forceTouch window
        showViewController(viewControllerToCommit, sender: self)
    }


    //MARK: - Search

    func searchOccured(notification: NSNotification) -> Void {
        guard let userInfo = notification.userInfo as? Dictionary<String, String> else {
            return
        }

        let type = userInfo["type"]

        if type != "meetup" {
            //Not for me
            return
        }
        if let objectId = userInfo["objectId"] {
            displayObject(objectId)
        }
    }

    func displayObject(recordID: String) -> Void {
        //if !loading {
            if self.navigationController?.visibleViewController == self {
                let meetups = self.meetupsArray

                if let selectedObject = meetups.filter({ (meetup: Meetup) -> Bool in
                    return meetup.recordID == recordID
                }).first {
                    performSegueWithIdentifier("ShowDetail", sender: selectedObject)
                }

            } else {
                self.navigationController?.popToRootViewControllerAnimated(false)
                searchedObjectId = recordID
            }

//        } else {
//            //cache object
//            searchedObjectId = objectId
//        }
    }


    //MARK: - Segues

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "ShowDetail" {
            if let selectedObject = sender as? Meetup {
                let detailViewController = segue.destinationViewController as! DetailViewController
                detailViewController.dataSource = MeetupDataSource(object: selectedObject)
            } else if let indexPath = self.tableView.indexPathForCell(sender as! UITableViewCell) {
                let meetup = self.meetupsArray[indexPath.row]
                let detailViewController = segue.destinationViewController as! DetailViewController
                detailViewController.dataSource = MeetupDataSource(object: meetup)
            }
        }
    }

    //MARK: - UITableViewDataSource

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        return self.meetupsArray.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCellWithIdentifier(MeetupCell.Identifier, forIndexPath: indexPath) as! MeetupCell

        let meetup = self.meetupsArray[indexPath.row]
        cell.configureCellForMeetup(meetup, row: indexPath.row)

        return cell

    }

    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }

    override func tableView(tableView: UITableView, estimatedHeightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return CGFloat(88)
    }

    //MARK: - UITableViewDelegate

    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        self.performSegueWithIdentifier("ShowDetail", sender: tableView.cellForRowAtIndexPath(indexPath))
        self.tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }

    //MARK: - fetching Cloudkit

    func fetchMeetups() {

        let pred = NSPredicate(value: true)
        let sort = NSSortDescriptor(key: "time", ascending: false)
        let query = CKQuery(recordType: "Meetup", predicate: pred)
        query.sortDescriptors = [sort]

        let operation = CKQueryOperation(query: query)
        operation.qualityOfService = .UserInteractive

        var CKMeetups = [Meetup]()

        operation.recordFetchedBlock = { (record) in
            let meetup = Meetup(record: record)
            print("Loaded \(meetup.smallLogoImage)")
            print("Loaded \(meetup.logoImage)")
            CKMeetups.append(meetup)
        }

        operation.queryCompletionBlock = { [unowned self] (cursor, error) in
            dispatch_async(dispatch_get_main_queue()) {
                guard error == nil else {
                    let ac = UIAlertController(
                        title: "Fetch failed",
                        message: "There was a problem fetching the list of meetups; please try again: \(error!.localizedDescription)", preferredStyle: .Alert)
                    ac.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
                    self.presentViewController(ac, animated: true, completion: nil)
                    return
                }
                self.meetupsArray = CKMeetups
                self.activityIndicatorView.stopAnimating()
                self.activityIndicatorView.hidesWhenStopped = true
                self.tableView.reloadData()
            }
        }

        CKContainer.defaultContainer().publicCloudDatabase.addOperation(operation)

    }


}
