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

    let realm = try! Realm()

    var contributors = try! Realm().objects(Contributor.self).sorted("commit_count", ascending: false)
    var notificationToken: NotificationToken?

    //MARK: - View LifeCycle

    override func viewDidLoad() {
        super.viewDidLoad()

        let backItem = UIBarButtonItem(title: "About", style: .Plain, target: nil, action: nil)
        self.navigationItem.backBarButtonItem = backItem

        self.navigationItem.titleView = UIImageView(image: UIImage(named: "Banner")!)

        // Set results notification block
        self.notificationToken = contributors.addNotificationBlock { (changes: RealmCollectionChange) in
            switch changes {
            case .Initial:
                // Results are now populated and can be accessed without blocking the UI
                self.tableView.reloadData()
                break
            case .Update(_, let deletions, let insertions, let modifications):
                // Query results have changed, so apply them to the TableView
                self.tableView.beginUpdates()
                self.tableView.insertRowsAtIndexPaths(insertions.map { NSIndexPath(forRow: $0, inSection: 0) },
                    withRowAnimation: .Automatic)
                self.tableView.deleteRowsAtIndexPaths(deletions.map { NSIndexPath(forRow: $0, inSection: 0) },
                    withRowAnimation: .Automatic)
                self.tableView.reloadRowsAtIndexPaths(modifications.map { NSIndexPath(forRow: $0, inSection: 0) },
                    withRowAnimation: .Automatic)
                self.tableView.endUpdates()
                break
            case .Error(let err):
                // An error occurred while opening the Realm file on the background worker thread
                fatalError("\(err)")
                break
            }
        }
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)

        self.fetchContributors()
    }

    //MARK: - UITableViewDataSource

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        return self.contributors.count

    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCellWithIdentifier("contributorCell", forIndexPath: indexPath)

        let contributor = self.contributors[indexPath.row]

        cell.textLabel?.text = contributor.name
        cell.detailTextLabel?.text = contributor.url

        if let avatar_url = contributor.avatar_url, url = NSURL(string: avatar_url) {
            let task = fetchImageTask(url, forImageView: cell.imageView!)
            task.resume()
        }


        return cell

    }


    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }

    override func tableView(tableView: UITableView, estimatedHeightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return CGFloat(88)
    }

    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Contributors to this app"
    }

    //MARK: - UITableViewDelegate

    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {

        let urlString = contributors[indexPath.row].url

        Answers.logContentViewWithName("Show contributer details",
                                       contentType: "Contributer",
                                       contentId: urlString,
                                       customAttributes: nil)

        if let urlString = urlString, url = NSURL(string: urlString) {
            if UIApplication.sharedApplication().canOpenURL(url) {
                UIApplication.sharedApplication().openURL(url)
            }
        }

        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }

    // MARK: Networking

    lazy var remoteSession: NSURLSession = {
        let config = NSURLSessionConfiguration.defaultSessionConfiguration()
        return NSURLSession(configuration: config)
    }()

    func fetchImageTask(url: NSURL, forImageView imageView: UIImageView) -> NSURLSessionDataTask {
        let task = remoteSession.dataTaskWithRequest(NSURLRequest(URL: url)) {
            (data, response, error) in
            if let data = data {
                let image = UIImage(data: data)
                dispatch_async(dispatch_get_main_queue()) {
                    imageView.image = image
                }
            }
        }
        return task
    }

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)

        Answers.logContentViewWithName("Show contributers",
                                       contentType: "Contributer",
                                       contentId: "overview",
                                       customAttributes: nil)
    }


    //MARK: - fetching Cloudkit

    func fetchContributors() {

        let pred = NSPredicate(value: true)
        let query = CKQuery(recordType: "Contributor", predicate: pred)

        let operation = CKQueryOperation(query: query)
        operation.qualityOfService = .UserInteractive

        var cloudContributors = [Contributor]()

        operation.recordFetchedBlock = { (record) in
            let contributor = Contributor.contributor(forRecord: record)
            cloudContributors.append(contributor)
        }

        operation.queryCompletionBlock = { [weak self] (cursor, error) in
            dispatch_async(dispatch_get_main_queue()) {
                if error == nil {

                    self?.realm.beginWrite()
                    self?.realm.add(cloudContributors, update: true)
                    try! self?.realm.commitWrite()

                } else {
                    let ac = UIAlertController(title: "Fetch failed", message: "There was a problem fetching the list of contributors; please try again: \(error!.localizedDescription)", preferredStyle: .Alert)
                    ac.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
                    self?.presentViewController(ac, animated: true, completion: nil)
                }
            }
        }

        CKContainer.defaultContainer().publicCloudDatabase.addOperation(operation)

    }


}
