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
import CoreData

class JobsViewController: UICollectionViewController {

    private lazy var fetchedResultsController: FetchedResultsController<Job> = {
        let fetchRequest = NSFetchRequest<Job>()
        fetchRequest.entity = Job.entity()
        fetchRequest.sortDescriptors = []
        let frc = FetchedResultsController<Job>(fetchRequest: fetchRequest, managedObjectContext: CoreDataStack.shared.viewContext, sectionNameKeyPath: nil)
        frc.setDelegate(self.frcDelegate)
        return frc
    }()

    private lazy var frcDelegate: JobFetchedResultsControllerDelegate = {
        // swiftlint:disable:this weak_delegate
        return JobFetchedResultsControllerDelegate(collectionView: self.collectionView)
    }()

    lazy var jobsArray: [Job] = {
    return try? Job.allInContext(CoreDataStack.shared.viewContext, sortDescriptors: [NSSortDescriptor(key: "date", ascending: false)])
    }() ?? []

    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!

    var searchedObjectId: String?

    override func viewDidLoad() {
        super.viewDidLoad()

        let nib = UINib(nibName: "JobsCell", bundle: nil)
        self.collectionView?.register(nib, forCellWithReuseIdentifier: "jobsCell")

        let backItem = UIBarButtonItem(title: NSLocalizedString("Jobs"), style: .plain, target: nil, action: nil)
        self.navigationItem.backBarButtonItem = backItem

        let accessibilityLabel = NSLocalizedString("Job openings at our sponsors")
        self.navigationItem.setupForRootViewController(withTitle: accessibilityLabel)

        //Inspect paste board for userInfo
        if let pasteBoard = UIPasteboard(name: UIPasteboard.Name(rawValue: searchPasteboardName), create: false) {
            let uniqueIdentifier = pasteBoard.string
            if let components = uniqueIdentifier?.components(separatedBy: ":") {
                if components.count > 1 && components[0] == "job"{
                    let objectId = components[1]
                    displayObject(objectId)
                }
            }
        }

        NotificationCenter.default.addObserver(self, selector: #selector(JobsViewController.searchOccured(_:)), name: NSNotification.Name(rawValue: searchNotificationName), object: nil)
        self.subscribe()
        if jobsArray.count == 0 {
            self.activityIndicator.startAnimating()
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.fetchJobs()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        if let searchedObjectId = searchedObjectId {
            self.searchedObjectId = nil
            displayObject(searchedObjectId)
        }
    }

    @objc func searchOccured(_ notification: Notification) {
        guard let userInfo = (notification as NSNotification).userInfo as? Dictionary<String, String> else {
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

    func displayObject(_ recordName: String) {
        // if !loading {
        if self.navigationController?.visibleViewController == self {
            let jobs = self.jobsArray

            if let selectedObject = jobs.filter({ (job: Job) -> Bool in
                return job.recordName == recordName
            }).first {
                performSegue(withIdentifier: "ShowDetail", sender: selectedObject)
            }

        } else {
            _ = self.navigationController?.popToRootViewController(animated: false)
            searchedObjectId = recordName
        }
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
        let publicDB = CKContainer.default().publicCloudDatabase

         let subscription = CKQuerySubscription(recordType: "Job", predicate: NSPredicate(format: "TRUEPREDICATE"), options: .firesOnRecordCreation)

        let info = CKSubscription.NotificationInfo()
        info.desiredKeys = ["title", "author", "logoUrl"]
        info.shouldBadge = true
        info.shouldSendContentAvailable = true
        info.category = "nl.cocoaheads.app.CocoaHeadsNL.jobNotification"

        subscription.notificationInfo = info

        publicDB.save(subscription, completionHandler: { _, _ in })
    }

    // MARK: - UICollectionViewDataSource methods

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return jobsArray.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "jobsCell", for: indexPath) as! JobsCell

        let job = jobsArray[indexPath.item]
        cell.job = job

        // Remove the vertical separator line for a cell on the right.
        cell.rightHandSide = ((indexPath as NSIndexPath).item % 2 == 1)

        return cell

    }

    // MARK: - UICollectionViewDelegate methods

    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.performSegue(withIdentifier: "ShowDetail", sender: collectionView.cellForItem(at: indexPath))
    }

    // MARK: - Segues

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ShowDetail" {
            if let selectedObject = sender as? Job {
                let detailViewController = segue.destination as! DetailViewController
                detailViewController.dataSource = JobDataSource(object: selectedObject)
            } else if let indexPath = self.collectionView?.indexPath(for: sender as! UICollectionViewCell) {
                let job = self.jobsArray[indexPath.row]
                let detailViewController = segue.destination as! DetailViewController
                detailViewController.dataSource = JobDataSource(object: job)
            }
        }
    }

    // MARK: - fetching Cloudkit

    func fetchJobs() {

        let pred = NSPredicate(value: true)
        let sort = NSSortDescriptor(key: "date", ascending: false)
        let query = CKQuery(recordType: "Job", predicate: pred)
        query.sortDescriptors = [sort]

        let operation = CKQueryOperation(query: query)
        operation.qualityOfService = .userInteractive

        var jobs = [Job]()

        operation.recordFetchedBlock = { (record) in
            let job = Job.job(forRecord: record, on: CoreDataStack.shared.viewContext)
            _ = job.logoImage
            jobs.append(job)
        }

        operation.queryCompletionBlock = { [weak self] (cursor, error) in
            DispatchQueue.main.async {
                guard error == nil else {
                    let ac = UIAlertController.fetchErrorDialog(whileFetching: "jobs", error: error!)
                    self?.present(ac, animated: true, completion: nil)
                    return
                }

                let jobRecordNames = jobs.compactMap ({ (job) -> String? in
                    return job.recordName
                })
                let predicate = NSPredicate(format: "NOT recordName IN %@", jobRecordNames)
                // TODO: insert into CoreData
//                let obsoleteJobs = self?.realm.objects(Job.self).filter(predicate)
//                self?.realm.beginWrite()
//                self?.realm.add(jobs, update: true)
//                if let obsoleteJobs = obsoleteJobs {
//                    self?.realm.delete(obsoleteJobs)
//                }
//                try! self?.realm.commitWrite()

                self?.activityIndicator.stopAnimating()
            }
        }

        CKContainer.default().publicCloudDatabase.add(operation)

    }
}

