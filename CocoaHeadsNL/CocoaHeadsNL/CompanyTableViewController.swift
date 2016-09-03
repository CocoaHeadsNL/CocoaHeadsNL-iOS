//
//  CompanyTableViewController.swift
//  CocoaHeadsNL
//
//  Created by Bart Hoffman on 30/05/15.
//  Copyright (c) 2016 Stichting CocoaheadsNL. All rights reserved.
//

import Foundation
import UIKit
import CloudKit
import Crashlytics
import RealmSwift

class CompanyTableViewController: UITableViewController {

    let realm = try! Realm()
    
    var companiesArray = try! Realm().objects(Company.self).sorted("name")
    
    var placesArray: [String] {
        get {
            var places = Set<String>()
            places.unionInPlace(companiesArray.flatMap { $0.place })
            return places.map{ $0 }.sort()
        }
    }

//    var sortedArray = [(place: String, companies:[Company])]()
    var notificationToken: NotificationToken?

    @IBOutlet weak var sortingLabel: UILabel!

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        let backItem = UIBarButtonItem(title: "Companies", style: .Plain, target: nil, action: nil)
        self.navigationItem.backBarButtonItem = backItem

        self.navigationItem.titleView = UIImageView(image: UIImage(named: "Banner")!)

        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(CompanyTableViewController.locationAvailable(_:)), name: "LOCATION_AVAILABLE", object: nil)

        self.subscribe()
        
        // Set results notification block
        self.notificationToken = companiesArray.addNotificationBlock { (changes: RealmCollectionChange) in
            switch changes {
            case .Initial:
                // Results are now populated and can be accessed without blocking the UI
                self.tableView.reloadData()
                break
            case .Update(_, _, _, _):
                self.tableView.reloadData()
                break
            case .Error(let err):
                // An error occurred while opening the Realm file on the background worker thread
                fatalError("\(err)")
                break
            }
        }
    }

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)

        Answers.logContentViewWithName("Show companies",
                                       contentType: "Company",
                                       contentId: "overview",
                                       customAttributes: nil)
    }

    func locationAvailable(notification: NSNotification) -> Void {

        let userInfo = notification.userInfo as! Dictionary<String, CLLocation>

        print("CoreLocationManager:  Location available \(userInfo)")

//        if let _ = userInfo["location"]?.coordinate.latitude, _ = userInfo["location"]?.coordinate.longitude {
//            self.sortingLabel?.text = "Companies sorted by distance"
//        } else {
            self.sortingLabel?.text = "Companies sorted by name"
//        }
    }


    //MARK: - Segues

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "ShowCompanies" {
            if let indexPath = self.tableView.indexPathForCell(sender as! UITableViewCell) {

                let detailViewController = segue.destinationViewController as? LocatedCompaniesViewController
                
                let place = placesArray[indexPath.row]
                
                detailViewController?.companiesArray = companiesArray.filter({ $0.place == place })

                Answers.logContentViewWithName("Show company location",
                                               contentType: "Company",
                                               contentId: placesArray[indexPath.row],
                                               customAttributes: nil)
            }
        }
    }

    //MARK: - UITablewViewDelegate

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return placesArray.count
    }

    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Companies sorted by place"
    }

    override func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let labelRect = CGRect(x: 15, y: 2, width: 300, height: 18)
        let label = UILabel(frame: labelRect)
        label.font = UIFont.boldSystemFontOfSize(15)

        label.text = tableView.dataSource!.tableView!(tableView, titleForHeaderInSection: section)

        let viewRect = CGRect(x: 0, y: 0, width: tableView.bounds.size.width, height: tableView.sectionHeaderHeight)
        let view = UIView(frame: viewRect)
        view.backgroundColor = UIColor(red: 247/255, green: 247/255, blue: 247/255, alpha: 1)
        view.addSubview(label)

        return view
    }


    //MARK: - UITableViewDataSource


    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCellWithIdentifier("companyTableViewCell", forIndexPath: indexPath)


        cell.textLabel!.text = placesArray[indexPath.row]


        return cell
    }

    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 44
    }

    //MARK: - UITableViewDelegate

    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        self.performSegueWithIdentifier("ShowCompanies", sender: tableView.cellForRowAtIndexPath(indexPath))
    }

    //MARK: - Notifications

    func subscribe() {
        let publicDB = CKContainer.defaultContainer().publicCloudDatabase

        let subscription = CKSubscription(
            recordType: "Companies",
            predicate: NSPredicate(value: true),
            options: .FiresOnRecordCreation
        )

        let info = CKNotificationInfo()

        info.alertBody = "A new company has been added!"
        info.shouldBadge = true

        subscription.notificationInfo = info

        publicDB.saveSubscription(subscription) { record, error in }
    }
}
