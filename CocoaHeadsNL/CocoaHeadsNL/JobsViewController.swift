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
    
    var searchedObjectId : String? = nil

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        self.parseClassName = "Job"
        self.pullToRefreshEnabled = true
        self.paginationEnabled = false
    }
    
    override func loadView() {
        super.loadView()

        self.collectionView?.registerClass(JobsCollectionViewCell.self, forCellWithReuseIdentifier: "jobsCollectionViewCell")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Inspect paste board for userInfo
        if let pasteBoard = UIPasteboard(name: searchPasteboardName, create: false) {
            let uniqueIdentifier = pasteBoard.string
            if let components = uniqueIdentifier?.componentsSeparatedByString(":") {
                if components.count > 1 && components[0] == "job"{
                    let objectId = components[1]
                    displayObject(objectId)
                }
            }
        }
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "searchOccured:", name: searchNotificationName, object: nil)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        if let searchedObjectId = searchedObjectId {
            self.searchedObjectId = nil
            displayObject(searchedObjectId)
        }
    }
    
    func searchOccured(notification:NSNotification) -> Void {
        guard let userInfo = notification.userInfo as? Dictionary<String,String> else {
            return
        }
        
        let type = userInfo["type"]
        
        if type != "job" {
            //Not for me
            return
        }
        if let objectId = userInfo["objectId"] {
            displayObject(objectId)
        }
    }
    
    func displayObject(objectId: String) -> Void {
        if !loading {
            if self.navigationController?.visibleViewController == self {
                if let jobs = objects as? [Job] {
                    if let selectedObject = jobs.filter({ (job :Job) -> Bool in
                        return job.objectId == objectId
                    }).first {
                        performSegueWithIdentifier("ShowDetail", sender: selectedObject)
                    }
                }
            } else {
                self.navigationController?.popToRootViewControllerAnimated(false)
                searchedObjectId = objectId
            }
            
        } else {
            //cache object
            searchedObjectId = objectId
        }
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
            if let selectedObject = sender as? Job {
                let detailViewController = segue.destinationViewController as! DetailViewController
                detailViewController.dataSource = JobDataSource(object: selectedObject)
            } else if let indexPath = self.collectionView?.indexPathForCell(sender as! UICollectionViewCell) {
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
        
        if let searchedObjectId = searchedObjectId {
            self.searchedObjectId = nil
            displayObject(searchedObjectId)
        }
        
        if let jobs = self.objects as? [Job] {
            Job.index(jobs)
        }
    }

    
}
