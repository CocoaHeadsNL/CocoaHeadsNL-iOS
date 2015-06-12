//
//  CompaniesNearbyViewController.swift
//  CocoaHeadsNL
//
//  Created by Bart Hoffman on 10/03/15.
//  Copyright (c) 2015 Stichting CocoaheadsNL. All rights reserved.
//

import Foundation

class CompaniesNearbyCollectionViewController: PFQueryCollectionViewController, UICollectionViewDelegateFlowLayout {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.collectionView?.registerClass(CompaniesNearbyCollectionViewCell.self, forCellWithReuseIdentifier: "companiesNearbyCollectionViewCell")
        self.collectionView?.registerClass(UICollectionReusableView.self, forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: "headerView")
    }
       
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()

        if let layout = collectionViewLayout as? UICollectionViewFlowLayout {
            layout.itemSize = CGSize(width: 100, height: 60)
        }
        
    }
    
    
    //MARK: - UICollectionViewDataSource methods
    
    override func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAtIndex section: Int) -> UIEdgeInsets {
        return UIEdgeInsetsMake(15, -310, 5, 5)
    }
    
   
    override func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSizeMake(collectionView.bounds.width, 20)
    }
    
    override func collectionView(collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, atIndexPath indexPath: NSIndexPath) -> UICollectionReusableView {
        let headerView = collectionView.dequeueReusableSupplementaryViewOfKind(UICollectionElementKindSectionHeader, withReuseIdentifier: "headerView", forIndexPath: indexPath) as! UICollectionReusableView
        headerView.frame = CGRectMake(6, 0, 300, 15)
        
        let label = UILabel(frame: CGRectInset(headerView.frame, 0, 0))
        label.font = UIFont(name: label.font.fontName, size: 13)
        label.text = "Companies near you"
        headerView.addSubview(label)
        
        return headerView
    }

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
    
    //MARK: -Query
    
    override func queryForCollection() -> PFQuery {
        let query = Company.query()
        return query!.orderByAscending("place")
    }

}
