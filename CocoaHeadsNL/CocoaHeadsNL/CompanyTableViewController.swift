//
//  CompanyTableViewController.swift
//  CocoaHeadsNL
//
//  Created by Bart Hoffman on 30/05/15.
//  Copyright (c) 2015 Stichting CocoaheadsNL. All rights reserved.
//

import Foundation

class CompanyTableViewController: PFQueryTableViewController, UITableViewDelegate {
    var locationSet = Set<String>()
    let sortedArray = NSMutableArray()
    
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
    
    
    override func objectsDidLoad(error: NSError?) {
        super.objectsDidLoad(error)
        
        locationSet.removeAll(keepCapacity: false)
        sortedArray.removeAllObjects()
        
        if error == nil {
            
            if let objectArray = self.objects {
                
                for company in objectArray {
                    
                    if let obj = company as? Company, let location = obj.place  {
                        
                        if !locationSet.contains(location) {
                            locationSet.insert(location)
                        }
                    }
                }
                
                let groups = sorted(locationSet)

                for String in groups {
                    let companyArray = NSMutableArray()
                    var locationDict = NSMutableDictionary()
                    locationDict.setValue(String, forKey: "location")
                    
                    for company in objectArray {
                        
                        if let comp = company as? Company, let loc = comp.place {
                                if loc == locationDict.valueForKey("location") as? StringLiteralType {
                                    companyArray.addObject(company)
                                }
                        }
                        
                    }
                    locationDict.setValue(companyArray, forKey: "company")
                    sortedArray.addObject(locationDict)
                }
            }
        } else {
            print(error)
        }
        
        self.tableView.reloadData()
    }

    
    //MARK: - Segues
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "ShowCompanies" {
            if let indexPath = self.tableView.indexPathForCell(sender as! UITableViewCell) {
                
                let detailViewController = segue.destinationViewController as? LocatedCompaniesViewController
                detailViewController?.companiesDict = sortedArray.objectAtIndex(indexPath.row) as! NSMutableDictionary
            }
        }
    }
    
    //MARK: - UITablewViewDelegate
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sortedArray.count
    }
        
    //MARK: - UITableViewDataSource
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath, object: PFObject?) -> PFTableViewCell {
        
        var cell = tableView.dequeueReusableCellWithIdentifier("companyTableViewCell", forIndexPath: indexPath) as! PFTableViewCell

            
        cell.textLabel!.text = sortedArray.objectAtIndex(indexPath.row).valueForKey("location") as? StringLiteralType

        
        return cell
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 44
    }
    
    //MARK: - UITableViewDelegate
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        self.performSegueWithIdentifier("ShowCompanies", sender: tableView.cellForRowAtIndexPath(indexPath))
    }
    
    //MARK: - Parse PFQueryTableViewController methods
    
    override func queryForTable() -> PFQuery {
        let companyQuery = Company.query()!
        companyQuery.orderByAscending("name")
        
        return companyQuery
    }
}
