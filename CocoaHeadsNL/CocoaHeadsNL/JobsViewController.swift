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
import RealmSwift

class JobsViewController: UICollectionViewController {
    let realm = try! Realm()

    var jobsArray = try! Realm().objects(Job.self).sorted("date", ascending: false)
    var searchedObjectId: String? = nil
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    var notificationToken: NotificationToken?

    override func viewDidLoad() {
        super.viewDidLoad()

        let nib = UINib(nibName: "JobsCell", bundle: nil)
        self.collectionView?.registerNib(nib, forCellWithReuseIdentifier: "jobsCell")

        let backItem = UIBarButtonItem(title: "Jobs", style: .Plain, target: nil, action: nil)
        self.navigationItem.backBarButtonItem = backItem

        self.navigationItem.titleView = UIImageView(image: UIImage(named: "Banner")!)

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
        if jobsArray.count == 0 {
            self.activityIndicator.startAnimating()
        }
    
        // Set results notification block
        self.notificationToken = jobsArray.addNotificationBlock { (changes: RealmCollectionChange) in
            switch changes {
            case .Initial:
                // Results are now populated and can be accessed without blocking the UI
                self.collectionView?.reloadData()
                break
            case .Update(_, let deletions, let insertions, let modifications):
                // Query results have changed, so apply them to the TableView
                self.collectionView?.performBatchUpdates({
                    self.collectionView?.insertItemsAtIndexPaths(insertions.map { NSIndexPath(forRow: $0, inSection: 0) })
                    self.collectionView?.deleteItemsAtIndexPaths(deletions.map { NSIndexPath(forRow: $0, inSection: 0) })
                    self.collectionView?.reloadItemsAtIndexPaths(modifications.map { NSIndexPath(forRow: $0, inSection: 0) })
                    }, completion: nil)
                break
            case .Error(let err):
                // An error occurred while opening the Realm file on the background worker thread
                fatalError("\(err)")
                break
            }
        }
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)

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

    func displayObject(recordName: String) -> Void {
       // if !loading {
            if self.navigationController?.visibleViewController == self {
                let jobs = self.jobsArray

                if let selectedObject = jobs.filter({ (job: Job) -> Bool in
                    return job.recordName == recordName
                }).first {
                    performSegueWithIdentifier("ShowDetail", sender: selectedObject)
                }

            } else {
                self.navigationController?.popToRootViewControllerAnimated(false)
                searchedObjectId = recordName
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
            let job = Job.job(forRecord: record)
            let _ = job.logoImage
            jobs.append(job)
        }

        operation.queryCompletionBlock = { [weak self] (cursor, error) in
            dispatch_async(dispatch_get_main_queue()) {

                if error != nil {

                    let ac = UIAlertController(title: "Fetch failed", message: "There was a problem fetching the list of jobs; please try again: \(error!.localizedDescription)", preferredStyle: .Alert)
                    ac.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
                    self?.presentViewController(ac, animated: true, completion: nil)

                } else {
                    let jobRecordNames = jobs.flatMap({ (job) -> String? in
                        return job.recordName
                    })
                    let predicate = NSPredicate(format: "NOT recordName IN %@", jobRecordNames)
                    let obsoleteJobs = self?.realm.objects(Job).filter(predicate)
                    self?.realm.beginWrite()
                    self?.realm.add(jobs, update: true)
                    if let obsoleteJobs = obsoleteJobs {
                        self?.realm.delete(obsoleteJobs)
                    }
                    try! self?.realm.commitWrite()

                    self?.activityIndicator.stopAnimating()
                }
            }
        }

        CKContainer.defaultContainer().publicCloudDatabase.addOperation(operation)

    }
}
