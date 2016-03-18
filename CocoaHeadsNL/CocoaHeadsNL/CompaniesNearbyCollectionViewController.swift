//
//  CompaniesNearbyViewController.swift
//  CocoaHeadsNL
//
//  Created by Bart Hoffman on 10/03/15.
//  Copyright (c) 2015 Stichting CocoaheadsNL. All rights reserved.
//

import Foundation
import UIKit
import CloudKit

class CompaniesNearbyCollectionViewController: UICollectionViewController {
    
    var companiesArray = [Company]()
    var coreLocationController:CoreLocationController?
    var geoPoint:CLLocation?
    

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
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "locationAvailable:", name: "LOCATION_AVAILABLE", object: nil)
    }
    
    override func viewWillAppear(animated: Bool) {
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
    
    func locationAvailable(notification:NSNotification) -> Void {
        
            let userInfo = notification.userInfo as! Dictionary<String,CLLocation>
            
            print("CoreLocationManager:  Location available \(userInfo)")
        
        if let latitude = userInfo["location"]?.coordinate.latitude, let longitude = userInfo["location"]?.coordinate.longitude {
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
        
        var CKCompanies = [Company]()
        
        operation.recordFetchedBlock = { (record) in
            let company = Company()
            
            company.recordID = record.recordID as CKRecordID?
            company.name = record["name"] as? String
            company.place = record["place"] as? String
            company.streetAddress = record["streetAddress"] as? String
            company.website = record["website"] as? String
            company.zipCode = record["zipCode"] as? String
            company.companyDescription = record["companyDescription"] as? String
            company.emailAddress = record["emailAddress"] as? String
            company.location = record["location"] as? CLLocation
            company.logo = record["logo"] as? CKAsset
            //            company.hasApps = record["hasApps"] as? Bool
            company.smallLogo = record["smallLogo"] as? CKAsset
            
            CKCompanies.append(company)
        }
        
        operation.queryCompletionBlock = { [unowned self] (cursor, error) in
            dispatch_async(dispatch_get_main_queue()) {
                if error == nil {
                    
                    self.companiesArray = CKCompanies
                    self.collectionView?.reloadData()
                    
                } else {
                    let ac = UIAlertController(title: "Fetch failed", message: "There was a problem fetching the list of companies; please try again: \(error!.localizedDescription)", preferredStyle: .Alert)
                    ac.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
                    self.presentViewController(ac, animated: true, completion: nil)
                }
            }
        }
        
        CKContainer.defaultContainer().publicCloudDatabase.addOperation(operation)
        
    }
    
    
    //MARK: - Query
    
//    override func queryForCollection() -> PFQuery {
//        let query = Company.query()
//        
//        if let coordinates = geoPoint {
//            query!.whereKey("location", nearGeoPoint: coordinates, withinKilometers: 15.00)
//                return query!
//        } else {
//             return query!.orderByAscending("place")
//        }
//    }
}
