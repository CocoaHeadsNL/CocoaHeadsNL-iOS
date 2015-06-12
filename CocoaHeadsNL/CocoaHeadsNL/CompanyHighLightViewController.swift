//
//  CompanyHighLightViewController.swift
//  CocoaHeadsNL
//
//  Created by Bart Hoffman on 30/05/15.
//  Copyright (c) 2015 Stichting CocoaheadsNL. All rights reserved.
//

import Foundation

class CompanyHighLightViewController: PFQueryCollectionViewController, UICollectionViewDelegateFlowLayout {
    var currentRowIndex = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.collectionView?.registerClass(CompanyHighLightCollectionViewCell.self, forCellWithReuseIdentifier: "companyHighLightCollectionViewCell")
        
        var timer = NSTimer.scheduledTimerWithTimeInterval(4.0, target: self, selector: Selector("startAnimatingHighLight"), userInfo: nil, repeats: true)
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        if let layout = collectionViewLayout as? UICollectionViewFlowLayout {
            layout.itemSize = CGSize(width: self.view.frame.size.width, height: 88)
        }
        
    }
    
    func startAnimatingHighLight() {
               
        if currentRowIndex < self.objects.count {
            var nextItem = NSIndexPath (forRow: currentRowIndex, inSection: 0)
            self.collectionView?.scrollToItemAtIndexPath(nextItem, atScrollPosition: UICollectionViewScrollPosition.CenteredHorizontally, animated: false)
            currentRowIndex++
            
            if currentRowIndex == self.objects.count {
                currentRowIndex = 0
            }
        }
    }
    
    
    //MARK: - UICollectionViewDataSource methods
    
    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath, object: PFObject?) -> PFCollectionViewCell {
        
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("companyHighLightCollectionViewCell", forIndexPath: indexPath) as! CompanyHighLightCollectionViewCell
        
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