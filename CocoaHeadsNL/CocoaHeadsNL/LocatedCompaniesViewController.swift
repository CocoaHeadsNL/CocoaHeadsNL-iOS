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

    var companiesArray = [Company]()

    override func viewDidLoad() {
        super.viewDidLoad()

        let backItem = UIBarButtonItem(title: NSLocalizedString("Companies"), style: .plain, target: nil, action: nil)
        self.navigationItem.backBarButtonItem = backItem
    }

    //MARK: - Segues

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ShowDetail" {

            if let indexPath = self.tableView.indexPath(for: sender as! UITableViewCell) {
                let company = companiesArray[(indexPath as NSIndexPath).row]
                let dataSource = CompanyDataSource(object: company)
                dataSource.fetchAffiliateLinks()

                let detailViewController = segue.destination as! DetailViewController
                detailViewController.dataSource = dataSource

                Answers.logContentView(withName: "Show company details",
                                               contentType: "Company",
                                               contentId: company.name!,
                                               customAttributes: nil)

            }
        }
    }

    //MARK: - UITableViewDelegate

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return companiesArray.count
    }

    //MARK: - UITableViewDataSource

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "defaultCell", for: indexPath)

        let company = companiesArray[(indexPath as NSIndexPath).row]

        cell.textLabel!.text = company.name
        cell.imageView?.image =  company.smallLogoImage
        return cell
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 44
    }

    //MARK: - UITableViewDelegate

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.tableView.deselectRow(at: indexPath, animated: true)
        self.performSegue(withIdentifier: "ShowDetail", sender: tableView.cellForRow(at: indexPath))
    }

}
