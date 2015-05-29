//
//  CompaniesViewController.swift
//  CocoaHeadsNL
//
//  Created by Bart Hoffman on 10/03/15.
//  Copyright (c) 2015 Stichting CocoaheadsNL. All rights reserved.
//

import Foundation

class CompaniesViewController: PFQueryCollectionViewController, UICollectionViewDelegateFlowLayout {
    
    override func viewDidLoad() {
        self.collectionView?.registerClass(CompanyCollectionViewCell.self, forCellWithReuseIdentifier: "companyCollectionViewCell")
        self.loadObjects()
    }
    
    
    override func queryForCollection() -> PFQuery {
        let query = Company.query()
        return query!
    }

    //MARK: - UICollectionViewDataSource methods

    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath, object: PFObject?) -> PFCollectionViewCell {
        
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("companyCollectionViewCell", forIndexPath: indexPath) as! CompanyCollectionViewCell
        
        if let company = object as? Company {
            cell.updateFromObject(company)
        }
        
        return cell
    }

    //MARK: - UICollectionViewDelegate methods

    override func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        self.performSegueWithIdentifier("ShowDetail", sender: collectionView.cellForItemAtIndexPath(indexPath))
    }

    //MARK: - UICollectionViewDelegateFlowLayout methods

    override func collectionView(collectionView : UICollectionView,layout collectionViewLayout:UICollectionViewLayout,sizeForItemAtIndexPath indexPath:NSIndexPath) -> CGSize {
        return CGSize(width: 140, height: 100)
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
}
