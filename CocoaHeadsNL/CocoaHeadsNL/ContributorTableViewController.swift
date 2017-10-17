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
import Crashlytics
import RealmSwift

class ContributorTableViewController: UITableViewController {

    lazy var realm = {
        try! Realm()
    }()

    lazy var contributors = {
        try! Realm().objects(Contributor.self).sorted(byKeyPath: "commit_count", ascending: false)
    }()
    
    var notificationToken: NotificationToken?

    //MARK: - View LifeCycle

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let backItem = UIBarButtonItem(title: NSLocalizedString("About"), style: .plain, target: nil, action: nil)
        self.navigationItem.backBarButtonItem = backItem

        let accessibilityLabel = NSLocalizedString("About CocoaHeadsNL")
        self.navigationItem.setupForRootViewController(withTitle: accessibilityLabel)

        // Set results notification block
        self.notificationToken = contributors.addNotificationBlock { (changes: RealmCollectionChange) in
            switch changes {
            case .initial:
                // Results are now populated and can be accessed without blocking the UI
                self.tableView.reloadData()
                break
            case .update(_, let deletions, let insertions, let modifications):
                // Query results have changed, so apply them to the TableView
                self.tableView.beginUpdates()
                self.tableView.insertRows(at: insertions.map { IndexPath(row: $0, section: 0) },
                                          with: .automatic)
                self.tableView.deleteRows(at: deletions.map { IndexPath(row: $0, section: 0) },
                                          with: .automatic)
                self.tableView.reloadRows(at: modifications.map { IndexPath(row: $0, section: 0) },
                                          with: .automatic)
                self.tableView.endUpdates()
                break
            case .error(let err):
                // An error occurred while opening the Realm file on the background worker thread
                fatalError("\(err)")
                break
            }
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        self.fetchContributors()
    }

    //MARK: - UITableViewDataSource

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        return self.contributors.count

    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCell(withIdentifier: "contributorCell", for: indexPath)

        let contributor = self.contributors[indexPath.row]

        cell.textLabel?.text = contributor.name
        cell.detailTextLabel?.text = contributor.url

        if let avatar_url = contributor.avatar_url, let url = URL(string: avatar_url) {
            let task = fetchImageTask(url, forImageView: cell.imageView!)
            task.resume()
        }


        return cell

    }


    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }

    override func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return CGFloat(88)
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return NSLocalizedString("Contributors to this app")
    }

    //MARK: - UITableViewDelegate

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        let urlString = contributors[indexPath.row].url

        Answers.logContentView(withName: "Show contributer details",
                                       contentType: "Contributer",
                                       contentId: urlString,
                                       customAttributes: nil)

        if let urlString = urlString, let url = URL(string: urlString) {
            if UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.openURL(url)
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
        let task = remoteSession.dataTask(with: URLRequest(url: url), completionHandler: {
            (data, response, error) in
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

        Answers.logContentView(withName: "Show contributers",
                                       contentType: "Contributer",
                                       contentId: "overview",
                                       customAttributes: nil)
    }


    //MARK: - fetching Cloudkit

    func fetchContributors() {

        let pred = NSPredicate(value: true)
        let query = CKQuery(recordType: "Contributor", predicate: pred)

        let operation = CKQueryOperation(query: query)
        operation.qualityOfService = .userInteractive

        var cloudContributors = [Contributor]()

        operation.recordFetchedBlock = { (record) in
            let contributor = Contributor.contributor(forRecord: record)
            cloudContributors.append(contributor)
        }

        operation.queryCompletionBlock = { [weak self] (cursor, error) in
            DispatchQueue.main.async {
                guard error == nil else {
                    let ac = UIAlertController.fetchErrorDialog(whileFetching: "contributors", error: error!)
                    self?.present(ac, animated: true, completion: nil)
                    return
                }
                self?.realm.beginWrite()
                self?.realm.add(cloudContributors, update: true)
                try! self?.realm.commitWrite()
            }
        }

        CKContainer.default().publicCloudDatabase.add(operation)

    }


}
