//
//  ContributorTableViewController.swift
//  CocoaHeadsNL
//
//  Created by Bart Hoffman on 06/02/16.
//  Copyright © 2016 Stichting CocoaheadsNL. All rights reserved.
//

import Foundation
import UIKit
import CloudKit
import CoreData

class ContributorTableViewController: UITableViewController {

    private lazy var fetchedResultsController: FetchedResultsController<Contributor> = {
        let fetchRequest = NSFetchRequest<Contributor>()
        fetchRequest.entity = Contributor.entity()
        fetchRequest.predicate = NSPredicate(format: "commitCount > 10")
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "commitCount", ascending: false), NSSortDescriptor(key: "name", ascending: true)]
        let frc = FetchedResultsController<Contributor>(fetchRequest: fetchRequest,
                                                   managedObjectContext: CoreDataStack.shared.viewContext,
                                                   sectionNameKeyPath: nil)
        frc.setDelegate(self.frcDelegate)
        return frc
    }()

    private lazy var frcDelegate: ContributorFetchedResultsControllerDelegate = { // swiftlint:disable:this weak_delegate
        return ContributorFetchedResultsControllerDelegate(tableView: self.tableView)
    }()

    // MARK: - View LifeCycle

    @IBOutlet weak var tableHeaderView: UIView!
    @IBOutlet weak var whatIsLabel: UILabel!
    @IBOutlet weak var whatIsExplanationLabel: UILabel!
    @IBOutlet weak var howDoesItWorkLabel: UILabel!
    @IBOutlet weak var howDoesItWorkExplanationLabel: UILabel!
    @IBOutlet weak var versionLabel: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.tableFooterView = UIView()

        let backItem = UIBarButtonItem(title: NSLocalizedString("About"), style: .plain, target: nil, action: nil)
        self.navigationItem.backBarButtonItem = backItem

        let accessibilityLabel = NSLocalizedString("About CocoaHeadsNL")
        self.navigationItem.setupForRootViewController(withTitle: accessibilityLabel)

        applyAccessibility()
    }

    private func applyAccessibility() {

        let what = NSLocalizedString("What is Cocoaheads?")
        let whatAnswer = NSLocalizedString("A monthly meeting of iOS and Mac developers in the Netherlands and part of the international CocoaHeads.org.")
        let how = NSLocalizedString("How does it work?")
        let howAnswer = NSLocalizedString("Every month we organize a meeting at a different venue including food and drinks sponsored by companies. Depending on the size of the location we put together a nice agenda for developers.")

        if let dictionary = Bundle.main.infoDictionary, let version = dictionary["CFBundleShortVersionString"] as? String, let build = dictionary["CFBundleVersion"] as? String {
            let versionInfo = "\(version) (\(build))"
            versionLabel.text = versionInfo
        }

        whatIsLabel.text = what
        whatIsExplanationLabel.text = whatAnswer
        howDoesItWorkLabel.text = how
        howDoesItWorkExplanationLabel.text = howAnswer

        tableHeaderView.isAccessibilityElement = true
        tableHeaderView.accessibilityLabel = [what, whatAnswer, how, howAnswer].joined(separator: " ")
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        try? fetchedResultsController.performFetch()

        self.fetchContributors()
    }

    // MARK: - UITableViewDataSource

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return fetchedResultsController.sections?[section].objects.count ?? 0
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCell(withIdentifier: "contributorCell", for: indexPath)

        guard let sections = fetchedResultsController.sections else {
            fatalError("FetchedResultsController \(fetchedResultsController) should have sections, but found nil")
        }

        let section = sections[indexPath.section]
        let contributor = section.objects[indexPath.row]

        if let avatarUrl = contributor.avatarUrl, let url = URL(string: avatarUrl) {
            let task = fetchImageTask(url, forImageView: cell.imageView!)
            task.resume()
        } else {
            cell.imageView!.image = #imageLiteral(resourceName: "CocoaHeadsNLLogo")
        }
        cell.textLabel?.text = contributor.name ?? NSLocalizedString("Anonymous")

        cell.accessibilityTraits = UIAccessibilityTraits(rawValue: cell.accessibilityTraits.rawValue | UIAccessibilityTraits.button.rawValue)
        cell.accessibilityHint = NSLocalizedString("Double-tap to open the Github profile page of \(contributor.name ?? NSLocalizedString("this contributor")) in Safari.")

        return cell
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }

    override func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return CGFloat(88)
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return NSLocalizedString("Contributors to this app with 10 or more commits")
    }

    // MARK: - UITableViewDelegate

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        guard let sections = fetchedResultsController.sections else {
            fatalError("FetchedResultsController \(fetchedResultsController) should have sections, but found nil")
        }

        let section = sections[indexPath.section]
        let urlString = section.objects[indexPath.row].url

        if let urlString = urlString, let url = URL(string: urlString) {
            if UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.open(url, options: convertToUIApplicationOpenExternalURLOptionsKeyDictionary([:]), completionHandler: { _ in
                })
            }
        }

        tableView.deselectRow(at: indexPath, animated: true)
    }

    // MARK: Networking

    lazy var remoteSession: URLSession = {
        let config = URLSessionConfiguration.default
        return URLSession(configuration: config)
    }()

    func fetchImageTask(_ url: URL, forImageView imageView: UIImageView) -> URLSessionDataTask {
        let task = remoteSession.dataTask(with: URLRequest(url: url), completionHandler: { data, _, _ in
            if let data = data {
                let image = UIImage(data: data)
                DispatchQueue.main.async {
                    imageView.image = image
                }
            }
        })
        return task
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }

    // MARK: - fetching Cloudkit

    func fetchContributors() {

        let pred = NSPredicate(value: true)
        let query = CKQuery(recordType: "Contributor", predicate: pred)

        let operation = CKQueryOperation(query: query)
        operation.qualityOfService = .userInteractive

        let context = CoreDataStack.shared.newBackgroundContext

        operation.recordFetchedBlock = { record in
            context.perform {
                _ = try? Contributor.contributor(forRecord: record, on: context)
            }
        }

        operation.queryCompletionBlock = { [weak self] cursor, error in
            guard error == nil else {
                DispatchQueue.main.async {
                    let alertController = UIAlertController.fetchErrorDialog(whileFetching: "contributors", error: error!)
                    self?.present(alertController, animated: true, completion: nil)
                }
                return
            }
            context.perform {
                context.saveContextToStore()
            }
        }

        CKContainer.default().publicCloudDatabase.add(operation)

    }
}

