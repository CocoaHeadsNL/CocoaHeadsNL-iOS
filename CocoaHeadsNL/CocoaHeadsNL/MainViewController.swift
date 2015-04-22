//
//  MainViewController.swift
//  CocoaHeadsNL
//
//  Created by Jeroen Leenarts on 09-03-15.
//  Copyright (c) 2015 Stichting CocoaheadsNL. All rights reserved.
//

import Foundation

class MainViewController: PFQueryTableViewController
{
    var selectedObject: PFObject?
    
    override init(style: UITableViewStyle, className: String!) {
        super.init(style: style, className: className)
    }
    
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        self.parseClassName = "Meetup"
        self.pullToRefreshEnabled = true
        self.paginationEnabled = true
        self.objectsPerPage = 50
    }
    
    override func viewDidLoad() {
        self.loadObjects()
    }
    
    override func viewWillAppear(animated: Bool) {
        self.tableView.reloadData()
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 80
    }

    //MARK: - UITableViewDataSource
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath, object: PFObject?) -> PFTableViewCell {
        let meetup = object as? Meetup

        let cellId = "meetupCell"
        
        var cell = tableView.dequeueReusableCellWithIdentifier(cellId) as? PFTableViewCell
        if cell == nil {
            cell = PFTableViewCell(style: .Subtitle, reuseIdentifier: cellId)
        }
        
        if let cell = cell {
            if let textLabel = cell.textLabel {
                textLabel.adjustsFontSizeToFitWidth = true
                textLabel.text = meetup?.name
            }
            if let detailTextLabel = cell.detailTextLabel {
                if let date = meetup?.time {
                    let dateFormatter = NSDateFormatter()
                    dateFormatter.dateStyle = .MediumStyle
                    dateFormatter.timeStyle = .ShortStyle
                    dateFormatter.dateFormat = "d MMMM, HH:mm a"
                    detailTextLabel.text = dateFormatter.stringFromDate(date)
                }
                //detailTextLabel.text = meetup.locationName
            }
            
            if let imageView = cell.imageView {
                imageView.image = UIImage(named: "CocoaHeadsNLLogo")
                imageView.layer.contentsGravity = kCAGravityCenter
                imageView.contentMode = .ScaleAspectFit
                
                if let logoFile = meetup?.logo {
                    imageView.file = logoFile
                    imageView.loadInBackground(nil)
                }
            }
        }
        
        return cell!
    }
    
    //MARK: - UITableViewDelegate
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        selectedObject = self.objectAtIndexPath(indexPath)

        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewControllerWithIdentifier("detailTableViewController") as! DetailTableViewController
        vc.selectedObject = selectedObject
        showDetailViewController(vc, sender: self)
    }
    
    //Mark: - Parse PFQueryTableViewController methods

    override func queryForTable() -> PFQuery {
        let historyQuery = Meetup.query()
        historyQuery!.whereKey("time", lessThan: NSDate())
        
        let futureQuery = Meetup.query()
        futureQuery!.whereKey("nextEvent", equalTo: true)
        
        let compoundQuery = PFQuery.orQueryWithSubqueries([historyQuery!, futureQuery!])
        compoundQuery.orderByDescending("time")
        
        compoundQuery.cachePolicy = PFCachePolicy.CacheThenNetwork

        return compoundQuery
    }
}