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

    var companiesArray = try! Realm().objects(Company.self).sorted(byProperty: "name")
//    var coreLocationController: CoreLocationController?
//    var geoPoint: CLLocation?
    var notificationToken: NotificationToken?

    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!


    override func viewDidLoad() {
        super.viewDidLoad()

        let nib = UINib(nibName: "CompaniesNearbyCell", bundle: nil)
        self.collectionView?.register(nib, forCellWithReuseIdentifier: "companiesNearbyCell")

        if let layout = collectionViewLayout as? UICollectionViewFlowLayout {
            layout.itemSize = CGSize(width: 100, height: 80)
            layout.sectionInset = UIEdgeInsets.zero
            layout.minimumInteritemSpacing = 4
        }

//        self.coreLocationController = CoreLocationController()

//        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(CompaniesNearbyCollectionViewController.locationAvailable(_:)), name: "LOCATION_AVAILABLE", object: nil)
        if companiesArray.count == 0 {
            self.activityIndicator.startAnimating()
        }
        
        // Set results notification block
        self.notificationToken = companiesArray.addNotificationBlock { (changes: RealmCollectionChange) in
            switch changes {
            case .initial:
                // Results are now populated and can be accessed without blocking the UI
                self.collectionView?.reloadData()
                break
            case .update(_, let deletions, let insertions, let modifications):
                // Query results have changed, so apply them to the TableView
                self.collectionView?.performBatchUpdates({
                    self.collectionView?.insertItems(at: insertions.map { IndexPath(row: $0, section: 0) })
                    self.collectionView?.deleteItems(at: deletions.map { IndexPath(row: $0, section: 0) })
                    self.collectionView?.reloadItems(at: modifications.map { IndexPath(row: $0, section: 0) })
                    }, completion: nil)
                break
            case .error(let err):
                // An error occurred while opening the Realm file on the background worker thread
                fatalError("\(err)")
                break
            }
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
//        if let locationManager = self.coreLocationController?.locationManager {
//            locationManager.startUpdatingLocation()
//        }

        self.fetchCompanies()
    }

//    override func viewWillDisappear(animated: Bool) {
//        super.viewWillDisappear(animated)
//        if let locationManager = self.coreLocationController?.locationManager {
//            locationManager.stopUpdatingLocation()
//        }
//    }

//    func locationAvailable(notification: NSNotification) -> Void {
//
//            let userInfo = notification.userInfo as! Dictionary<String, CLLocation>
//
//            print("CoreLocationManager:  Location available \(userInfo)")
//
//        if let latitude = userInfo["location"]?.coordinate.latitude, longitude = userInfo["location"]?.coordinate.longitude {
//            geoPoint = CLLocation(latitude: latitude, longitude: longitude)
//            self.collectionView?.reloadData()
//        }
//    }


    //MARK: - UICollectionViewDataSource methods

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.companiesArray.count
    }


    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "companiesNearbyCell", for: indexPath) as! CompaniesNearbyCell

        let company = self.companiesArray[indexPath.item]
        cell.updateFromObject(company)

        return cell
    }

    //MARK: - UICollectionViewDelegate methods

    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.performSegue(withIdentifier: "ShowDetail", sender: collectionView.cellForItem(at: indexPath))
    }

    //MARK: - Segues

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ShowDetail" {
            if let indexPath = self.collectionView?.indexPath(for: sender as! UICollectionViewCell) {
                let company = self.companiesArray[indexPath.row]
                let dataSource = CompanyDataSource(object: company)
                dataSource.fetchAffiliateLinks()

                let detailViewController = segue.destination as! DetailViewController
                detailViewController.dataSource = dataSource

                Answers.logContentView(withName: "Show company details",
                                               contentType: "Company",
                                               contentId: company.name!,
                                               customAttributes: nil)
            }
        }
    }

    //MARK: - fetching Cloudkit

    func fetchCompanies() {

        let query = CKQuery(recordType: "Companies", predicate: NSPredicate(value: true))
        let operation = CKQueryOperation(query: query)
        operation.qualityOfService = .userInteractive

        var companies = [Company]()

        operation.recordFetchedBlock = { (record) in
            let company = Company.company(forRecord: record)

            companies.append(company)
        }

        operation.queryCompletionBlock = { [weak self] (cursor, error) in
            DispatchQueue.main.async {
                if error == nil {
                    self?.realm.beginWrite()
                    self?.realm.add(companies, update: true)
                    try! self?.realm.commitWrite()

                    self?.activityIndicator.stopAnimating()
                } else {
                    let ac = UIAlertController(title: "Fetch failed", message: "There was a problem fetching the list of companies; please try again: \(error!.localizedDescription)", preferredStyle: .alert)
                    ac.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                    self?.present(ac, animated: true, completion: nil)
                }
            }
        }

        CKContainer.default().publicCloudDatabase.add(operation)

    }
}
