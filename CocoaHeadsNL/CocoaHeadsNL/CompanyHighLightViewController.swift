//
//  CompanyHighLightViewController.swift
//  CocoaHeadsNL
//
//  Created by Bart Hoffman on 30/05/15.
//  Copyright (c) 2015 Stichting CocoaheadsNL. All rights reserved.
//

import Foundation

class CompanyHighLightViewController: PFQueryCollectionViewController {

    var maxIndex = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.collectionView?.registerClass(CompanyHighLightCollectionViewCell.self, forCellWithReuseIdentifier: "companyHighLightCollectionViewCell")
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        if let layout = collectionViewLayout as? UICollectionViewFlowLayout {
            layout.itemSize = CGSize(width: self.view.frame.size.width, height: 88)
        }
    }
    
    override func viewWillTransitionToSize(size: CGSize, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransitionToSize(size, withTransitionCoordinator: coordinator)
        
        let indexPathForVisibleItem = self.collectionView?.indexPathsForVisibleItems()
        let first = indexPathForVisibleItem?.first!
        
        coordinator.animateAlongsideTransition({ (context) -> Void in
            // scroll to the current index
            self.collectionView?.scrollToItemAtIndexPath(first!, atScrollPosition: UICollectionViewScrollPosition.CenteredHorizontally, animated: false)
            }, completion: nil);
    }
        
    override func objectAtIndexPath(indexPath: NSIndexPath?) -> PFObject? {
        
        maxIndex = (self.objects.count - 1)
        
        let firstItemInThirdSection = NSIndexPath(forItem: 0, inSection: 2)
        let lastItemInFourthSection = NSIndexPath(forItem: maxIndex, inSection: 3)
        let firstItemInFirstSection = NSIndexPath(forItem: 0, inSection: 1)
        
        if let ind = indexPath {
            
            if ind.section == 0 {
                
                if ind.item == 0 {
                    self.collectionView?.scrollToItemAtIndexPath(firstItemInThirdSection, atScrollPosition: UICollectionViewScrollPosition.CenteredHorizontally, animated: false)
                }
                
                if ind.item == maxIndex-1 {
                    self.collectionView?.scrollToItemAtIndexPath(lastItemInFourthSection, atScrollPosition: UICollectionViewScrollPosition.CenteredHorizontally, animated: false)
                }
            }
            
            if ind.section == 4 {
                if ind.item == 1 {
                self.collectionView?.scrollToItemAtIndexPath(firstItemInFirstSection, atScrollPosition: UICollectionViewScrollPosition.CenteredHorizontally, animated: false)
                }
            }
            
            return self.objects[ind.row] //as? PFObject Always succeeds as self.objects is an array of PFObjects.
        }
        
        return nil
    }
    
    //MARK: - UICollectionViewDataSource methods
    
    override func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 5
    }
    
    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.objects.count
    }
    
    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath, object: PFObject?) -> PFCollectionViewCell {
        
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("companyHighLightCollectionViewCell", forIndexPath: indexPath) as! CompanyHighLightCollectionViewCell
        
        if let company = object as? Company {
            cell.updateFromObject(company)
        }
        
        return cell
    }
    
    //MARK: - UICollectionViewDelegate methods
    
    override func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        print(indexPath, terminator: "")
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