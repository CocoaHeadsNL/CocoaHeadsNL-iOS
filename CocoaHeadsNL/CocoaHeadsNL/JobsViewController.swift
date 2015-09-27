//
//  JobsViewController.swift
//  CocoaHeadsNL
//
//  Created by Bart Hoffman on 07/03/15.
//  Copyright (c) 2015 Stichting CocoaheadsNL. All rights reserved.
//

import Foundation
import UIKit

class JobsViewController: PFQueryCollectionViewController {
    
    override func loadView() {
        super.loadView()

        self.collectionView?.registerClass(JobsCollectionViewCell.self, forCellWithReuseIdentifier: "jobsCollectionViewCell")
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        if let layout = collectionViewLayout as? UICollectionViewFlowLayout {
            layout.itemSize = CGSize(width: 145, height: 100)
            let screenwidth = view.frame.width
            let numberOfCells = floor(screenwidth / layout.itemSize.width)
            let inset = floor((screenwidth - numberOfCells * layout.itemSize.width) / (numberOfCells + 1))
            layout.sectionInset = UIEdgeInsets(top: 10.0, left: inset, bottom: 10.0, right: inset)
                layout.minimumInteritemSpacing = inset
        }
    }

    //MARK: - UICollectionViewDataSource methods

    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath, object: PFObject?) -> PFCollectionViewCell? {

        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("jobsCollectionViewCell", forIndexPath: indexPath) as! JobsCollectionViewCell
            
        if let job = object as? Job {
            cell.updateFromObject(job)
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
                let job = self.objectAtIndexPath(indexPath) as! Job
                let detailViewController = segue.destinationViewController as! DetailViewController
                detailViewController.dataSource = JobDataSource(object: job)
            }
        }
    }
    
    //MARK: - Query
    
    override func queryForCollection() -> PFQuery {
        let query = Job.query()
        return query!.orderByAscending("date")
    }
    
    override func objectsDidLoad(error: NSError?) {
        super.objectsDidLoad(error)
        
        if let jobs = self.objects as? [Job] {
            Job.index(jobs)
        }
    }

    
}
