//
//  CompaniesNearbyViewController.swift
//  CocoaHeadsNL
//
//  Created by Bart Hoffman on 10/03/15.
//  Copyright (c) 2016 Stichting CocoaheadsNL. All rights reserved.
//

import Foundation
import UIKit
import CloudKit
import Crashlytics
import RealmSwift

class CompaniesNearbyCollectionViewController: UICollectionViewController {
    
    let realm = try! Realm()

    var companiesArray = try! Realm().objects(Company.self).sorted("name")
    var coreLocationController: CoreLocationController?
    var geoPoint: CLLocation?
    var notificationToken: NotificationToken?

    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!


    override func viewDidLoad() {
        super.viewDidLoad()

        let nib = UINib(nibName: "CompaniesNearbyCell", bundle: nil)
        self.collectionView?.registerNib(nib, forCellWithReuseIdentifier: "companiesNearbyCell")

        if let layout = collectionViewLayout as? UICollectionViewFlowLayout {
            layout.itemSize = CGSize(width: 100, height: 80)
            layout.sectionInset = UIEdgeInsetsZero
            layout.minimumInteritemSpacing = 4
        }

        self.coreLocationController = CoreLocationController()

        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(CompaniesNearbyCollectionViewController.locationAvailable(_:)), name: "LOCATION_AVAILABLE", object: nil)
        self.activityIndicator.startAnimating()
        
        // Set results notification block
        self.notificationToken = companiesArray.addNotificationBlock { (changes: RealmCollectionChange) in
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
        if let locationManager = self.coreLocationController?.locationManager {
            locationManager.startUpdatingLocation()
        }

        self.fetchCompanies()
    }

    override func viewWillDisappear(animated: Bool) {
        if let locationManager = self.coreLocationController?.locationManager {
            locationManager.stopUpdatingLocation()
        }
    }

    func locationAvailable(notification: NSNotification) -> Void {

            let userInfo = notification.userInfo as! Dictionary<String, CLLocation>

            print("CoreLocationManager:  Location available \(userInfo)")

        if let latitude = userInfo["location"]?.coordinate.latitude, longitude = userInfo["location"]?.coordinate.longitude {
            geoPoint = CLLocation(latitude: latitude, longitude: longitude)
            self.collectionView?.reloadData()
        }
    }


    //MARK: - UICollectionViewDataSource methods

    override func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }

    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.companiesArray.count
    }


    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {

        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("companiesNearbyCell", forIndexPath: indexPath) as! CompaniesNearbyCell

        let company = self.companiesArray[indexPath.item]
        cell.updateFromObject(company)

        return cell
    }

    //MARK: - UICollectionViewDelegate methods

    override func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        self.performSegueWithIdentifier("ShowDetail", sender: collectionView.cellForItemAtIndexPath(indexPath))
    }

    //MARK: - Segues

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "ShowDetail" {
            if let indexPath = self.collectionView?.indexPathForCell(sender as! UICollectionViewCell) {
                let company = self.companiesArray[indexPath.row]
                let dataSource = CompanyDataSource(object: company)
                dataSource.fetchAffiliateLinks()

                let detailViewController = segue.destinationViewController as! DetailViewController
                detailViewController.dataSource = dataSource

                Answers.logContentViewWithName("Show company details",
                                               contentType: "Company",
                                               contentId: company.name!,
                                               customAttributes: nil)
            }
        }
    }

    //MARK: - fetching Cloudkit

    func fetchCompanies() {

        let query = CKQuery(recordType: "Companies", predicate: NSPredicate(value: true))
        if let location = self.geoPoint {
            query.sortDescriptors = [
                CKLocationSortDescriptor(key: "location", relativeLocation: location)
            ]

        } else {
            query.sortDescriptors = [
                CKLocationSortDescriptor(key: "name", ascending: true)
            ]
        }

        let operation = CKQueryOperation(query: query)
        operation.qualityOfService = .UserInteractive

        var companies = [Company]()

        operation.recordFetchedBlock = { (record) in
            let company = Company.company(forRecord: record)

            companies.append(company)
        }

        operation.queryCompletionBlock = { [weak self] (cursor, error) in
            dispatch_async(dispatch_get_main_queue()) {
                if error == nil {
                    self?.realm.beginWrite()
                    self?.realm.add(companies, update: true)
                    try! self?.realm.commitWrite()

                    self?.activityIndicator.stopAnimating()
                } else {
                    let ac = UIAlertController(title: "Fetch failed", message: "There was a problem fetching the list of companies; please try again: \(error!.localizedDescription)", preferredStyle: .Alert)
                    ac.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
                    self?.presentViewController(ac, animated: true, completion: nil)
                }
            }
        }

        CKContainer.defaultContainer().publicCloudDatabase.addOperation(operation)

    }
}