class JobFetchedResultsControllerDelegate: NSObject, FetchedResultsControllerDelegate {
    private weak var collectionView: UICollectionView?

    // MARK: - Lifecycle
    init(collectionView: UICollectionView?) {
        self.collectionView = collectionView
    }

    func fetchedResultsControllerDidPerformFetch(_ controller: FetchedResultsController<Job>) {
        collectionView?.reloadData()
    }

    func fetchedResultsControllerWillChangeContent(_ controller: FetchedResultsController<Job>) {
//        collectionView?.beginUp
    }

    func fetchedResultsControllerDidChangeContent(_ controller: FetchedResultsController<Job>) {
//        collectionView?.endUpdates()
    }

    func fetchedResultsController(_ controller: FetchedResultsController<Job>, didChangeObject change: FetchedResultsObjectChange<Job>) {
        guard let collectionView = collectionView else { return }
        switch change {
        case let .insert(_, indexPath):
            collectionView.insertItems(at: [indexPath])

        case let .delete(_, indexPath):
            collectionView.deleteItems(at: [indexPath])

        case let .move(_, fromIndexPath, toIndexPath):
            collectionView.moveItem(at: fromIndexPath, to: toIndexPath)

        case let .update(_, indexPath):
            collectionView.reloadItems(at: [indexPath])
        }
    }

    func fetchedResultsController(_ controller: FetchedResultsController<Job>, didChangeSection change: FetchedResultsSectionChange<Job>) {
        guard let collectionView = collectionView else { return }
        switch change {
        case let .insert(_, index):
            collectionView.insertSections(IndexSet(integer: index))

        case let .delete(_, index):
            collectionView.deleteSections(IndexSet(integer: index))
        }
    }
}