// swiftlint:disable:next type_name
class ContributorFetchedResultsControllerDelegate: NSObject, FetchedResultsControllerDelegate {

    private weak var tableView: UITableView?

    // MARK: - Lifecycle
    init(tableView: UITableView) {
        self.tableView = tableView
    }

    func fetchedResultsControllerDidPerformFetch(_ controller: FetchedResultsController<Contributor>) {
        tableView?.reloadData()
    }

    func fetchedResultsControllerWillChangeContent(_ controller: FetchedResultsController<Contributor>) {
        tableView?.beginUpdates()
    }

    func fetchedResultsControllerDidChangeContent(_ controller: FetchedResultsController<Contributor>) {
        tableView?.endUpdates()
    }

    func fetchedResultsController(_ controller: FetchedResultsController<Contributor>, didChangeObject change: FetchedResultsObjectChange<Contributor>) {
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

    func fetchedResultsController(_ controller: FetchedResultsController<Contributor>, didChangeSection change: FetchedResultsSectionChange<Contributor>) {
        guard let tableView = tableView else { return }
        switch change {
        case let .insert(_, index):
            tableView.insertSections(IndexSet(integer: index), with: .automatic)

        case let .delete(_, index):
            tableView.deleteSections(IndexSet(integer: index), with: .automatic)
        }
    }
}

// Helper function inserted by Swift 4.2 migrator.
private func convertToUIApplicationOpenExternalURLOptionsKeyDictionary(_ input: [String: Any]) -> [UIApplication.OpenExternalURLOptionsKey: Any] {
	return Dictionary(uniqueKeysWithValues: input.map { key, value in (UIApplication.OpenExternalURLOptionsKey(rawValue: key), value) })
}
