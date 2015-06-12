//
//  CompanyTableViewController.swift
//  CocoaHeadsNL
//
//  Created by Bart Hoffman on 30/05/15.
//  Copyright (c) 2015 Stichting CocoaheadsNL. All rights reserved.
//

import Foundation

class CompanyTableViewController: PFQueryTableViewController, UITableViewDelegate {
    
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
        
        sortedArray.removeAllObjects()
        
        if error == nil {
            
            if let objectArray = self.objects as? [Company] {
                
                var locationSet = Set<String>()
                
                for company in objectArray  {
                    
                    if let location = company.place  {
                        
                        if !locationSet.contains(location) {
                            locationSet.insert(location)
                        }
                    }
                }
                
                let groupedArray = sorted(locationSet)

                for group in groupedArray {
                    let companyArray = NSMutableArray()
                    var locationDict = NSMutableDictionary()
                    locationDict.setValue(group, forKey: "place")
                    
                    for company in objectArray {
                        
                        if let loc = company.place {
                                if loc == locationDict.valueForKey("place") as? StringLiteralType {
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
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "All Companies"
    }

    override func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let labelRect = CGRect(x: 15, y: 2, width: 300, height: 18)
        let label = UILabel(frame: labelRect)
        label.font = UIFont.boldSystemFontOfSize(15)

        label.text = tableView.dataSource!.tableView!(tableView, titleForHeaderInSection: section)

        let viewRect = CGRect(x: 0, y: 0, width: tableView.bounds.size.width, height: tableView.sectionHeaderHeight)
        let view = UIView(frame: viewRect)
        view.backgroundColor = UIColor(white: 0, alpha: 0.05)
        view.addSubview(label)

        return view
    }


    //MARK: - UITableViewDataSource
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath, object: PFObject?) -> PFTableViewCell {
        
        var cell = tableView.dequeueReusableCellWithIdentifier("companyTableViewCell", forIndexPath: indexPath) as! PFTableViewCell

            
        cell.textLabel!.text = sortedArray.objectAtIndex(indexPath.row).valueForKey("place") as? StringLiteralType

        
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
