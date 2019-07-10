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

    private lazy var fetchedResultsController: FetchedResultsController<Company> = {
        let fetchRequest = NSFetchRequest<Company>()
        fetchRequest.entity = Company.entity()
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "place", ascending: true), NSSortDescriptor(key: "name", ascending: true)]
        let frc = FetchedResultsController<Company>(fetchRequest: fetchRequest,
                                                        managedObjectContext: CoreDataStack.shared.viewContext,
                                                        sectionNameKeyPath: "place")
        frc.setDelegate(self.frcDelegate)
        return frc
    }()

    private lazy var frcDelegate: CompanyFetchedResultsControllerDelegate = { // swiftlint:disable:this weak_delegate
        return CompanyFetchedResultsControllerDelegate(tableView: self.tableView)
    }()

    var sortedByPlace = [String: [Company]]()

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.tableFooterView = UIView()

        let backItem = UIBarButtonItem(title: NSLocalizedString("Companies"), style: .plain, target: nil, action: nil)
        self.navigationItem.backBarButtonItem = backItem

        let accessibilityLabel = NSLocalizedString("iOS and macOS development companies")
        self.navigationItem.setupForRootViewController(withTitle: accessibilityLabel)

        self.subscribe()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        try? fetchedResultsController.performFetch()
        self.fetchCompanies()
    }

    // MARK: - Segues

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ShowDetail" {

            if let indexPath = self.tableView.indexPath(for: sender as! UITableViewCell) {

                guard let sections = fetchedResultsController.sections else {
                    fatalError("FetchedResultsController \(fetchedResultsController) should have sections, but found nil")
                }

                let section = sections[indexPath.section]
                let company = section.objects[indexPath.row]

                let dataSource = CompanyDataSource(object: company)

                let detailViewController = segue.destination as? DetailViewController
                detailViewController?.dataSource = dataSource
            }
        }
    }

    // MARK: - UITableViewDelegate

    override func numberOfSections(in tableView: UITableView) -> Int {
        return fetchedResultsController.sectionCount
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        guard let sections = fetchedResultsController.sections else {
            fatalError("FetchedResultsController \(fetchedResultsController) should have sections, but found nil")
        }

        return NSLocalizedString(sections[section].name ?? "")
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        guard let sections = fetchedResultsController.sections else {
            fatalError("FetchedResultsController \(fetchedResultsController) should have sections, but found nil")
        }

        return sections[section].objects.count
    }

    // MARK: - UITableViewDataSource

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "defaultCell", for: indexPath)

        guard let sections = fetchedResultsController.sections else {
            fatalError("FetchedResultsController \(fetchedResultsController) should have sections, but found nil")
        }

        let section = sections[indexPath.section]
        let company = section.objects[indexPath.row]

        cell.textLabel!.text = company.name
        cell.imageView?.image =  company.smallLogoImage
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

        let context = CoreDataStack.shared.newBackgroundContext

        operation.recordFetchedBlock = { (record) in
            if let company = Company.company(forRecord: record, on: context) {
                companies.append(company)
            }
        }

        operation.queryCompletionBlock = { [weak self] (cursor, error) in
            guard error == nil else {
                DispatchQueue.main.async {
                    let ac = UIAlertController.fetchErrorDialog(whileFetching: "companies", error: error!)
                    self?.present(ac, animated: true, completion: nil)
                }
                return
            }

            context.perform {
                do {
                    try Company.removeAllInContext(context, except: companies)
                    context.saveContextToStore()
                } catch {
                    //Do nothing
                    print("Error while updating companies: \(error)")
                }
            }
        }

        CKContainer.default().publicCloudDatabase.add(operation)
    }
}

class CompanyFetchedResultsControllerDelegate: NSObject, FetchedResultsControllerDelegate {

    private weak var tableView: UITableView?

    // MARK: - Lifecycle
    init(tableView: UITableView) {
        self.tableView = tableView
    }

    func fetchedResultsControllerDidPerformFetch(_ controller: FetchedResultsController<Company>) {
        tableView?.reloadData()
    }

    func fetchedResultsControllerWillChangeContent(_ controller: FetchedResultsController<Company>) {
        tableView?.beginUpdates()
    }

    func fetchedResultsControllerDidChangeContent(_ controller: FetchedResultsController<Company>) {
        tableView?.endUpdates()
    }

    func fetchedResultsController(_ controller: FetchedResultsController<Company>, didChangeObject change: FetchedResultsObjectChange<Company>) {
        guard let tableView = tableView else { return }
        switch change {
        case let .insert(_, indexPath):
            tableView.insertRows(at: [indexPath], with: .automatic)

        case let .delete(_, indexPath):
            tableView.deleteRows(at: [indexPath], with: .automatic)

        case let .move(_, fromIndexPath, toIndexPath):
            tableView.moveRow(at: fromIndexPath, to: toIndexPath)

        case let .update(_, indexPath):
            tableView.reloadRows(at: [indexPath], with: .automatic)
        }
    }

    func fetchedResultsController(_ controller: FetchedResultsController<Company>, didChangeSection change: FetchedResultsSectionChange<Company>) {
        guard let tableView = tableView else { return }
        switch change {
        case let .insert(_, index):
            tableView.insertSections(IndexSet(integer: index), with: .automatic)

        case let .delete(_, index):
            tableView.deleteSections(IndexSet(integer: index), with: .automatic)
        }
    }
}
