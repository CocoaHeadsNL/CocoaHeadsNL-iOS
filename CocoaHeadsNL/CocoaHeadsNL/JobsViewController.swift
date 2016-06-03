//
//  JobsViewController.swift
//  CocoaHeadsNL
//
//  Created by Bart Hoffman on 07/03/15.
//  Copyright (c) 2016 Stichting CocoaheadsNL. All rights reserved.
//

import Foundation
import UIKit
import CloudKit
import Crashlytics

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

        Answers.logContentViewWithName("Show jobs",
                                       contentType: "Job",
                                       contentId: "overview",
                                       customAttributes: nil)
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
            let screenwidth = view.frame.width
            layout.itemSize = CGSize(width: screenwidth/2, height: 120)
            layout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
            layout.minimumInteritemSpacing = 0
            layout.minimumLineSpacing = 0
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

        // Remove the vertical separator line for a cell on the right.
        cell.rightHandSide = (indexPath.item % 2 == 1)

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
                Answers.logContentViewWithName("Show Job details",
                                               contentType: "Job",
                                               contentId: selectedObject.link,
                                               customAttributes: nil)
            } else if let indexPath = self.collectionView?.indexPathForCell(sender as! UICollectionViewCell) {
                let job = self.jobsArray[indexPath.row]
                let detailViewController = segue.destinationViewController as! DetailViewController
                detailViewController.dataSource = JobDataSource(object: job)
                Answers.logContentViewWithName("Show Job details",
                                               contentType: "Job",
                                               contentId: job.link,
                                               customAttributes: nil)
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

        var jobs = [Job]()

        operation.recordFetchedBlock = { (record) in
            let job = Job(record: record)
            let _ = job.logoImage
            jobs.append(job)
        }

        operation.queryCompletionBlock = { [unowned self] (cursor, error) in
            dispatch_async(dispatch_get_main_queue()) {

                if error != nil {

                    let ac = UIAlertController(title: "Fetch failed", message: "There was a problem fetching the list of jobs; please try again: \(error!.localizedDescription)", preferredStyle: .Alert)
                    ac.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
                    self.presentViewController(ac, animated: true, completion: nil)

                } else {

                    self.activityIndicator.stopAnimating()
                    self.jobsArray = jobs
                    self.collectionView?.reloadData()
                }
            }
        }

        CKContainer.defaultContainer().publicCloudDatabase.addOperation(operation)

    }
}
