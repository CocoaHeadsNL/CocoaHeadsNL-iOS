//
//  JobsViewController.swift
//  CocoaHeadsNL
//
//  Created by Bart Hoffman on 07/03/15.
//  Copyright (c) 2015 Stichting CocoaheadsNL. All rights reserved.
//

import Foundation
import UIKit

class JobsViewController: PFQueryCollectionViewController, UICollectionViewDelegateFlowLayout
{
    override func queryForCollection() -> PFQuery! {
        let query = Job.query()
        query.cachePolicy = PFCachePolicy.CacheThenNetwork
        return query
    }

    //MARK: - UICollectionViewDataSource methods
    override func collectionView(collectionView: UICollectionView!, cellForItemAtIndexPath indexPath: NSIndexPath!, object: PFObject!) -> PFCollectionViewCell! {
        let job = object as Job
        let cell = super.collectionView(collectionView, cellForItemAtIndexPath: indexPath, object: object)
        
        if let logoFile = job.logo {
            cell.imageView.file = logoFile
            cell.imageView.image = UIImage(named: "CocoaHeadsNLLogo")
            cell.imageView.contentMode = .ScaleAspectFit
            cell.imageView.frame = CGRect(x:5.0, y:5.0, width:140.0, height:60.0)
            cell.imageView.loadInBackground(nil)
        }
        
        cell.contentView.layer.borderWidth = 0.5
        cell.contentView.layer.borderColor = UIColor.grayColor().CGColor
        
        return cell
    }
    
    //MARK: - UICollectionViewDelegate methods
    
    override func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        let selectedObject = self.objectAtIndexPath(indexPath)
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewControllerWithIdentifier("detailTableViewController") as DetailTableViewController
        vc.selectedObject = selectedObject
        showDetailViewController(vc, sender: self)
    }
    
    //MARK: - UICollectionViewDelegateFlowLayout methods
    
    override func collectionView(collectionView : UICollectionView,layout collectionViewLayout:UICollectionViewLayout,sizeForItemAtIndexPath indexPath:NSIndexPath) -> CGSize
    {
        return CGSizeMake((self.view.bounds.size.width - 18.0)/2.0, 80)
    }
    
    override func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAtIndex section: Int) -> CGFloat {
        return 6.0
    }
    
    override func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAtIndex section: Int) -> CGFloat {
        return 6.0
    }
    
    override func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAtIndex section: Int) -> UIEdgeInsets {
        return UIEdgeInsetsMake(6, 6, 6, 6)
    }
}