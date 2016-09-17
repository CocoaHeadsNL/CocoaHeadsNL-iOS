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
    
    var companiesArray = try! Realm().objects(Company.self).sorted(byProperty: "name")
    
    var placesArray: [String] {
        get {
            var places = Set<String>()
            places.formUnion(companiesArray.flatMap { $0.place })
            return places.map{ $0 }.sorted()
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

        let backItem = UIBarButtonItem(title: "Companies", style: .plain, target: nil, action: nil)
        self.navigationItem.backBarButtonItem = backItem

        self.navigationItem.titleView = UIImageView(image: UIImage(named: "Banner")!)

        NotificationCenter.default.addObserver(self, selector: #selector(CompanyTableViewController.locationAvailable(_:)), name: NSNotification.Name(rawValue: "LOCATION_AVAILABLE"), object: nil)

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

    func locationAvailable(_ notification: Notification) -> Void {

        let userInfo = (notification as NSNotification).userInfo as! Dictionary<String, CLLocation>

        print("CoreLocationManager:  Location available \(userInfo)")

//        if let _ = userInfo["location"]?.coordinate.latitude, _ = userInfo["location"]?.coordinate.longitude {
//            self.sortingLabel?.text = "Companies sorted by distance"
//        } else {
            self.sortingLabel?.text = "Companies sorted by name"
//        }
    }


    //MARK: - Segues

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ShowCompanies" {
            if let indexPath = self.tableView.indexPath(for: sender as! UITableViewCell) {

                let detailViewController = segue.destination as? LocatedCompaniesViewController
                
                let place = placesArray[(indexPath as NSIndexPath).row]
                
                detailViewController?.companiesArray = companiesArray.filter({ $0.place == place })

                Answers.logContentView(withName: "Show company location",
                                               contentType: "Company",
                                               contentId: placesArray[(indexPath as NSIndexPath).row],
                                               customAttributes: nil)
            }
        }
    }

    //MARK: - UITablewViewDelegate

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return placesArray.count
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Companies sorted by place"
    }

    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let labelRect = CGRect(x: 15, y: 2, width: 300, height: 18)
        let label = UILabel(frame: labelRect)
        label.font = UIFont.boldSystemFont(ofSize: 15)

        label.text = tableView.dataSource!.tableView!(tableView, titleForHeaderInSection: section)

        let viewRect = CGRect(x: 0, y: 0, width: tableView.bounds.size.width, height: tableView.sectionHeaderHeight)
        let view = UIView(frame: viewRect)
        view.backgroundColor = UIColor(red: 247/255, green: 247/255, blue: 247/255, alpha: 1)
        view.addSubview(label)

        return view
    }


    //MARK: - UITableViewDataSource


    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCell(withIdentifier: "companyTableViewCell", for: indexPath)


        cell.textLabel!.text = placesArray[(indexPath as NSIndexPath).row]


        return cell
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 44
    }

    //MARK: - UITableViewDelegate

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.performSegue(withIdentifier: "ShowCompanies", sender: tableView.cellForRow(at: indexPath))
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

        info.alertBody = "A new company has been added!"
        info.shouldBadge = true

        subscription.notificationInfo = info

        publicDB.save(subscription, completionHandler: { record, error in }) 
    }
}
