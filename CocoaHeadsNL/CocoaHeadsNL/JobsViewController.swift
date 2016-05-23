//
//  JobsViewController.swift
//  CocoaHeadsNL
//
//  Created by Bart Hoffman on 07/03/15.
//  Copyright (c) 2015 Stichting CocoaheadsNL. All rights reserved.
//

import Foundation
import UIKit
import CloudKit

class JobsViewController: UICollectionViewController {

    var jobsArray = [Job]()
    var searchedObjectId: String? = nil
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!

    override func viewDidLoad() {
        super.viewDidLoad()

        let nib = UINib(nibName: "JobsCell", bundle: nil)
        self.collectionView?.registerNib(nib, forCellWithReuseIdentifier: "jobsCell")

        //Inspect paste board for userInfo
        if let pasteBoard = UIPasteboard(name: searchPasteboardName, create: false) {
            let uniqueIdentifier = pasteBoard.string
            if let components = uniqueIdentifier?.componentsSeparatedByString(":") {
                if components.count > 1 && components[0] == "job"{
                    let objectId = components[1]
                    displayObject(objectId)
                }
            }
        }

        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(JobsViewController.searchOccured(_:)), name: searchNotificationName, object: nil)
        self.subscribe()
        self.activityIndicator.startAnimating()
    }

    override func viewWillAppear(animated: Bool) {
        self.fetchJobs()
    }

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)

        if let searchedObjectId = searchedObjectId {
            self.searchedObjectId = nil
            displayObject(searchedObjectId)
        }
    }

    func searchOccured(notification: NSNotification) -> Void {
        guard let userInfo = notification.userInfo as? Dictionary<String, String> else {
            return
        }

        let type = userInfo["type"]

        if type != "job" {
            //Not for me
            return
        }
        if let objectId = userInfo["objectId"] {
            displayObject(objectId)
        }
    }

    func displayObject(recordID: String) -> Void {
       // if !loading {
            if self.navigationController?.visibleViewController == self {
                let jobs = self.jobsArray

                if let selectedObject = jobs.filter({ (job: Job) -> Bool in
                    return job.recordID == recordID
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

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()

        if let layout = collectionViewLayout as? UICollectionViewFlowLayout {
            layout.itemSize = CGSize(width: 145, height: 100)
            let screenwidth = view.frame.width
            let numberOfCells = floor(screenwidth / layout.itemSize.width)
            let inset = floor((screenwidth - numberOfCells * layout.itemSize.width) / (numberOfCells + 1))
            layout.sectionInset = UIEdgeInsets(top: 10.0, left: inset, bottom: 10.0, right: inset)
                layout.minimumInteritemSpacing = inset
        }
    }

    func subscribe() {
        let publicDB = CKContainer.defaultContainer().publicCloudDatabase

        let subscription = CKSubscription(
            recordType: "Job",
            predicate: NSPredicate(value: true),
            options: .FiresOnRecordCreation
        )

        let info = CKNotificationInfo()

        info.alertBody = "A new job has been added!"
        info.shouldBadge = true

        subscription.notificationInfo = info

        publicDB.saveSubscription(subscription) { record, error in }
    }


    //MARK: - UICollectionViewDataSource methods

    override func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }

    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return jobsArray.count
    }

    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {

        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("jobsCell", forIndexPath: indexPath) as! JobsCell

        let job = jobsArray[indexPath.item]
        cell.job = job

        return cell

    }

    //MARK: - UICollectionViewDelegate methods

    override func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        self.performSegueWithIdentifier("ShowDetail", sender: collectionView.cellForItemAtIndexPath(indexPath))
    }

    //MARK: - Segues

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "ShowDetail" {
            if let selectedObject = sender as? Job {
                let detailViewController = segue.destinationViewController as! DetailViewController
                detailViewController.dataSource = JobDataSource(object: selectedObject)
            } else if let indexPath = self.collectionView?.indexPathForCell(sender as! UICollectionViewCell) {
                let job = self.jobsArray[indexPath.row]
                let detailViewController = segue.destinationViewController as! DetailViewController
                detailViewController.dataSource = JobDataSource(object: job)
            }
        }
    }

    //MARK: - fetching Cloudkit

    func fetchJobs() {

        let pred = NSPredicate(value: true)
        let sort = NSSortDescriptor(key: "date", ascending: false)
        let query = CKQuery(recordType: "Job", predicate: pred)
        query.sortDescriptors = [sort]

        let operation = CKQueryOperation(query: query)
        operation.qualityOfService = .UserInteractive

        var CKJob = [Job]()

        operation.recordFetchedBlock = { (record) in
            let recordID = record.recordID
            let content = record["content"] as? String ?? ""
            let date = record["date"] as? NSDate ?? NSDate()
            let link = record["link"] as? String ?? ""
            let title = record["title"] as? String ?? ""
            let logo = record["logo"] as? CKAsset

            let job = Job(recordID: recordID, content: content, date: date, link: link, title: title, logo: logo)
            print("Loaded \(job.logoImage)")

            CKJob.append(job)
        }

        operation.queryCompletionBlock = { [unowned self] (cursor, error) in
            dispatch_async(dispatch_get_main_queue()) {

                if error != nil {

                    let ac = UIAlertController(title: "Fetch failed", message: "There was a problem fetching the list of jobs; please try again: \(error!.localizedDescription)", preferredStyle: .Alert)
                    ac.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
                    self.presentViewController(ac, animated: true, completion: nil)

                } else {

                    self.activityIndicator.stopAnimating()
                    self.jobsArray = CKJob
                    self.collectionView?.reloadData()
                }
            }
        }

        CKContainer.defaultContainer().publicCloudDatabase.addOperation(operation)

    }
}
