//
//  LocatedCompaniesViewController.swift
//  CocoaHeadsNL
//
//  Created by Bart Hoffman on 03/06/15.
//  Copyright (c) 2016 Stichting CocoaheadsNL. All rights reserved.
//

import Foundation
import UIKit
import CloudKit
import Crashlytics
import RealmSwift

class LocatedCompaniesViewController: UITableViewController {
    
    let realm = try! Realm()
    
    var companiesArray = try! Realm().objects(Company.self).sorted(byKeyPath: "name")
    
    var placesArray: [String] {
        get {
            var places = Set<String>()
            places.formUnion(companiesArray.flatMap { $0.place })
            return places.map{ $0 }.sorted()
        }
    }

    //var companiesArray = [Company]()
    var notificationToken: NotificationToken?
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let backItem = UIBarButtonItem(title: NSLocalizedString("Companies"), style: .plain, target: nil, action: nil)
        self.navigationItem.backBarButtonItem = backItem
        
        self.navigationItem.titleView = UIImageView(image: UIImage(named: "Banner")!)
        
        self.subscribe()
        
        // Set results notification block
        self.notificationToken = companiesArray.addNotificationBlock { (changes: RealmCollectionChange) in
            switch changes {
            case .initial:
                // Results are now populated and can be accessed without blocking the UI
                self.tableView.reloadData()
                break
            case .update(_, _, _, _):
                self.tableView.reloadData()
                break
            case .error(let err):
                // An error occurred while opening the Realm file on the background worker thread
                fatalError("\(err)")
                break
            }
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        Answers.logContentView(withName: "Show companies",
                               contentType: "Company",
                               contentId: "overview",
                               customAttributes: nil)
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
    
//    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        if segue.identifier == "ShowCompanies" {
//            if let indexPath = self.tableView.indexPath(for: sender as! UITableViewCell) {
//                
//                let detailViewController = segue.destination as? LocatedCompaniesViewController
//                
//                let place = placesArray[(indexPath as NSIndexPath).row]
//                
//                detailViewController?.companiesArray = companiesArray.filter({ $0.place == place })
//                
//                Answers.logContentView(withName: "Show company location",
//                                       contentType: "Company",
//                                       contentId: placesArray[(indexPath as NSIndexPath).row],
//                                       customAttributes: nil)
//            }
//        }
//    }

    //MARK: - UITableViewDelegate

    override func numberOfSections(in tableView: UITableView) -> Int {
        return placesArray.count
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return NSLocalizedString(placesArray[section])
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
    
    //MARK: - Notifications
    
    func subscribe() {
        let publicDB = CKContainer.default().publicCloudDatabase
        
        let subscription = CKSubscription(
            recordType: "Companies",
            predicate: NSPredicate(value: true),
            options: .firesOnRecordCreation
        )
        
        let info = CKNotificationInfo()
        
        info.alertBody = NSLocalizedString("A new company has been added!")
        info.shouldBadge = true
        
        subscription.notificationInfo = info
        
        publicDB.save(subscription, completionHandler: { record, error in })
    }


}
