//
//  CompanyTableViewController.swift
//  CocoaHeadsNL
//
//  Created by Bart Hoffman on 30/05/15.
//  Copyright (c) 2015 Stichting CocoaheadsNL. All rights reserved.
//

import Foundation

class CompanyTableViewController: PFQueryTableViewController {
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        self.parseClassName = "Companies"
        self.pullToRefreshEnabled = true
        self.paginationEnabled = true
        self.objectsPerPage = 50
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let backItem = UIBarButtonItem(title: "Companies", style: .Plain, target: nil, action: nil)
        self.navigationItem.backBarButtonItem = backItem
    }
    
    //MARK: - Segues
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "ShowDetail" {
            if let indexPath = self.tableView.indexPathForCell(sender as! UITableViewCell) {
                let company = self.objectAtIndexPath(indexPath) as! Company
                let dataSource = CompanyDataSource(object: company)
                dataSource.fetchAffiliateLinks()
                
                let detailViewController = segue.destinationViewController as! DetailViewController
                detailViewController.dataSource = dataSource
            }
        }
    }
        
    //MARK: - UITableViewDataSource
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath, object: PFObject?) -> PFTableViewCell {
        
        var cell = tableView.dequeueReusableCellWithIdentifier("companyTableViewCell", forIndexPath: indexPath) as! PFTableViewCell
        
        if let company = object as? Company {
        
        cell.textLabel!.text = company.name
            
        }
        
        return cell
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 44
    }
    
    //MARK: - UITableViewDelegate
    
//    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
//        self.performSegueWithIdentifier("ShowDetail", sender: tableView.cellForRowAtIndexPath(indexPath))
//    }
    
    //MARK: - Parse PFQueryTableViewController methods
    
    override func queryForTable() -> PFQuery {
        let companyQuery = Company.query()!
        companyQuery.orderByDescending("place")
        
        return companyQuery
    }
}
