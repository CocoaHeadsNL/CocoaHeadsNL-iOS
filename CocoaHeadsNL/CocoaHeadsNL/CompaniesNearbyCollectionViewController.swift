//
//  CompaniesNearbyViewController.swift
//  CocoaHeadsNL
//
//  Created by Bart Hoffman on 10/03/15.
//  Copyright (c) 2015 Stichting CocoaheadsNL. All rights reserved.
//

import Foundation

class CompaniesNearbyCollectionViewController: PFQueryCollectionViewController, UICollectionViewDelegateFlowLayout {
    
    var geoPoint:PFGeoPoint?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.collectionView?.registerClass(CompaniesNearbyCollectionViewCell.self, forCellWithReuseIdentifier: "companiesNearbyCollectionViewCell")

        if let layout = collectionViewLayout as? UICollectionViewFlowLayout {
            layout.itemSize = CGSize(width: 100, height: 80)
            layout.sectionInset = UIEdgeInsetsZero
            layout.minimumInteritemSpacing = 4
        }
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "locationAvailable:", name: "LOCATION_AVAILABLE", object: nil)
    }
    

    func locationAvailable(notification:NSNotification) -> Void {
        
            let userInfo = notification.userInfo as! Dictionary<String,CLLocation>
            
            println("CoreLocationManager:  Location available \(userInfo)")
        
            geoPoint = PFGeoPoint(location: userInfo["location"])
        
            self.loadObjects()
            self.collectionView?.reloadData()
    }
    
    
    //MARK: - UICollectionViewDataSource methods
    
    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath, object: PFObject?) -> PFCollectionViewCell {
        
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("companiesNearbyCollectionViewCell", forIndexPath: indexPath) as! CompaniesNearbyCollectionViewCell
        
        if let company = object as? Company {
            cell.updateFromObject(company)
        }
        
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
                let company = self.objectAtIndexPath(indexPath) as! Company
                let dataSource = CompanyDataSource(object: company)
                dataSource.fetchAffiliateLinks()

                let detailViewController = segue.destinationViewController as! DetailViewController
                detailViewController.dataSource = dataSource
            }
        }
    }
    
    //MARK: - Query
    
    override func queryForCollection() -> PFQuery {
        let query = Company.query()
        
        if let coordinates = geoPoint {
            query!.whereKey("location", nearGeoPoint: coordinates, withinKilometers: 15.00)
            
            if query!.countObjects() > 0 {
                return query!
            } else {
                return query!.orderByAscending("place")
            }
        } else {
             return query!.orderByAscending("place")
        }
    }
}
