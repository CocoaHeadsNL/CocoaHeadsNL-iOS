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
    
    lazy var realm = {
        try! Realm()
    }()
    
    lazy var companiesArray = {
        try! Realm().objects(Company.self).sorted(byKeyPath: "name")
    }()
    
    var placesArray: [String] {
        get {
            var places = Set<String>()
            places.formUnion(companiesArray.flatMap { $0.place })
            return places.map{ $0 }.sorted()
        }
    }

    var sortedByPlace = [String: [Company]]()
    var notificationToken: NotificationToken?
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let backItem = UIBarButtonItem(title: NSLocalizedString("Companies"), style: .plain, target: nil, action: nil)
        self.navigationItem.backBarButtonItem = backItem

        let accessibilityLabel = NSLocalizedString("iOS and macOS development companies")
        self.navigationItem.setupForRootViewController(withTitle: accessibilityLabel)
        
        self.subscribe()
        
        // Set results notification block
        self.notificationToken = companiesArray.addNotificationBlock { (changes: RealmCollectionChange) in
            self.sortCompaniesByPlace()
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
        
        self.sortCompaniesByPlace()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        Answers.logContentView(withName: "Show companies",
                               contentType: "Company",
                               contentId: "overview",
                               customAttributes: nil)
        self.fetchCompanies()
    }
    
    func sortCompaniesByPlace() {
        
        for place in placesArray {
            let companiesForPlace = companiesArray.filter({ $0.place == place }) as [Company]
            sortedByPlace.updateValue(companiesForPlace, forKey: place)
        }
    }

    //MARK: - Segues

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ShowDetail" {

            if let indexPath = self.tableView.indexPath(for: sender as! UITableViewCell) {
                
                let section = indexPath.section
                let place = placesArray[section]
                let companyArray = sortedByPlace[place]
                
                let company = (companyArray?[indexPath.row])!
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
        return placesArray.count
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return NSLocalizedString(placesArray[section])
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let place = placesArray[section]
        if let arrayOfPlace = sortedByPlace[place] {
        return arrayOfPlace.count
        }
        return 0
    }

    //MARK: - UITableViewDataSource

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "defaultCell", for: indexPath)
        
        let section = indexPath.section
        let place = placesArray[section]
        let companyArray = sortedByPlace[place]
        
        let company = companyArray?[indexPath.row]

        cell.textLabel!.text = company?.name
        cell.imageView?.image =  company?.smallLogoImage
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

    //MARK: - fetching Cloudkit
    
    func fetchCompanies() {
        
        let query = CKQuery(recordType: "Companies", predicate: NSPredicate(value: true))
        let operation = CKQueryOperation(query: query)
        operation.qualityOfService = .userInteractive
        
        var companies = [Company]()
        
        operation.recordFetchedBlock = { (record) in
            let company = Company.company(forRecord: record)
            
            companies.append(company)
        }
        
        operation.queryCompletionBlock = { [weak self] (cursor, error) in
            DispatchQueue.main.async {
                guard error == nil else {
                    let ac = UIAlertController.fetchErrorDialog(whileFetching: "companies", error: error!)
                    self?.present(ac, animated: true, completion: nil)
                    return
                }
                
                let companyRecordNames = companies.flatMap({ $0.recordName })
                let predicate = NSPredicate(format: "NOT recordName IN %@", companyRecordNames)
                let obsoleteCompanies = self?.realm.objects(Company.self).filter(predicate)
                
                self?.realm.beginWrite()
                self?.realm.add(companies, update: true)
                if let obsoleteCompanies = obsoleteCompanies {
                    self?.realm.delete(obsoleteCompanies)
                }
                try! self?.realm.commitWrite()
            }
        }
        
        CKContainer.default().publicCloudDatabase.add(operation)
        
    }
}
