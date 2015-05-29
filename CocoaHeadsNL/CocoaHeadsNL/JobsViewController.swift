//
//  JobsViewController.swift
//  CocoaHeadsNL
//
//  Created by Bart Hoffman on 07/03/15.
//  Copyright (c) 2015 Stichting CocoaheadsNL. All rights reserved.
//

import Foundation
import UIKit

class JobsViewController: PFQueryCollectionViewController, UICollectionViewDelegateFlowLayout {
    override func queryForCollection() -> PFQuery {
        let query = Job.query()
        query!.cachePolicy = .CacheThenNetwork
        return query!
    }

    override func viewWillTransitionToSize(size: CGSize, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
        coordinator.animateAlongsideTransition({ _ in
            super.collectionViewLayout?.invalidateLayout()
        }, completion: nil)
    }

    //MARK: - UICollectionViewDataSource methods

    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath, object: PFObject?) -> PFCollectionViewCell? {
        if let cell = super.collectionView(collectionView, cellForItemAtIndexPath: indexPath, object: object) {
            let job = object as? Job

            if let logoFile = job?.logo {
                cell.imageView.file = logoFile
                cell.imageView.image = UIImage(named: "CocoaHeadsNLLogo")
                cell.imageView.contentMode = .ScaleAspectFit
                cell.imageView.frame = CGRectInset(cell.contentView.frame, 5, 5)
                cell.imageView.clipsToBounds = true
                cell.imageView.loadInBackground(nil)
            }

            cell.contentView.layer.borderWidth = 0.5
            cell.contentView.layer.borderColor = UIColor.grayColor().CGColor
            return cell
        }
        fatalError("Could not get a cell")
    }

    //MARK: - UICollectionViewDelegate methods

    override func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        self.performSegueWithIdentifier("ShowDetail", sender: collectionView.cellForItemAtIndexPath(indexPath))
    }

    override func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        return CGSize(width: (self.view.frame.width - 15) / 2, height: 80)
    }

    //MARK: - Segues

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "ShowDetail" {
            if let indexPath = self.collectionView?.indexPathForCell(sender as! UICollectionViewCell) {
                let job = self.objectAtIndexPath(indexPath) as! Job
                let detailViewController = segue.destinationViewController as! DetailViewController
                detailViewController.dataSource = JobDataSource(object: job)
            }
        }
    }
}
