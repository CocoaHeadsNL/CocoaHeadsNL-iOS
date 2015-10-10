//
//  MeetupsViewController
//  CocoaHeadsNL
//
//  Created by Jeroen Leenarts on 09-03-15.
//  Copyright (c) 2015 Stichting CocoaheadsNL. All rights reserved.
//

import Foundation
import CoreSpotlight

class MeetupsViewController: PFQueryTableViewController, UIViewControllerPreviewingDelegate {
    
    var searchedObjectId : String? = nil
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        self.parseClassName = "Meetup"
        self.pullToRefreshEnabled = true
        self.paginationEnabled = false
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        //self.tableView.registerClass(MeetupCell.self, forCellReuseIdentifier: MeetupCell.Identifier)
        let nib = UINib(nibName: "MeetupCell", bundle: nil)
        self.tableView.registerNib(nib, forCellReuseIdentifier: MeetupCell.Identifier)

        let backItem = UIBarButtonItem(title: "Events", style: .Plain, target: nil, action: nil)
        self.navigationItem.backBarButtonItem = backItem
        
        let calendarIcon = UIImage.calendarTabImageWithCurrentDate()
        self.navigationController?.tabBarItem.image = calendarIcon
        self.navigationController?.tabBarItem.selectedImage = calendarIcon
        
        //Inspect paste board for userInfo
        if let pasteBoard = UIPasteboard(name: searchPasteboardName, create: false) {
            let uniqueIdentifier = pasteBoard.string
            if let components = uniqueIdentifier?.componentsSeparatedByString(":") {
                if components.count > 1 {
                    let objectId = components[1]
                    displayObject(objectId)
                }
            }
        }

        NSNotificationCenter.defaultCenter().addObserver(self, selector: "searchOccured:", name: searchNotificationName, object: nil)
        
        if #available(iOS 9.0, *) {
            if traitCollection.forceTouchCapability == .Available {
                registerForPreviewingWithDelegate(self, sourceView: view)
            }
        } else {
            // Fallback on earlier versions
        }
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        if let searchedObjectId = searchedObjectId {
            self.searchedObjectId = nil
            displayObject(searchedObjectId)
        }
    }
    
    //MARK: - 3D Touch
    
    func previewingContext(previewingContext: UIViewControllerPreviewing, viewControllerForLocation location: CGPoint) -> UIViewController? {
        //quick peek
        guard let indexPath = tableView.indexPathForRowAtPoint(location), cell = tableView.cellForRowAtIndexPath(indexPath) as? MeetupCell
            else { return nil }
        
        let vcId = "detailViewController"
        
        guard let detailVC = storyboard?.instantiateViewControllerWithIdentifier(vcId) as? DetailViewController
            else { return nil }
        
        if #available(iOS 9.0, *) {
            
            if let meetup = self.objectAtIndexPath(indexPath) as? Meetup {
            detailVC.dataSource = MeetupDataSource(object: meetup )
            detailVC.presentingVC  = self
            
            previewingContext.sourceRect = cell.frame
                
            return detailVC
                
            } else {
                return nil
            }
            
        } else {
            // Fallback on earlier versions
            return nil
        }
    }
    
    func previewingContext(previewingContext: UIViewControllerPreviewing, commitViewController viewControllerToCommit: UIViewController) {
        //push to detailView - pop forceTouch window
        showViewController(viewControllerToCommit, sender: self)
    }
    
    
    //MARK: - Search
    
    func searchOccured(notification:NSNotification) -> Void {
        guard let userInfo = notification.userInfo as? Dictionary<String,String> else {
            return
        }
        
        let type = userInfo["type"]
        
        if type != "meetup" {
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
                if let meetups = objects as? [Meetup] {
                    if let selectedObject = meetups.filter({ (meetup :Meetup) -> Bool in
                        return meetup.objectId == objectId
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


    //MARK: - Segues

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "ShowDetail" {
            if let selectedObject = sender as? Meetup {
                let detailViewController = segue.destinationViewController as! DetailViewController
                detailViewController.dataSource = MeetupDataSource(object: selectedObject)
            } else if let indexPath = self.tableView.indexPathForCell(sender as! UITableViewCell) {
                let meetup = self.objectAtIndexPath(indexPath) as! Meetup
                let detailViewController = segue.destinationViewController as! DetailViewController
                detailViewController.dataSource = MeetupDataSource(object: meetup)
            }
        }
    }

    //MARK: - UITableViewDataSource
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath, object: PFObject?) -> PFTableViewCell {

        let cell = tableView.dequeueReusableCellWithIdentifier(MeetupCell.Identifier, forIndexPath: indexPath) as! MeetupCell

        if let meetup = object as? Meetup {
            cell.configureCellForMeetup(meetup, row: indexPath.row)
        }

        return cell
    }

    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }

    override func tableView(tableView: UITableView, estimatedHeightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return CGFloat(88)
    }

    //MARK: - UITableViewDelegate
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        self.performSegueWithIdentifier("ShowDetail", sender: tableView.cellForRowAtIndexPath(indexPath))
    }

    //MARK: - Parse PFQueryTableViewController methods

    override func queryForTable() -> PFQuery {
        let meetupQuery = Meetup.query()!
        meetupQuery.orderByDescending("time")

        return meetupQuery
    }
    
    override func objectsDidLoad(error: NSError?) {
        super.objectsDidLoad(error)
        
        if let searchedObjectId = searchedObjectId {
            self.searchedObjectId = nil
            displayObject(searchedObjectId)
        }
        
        if let meetups = self.objects as? [Meetup] {
            Meetup.index(meetups)
        }
    }
}
