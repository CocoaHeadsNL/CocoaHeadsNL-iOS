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
import CoreData

class LocatedCompaniesViewController: UITableViewController {

    lazy var companiesArray: [Company] = {
        return try? Company.allInContext(CoreDataStack.shared.viewContext, sortDescriptors: [NSSortDescriptor(key: "name", ascending: true)])
    }() ?? []

    var placesArray: [String] {
        get {
            var places = Set<String>()
            places.formUnion(companiesArray.compactMap { $0.place })
            return places.map { $0 }.sorted()
        }
    }

    var sortedByPlace = [String: [Company]]()

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

        self.sortCompaniesByPlace()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        self.fetchCompanies()
    }

    func sortCompaniesByPlace() {

        for place in placesArray {
            let companiesForPlace = companiesArray.filter({ $0.place == place }) as [Company]
            sortedByPlace.updateValue(companiesForPlace, forKey: place)
        }
    }

    // MARK: - Segues

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
            }
        }
    }

    // MARK: - UITableViewDelegate

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

    // MARK: - UITableViewDataSource

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

    // MARK: - UITableViewDelegate

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.tableView.deselectRow(at: indexPath, animated: true)
        self.performSegue(withIdentifier: "ShowDetail", sender: tableView.cellForRow(at: indexPath))
    }

    // MARK: - Notifications

    func subscribe() {
        let publicDB = CKContainer.default().publicCloudDatabase

        let subscription = CKQuerySubscription(recordType: "Companies", predicate: NSPredicate(format: "TRUEPREDICATE"), options: .firesOnRecordCreation)

        let info = CKSubscription.NotificationInfo()

        info.alertBody = NSLocalizedString("A new company has been added!")
        info.shouldBadge = true
        info.category = "COMPANY"

        subscription.notificationInfo = info

        publicDB.save(subscription, completionHandler: { _, _ in })
    }

    // MARK: - fetching Cloudkit

    func fetchCompanies() {

        let query = CKQuery(recordType: "Companies", predicate: NSPredicate(value: true))
        let operation = CKQueryOperation(query: query)
        operation.qualityOfService = .userInteractive

        var companies = [Company]()

        operation.recordFetchedBlock = { (record) in
            let company = Company.company(forRecord: record, on: CoreDataStack.shared.viewContext)

            companies.append(company)
        }

        operation.queryCompletionBlock = { [weak self] (cursor, error) in
            DispatchQueue.main.async {
                guard error == nil else {
                    let ac = UIAlertController.fetchErrorDialog(whileFetching: "companies", error: error!)
                    self?.present(ac, animated: true, completion: nil)
                    return
                }

                let companyRecordNames = companies.compactMap({ $0.recordName })
                let predicate = NSPredicate(format: "NOT recordName IN %@", companyRecordNames)
                // TODO: write items to CoreData
//                let obsoleteCompanies = self?.realm.objects(Company.self).filter(predicate)
//
//                self?.realm.beginWrite()
//                self?.realm.add(companies, update: true)
//                if let obsoleteCompanies = obsoleteCompanies {
//                    self?.realm.delete(obsoleteCompanies)
//                }
//                try! self?.realm.commitWrite()
            }
        }

        CKContainer.default().publicCloudDatabase.add(operation)

    }
}
