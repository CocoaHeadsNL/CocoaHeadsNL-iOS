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
    override init!(style: UITableViewStyle, className: String!) {
        super.init(style: style, className: className)
    }
    
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        self.parseClassName = "Meetup"
        self.pullToRefreshEnabled = true
        self.paginationEnabled = true
        self.objectsPerPage = 50
    }
    
    override func tableView(tableView: UITableView!, cellForRowAtIndexPath indexPath: NSIndexPath!, object: PFObject!) -> PFTableViewCell! {
        let cellId = "meetupCell"
        
        var cell = tableView.dequeueReusableCellWithIdentifier(cellId) as? PFTableViewCell
        if cell == nil {
            cell = PFTableViewCell(style: .Subtitle, reuseIdentifier: cellId)
        }
        
        if let cell = cell {
            if let textLabel = cell.textLabel {
                textLabel.text = object.objectForKey("name").description
            }
            if let detailTextLabel = cell.detailTextLabel {
                detailTextLabel.text = object.objectForKey("locationName").description
            }
        }
        
        return cell
    }

    override func queryForTable() -> PFQuery! {
        let query = PFQuery(className: "Meetup")
        query.orderByDescending("time")
        return query
    }
}