//
//  LocatedCompaniesViewController.swift
//  CocoaHeadsNL
//
//  Created by Bart Hoffman on 03/06/15.
//  Copyright (c) 2016 Stichting CocoaheadsNL. All rights reserved.
//

import Foundation
import UIKit
import Crashlytics

class LocatedCompaniesViewController: UITableViewController {

    var companyDict: (place: String, companies: [Company])?
    var companiesArray = [Company]()

    override func viewDidLoad() {
        super.viewDidLoad()

        let backItem = UIBarButtonItem(title: "Companies", style: .Plain, target: nil, action: nil)
        self.navigationItem.backBarButtonItem = backItem
    }

    override func viewWillAppear(animated: Bool) {

            if let companiesArray = companyDict?.companies {
                self.companiesArray = companiesArray
            }
    }

    //MARK: - Segues

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "ShowDetail" {

            if let indexPath = self.tableView.indexPathForCell(sender as! UITableViewCell) {
                let company = companiesArray[indexPath.row]
                let dataSource = CompanyDataSource(object: company)
                dataSource.fetchAffiliateLinks()

                let detailViewController = segue.destinationViewController as! DetailViewController
                detailViewController.dataSource = dataSource

                Answers.logContentViewWithName("Show company details",
                                               contentType: "Company",
                                               contentId: company.name!,
                                               customAttributes: nil)

            }
        }
    }

    //MARK: - UITableViewDelegate

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return companiesArray.count
    }

    //MARK: - UITableViewDataSource

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("defaultCell", forIndexPath: indexPath)

        let company = companiesArray[indexPath.row]

        cell.textLabel!.text = company.name
        cell.imageView?.image =  company.smallLogoImage
        return cell
    }

    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 44
    }

    //MARK: - UITableViewDelegate

    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        self.tableView.deselectRowAtIndexPath(indexPath, animated: true)
        self.performSegueWithIdentifier("ShowDetail", sender: tableView.cellForRowAtIndexPath(indexPath))
    }

}
