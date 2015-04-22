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
    override func queryForCollection() -> PFQuery {
        let query = Job.query()
        query!.cachePolicy = PFCachePolicy.CacheThenNetwork
        return query!
    }
    
    override func viewWillAppear(animated: Bool) {
        self.loadObjects()
    }

    override func viewWillTransitionToSize(size: CGSize, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
        
        coordinator.animateAlongsideTransition({ (context: UIViewControllerTransitionCoordinatorContext!) -> Void in
            self.loadObjects()
            }, completion: { (context:UIViewControllerTransitionCoordinatorContext!) -> Void in
            
        })
    }
    
    override func didMoveToParentViewController(parent: UIViewController?) {
        // when presented by NavigationController through SplitViewController
        self.collectionViewLayout.invalidateLayout()
    }
    
    //MARK: - UICollectionViewDataSource methods
    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath, object: PFObject?) -> PFCollectionViewCell? {
        let job = object as! Job
        let cell = super.collectionView(collectionView, cellForItemAtIndexPath: indexPath, object: object)
        
        if let logoFile = job.logo {
            
            cell!.imageView.file = logoFile
            cell!.imageView.image = UIImage(named: "CocoaHeadsNLLogo")
            cell!.imageView.contentMode = .ScaleAspectFit
            cell!.imageView.frame = CGRectInset(cell!.contentView.frame, 5, 5)
            cell!.imageView.clipsToBounds = true
            cell!.imageView.loadInBackground(nil)
        }

        
        cell!.contentView.layer.borderWidth = 0.5
        cell!.contentView.layer.borderColor = UIColor.grayColor().CGColor
        
        return cell!
    }
    
    //MARK: - UICollectionViewDelegate methods
    
    override func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        let selectedObject = self.objectAtIndexPath(indexPath)
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewControllerWithIdentifier("detailTableViewController") as!DetailTableViewController
        vc.selectedObject = selectedObject
        showDetailViewController(vc, sender: self)
    }
    
    
    override func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        
        let currentWidth = self.view.frame.size.width
        
        let width = (currentWidth - 15) / 2.0
        
        return CGSizeMake(width, 80)
    }
}