//
//  MeetupsViewController
//  CocoaHeadsNL
//
//  Created by Jeroen Leenarts on 09-03-15.
//  Copyright (c) 2016 Stichting CocoaheadsNL. All rights reserved.
//

import Foundation
import UIKit
import CoreSpotlight
import CloudKit
import Crashlytics
import RealmSwift

class MeetupsViewController: UITableViewController, UIViewControllerPreviewingDelegate {

    let realm = try! Realm()

    var meetupsArray = try! Realm().objects(Meetup.self).sorted(byProperty: "time", ascending: false)
    var searchedObjectId: String? = nil
    var notificationToken: NotificationToken?


    weak var activityIndicatorView: UIActivityIndicatorView!

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

    }

    override func viewDidLoad() {
        super.viewDidLoad()

        //self.tableView.registerClass(MeetupCell.self, forCellReuseIdentifier: MeetupCell.Identifier)
        let nib = UINib(nibName: "MeetupCell", bundle: nil)
        self.tableView.register(nib, forCellReuseIdentifier: MeetupCell.Identifier)

        let backItem = UIBarButtonItem(title: "Events", style: .plain, target: nil, action: nil)
        self.navigationItem.backBarButtonItem = backItem

        self.navigationItem.titleView = UIImageView(image: UIImage(named: "Banner")!)

        let calendarIcon = UIImage.calendarTabImageWithCurrentDate()
        self.navigationController?.tabBarItem.image = calendarIcon
        self.navigationController?.tabBarItem.selectedImage = calendarIcon

        //Inspect paste board for userInfo
        if let pasteBoard = UIPasteboard(name: UIPasteboardName(rawValue: searchPasteboardName), create: false) {
            let uniqueIdentifier = pasteBoard.string
            if let components = uniqueIdentifier?.components(separatedBy: ":") {
                if components.count > 1 {
                    let objectId = components[1]
                    displayObject(objectId)
                }
            }
        }


        NotificationCenter.default.addObserver(self, selector: #selector(MeetupsViewController.searchOccured(_:)), name: NSNotification.Name(rawValue: searchNotificationName), object: nil)
        
        // Set results notification block
        self.notificationToken = meetupsArray.addNotificationBlock { (changes: RealmCollectionChange) in
            switch changes {
            case .initial:
                // Results are now populated and can be accessed without blocking the UI
                self.tableView.reloadData()
                break
            case .update(_, let deletions, let insertions, let modifications):
                // Query results have changed, so apply them to the TableView
                self.tableView.beginUpdates()
                self.tableView.insertRows(at: insertions.map { (NSIndexPath(row: $0, section: 0) as IndexPath) },
                                          with: .automatic)
                self.tableView.deleteRows(at: deletions.map { (NSIndexPath(row: $0, section: 0) as IndexPath) },
                                          with: .automatic)
                self.tableView.reloadRows(at: modifications.map { (NSIndexPath(row: $0, section: 0) as IndexPath) },
                                          with: .automatic)
                self.tableView.endUpdates()
                break
            case .error(let err):
                // An error occurred while opening the Realm file on the background worker thread
                fatalError("\(err)")
                break
            }
        }

        if #available(iOS 9.0, *) {
            if traitCollection.forceTouchCapability == .available {
                registerForPreviewing(with: self, sourceView: view)
            }
        } else {
            // Fallback on earlier versions
        }

        self.discover()
        self.subscribe()

        let activityIndicatorView = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.gray)
        tableView.backgroundView = activityIndicatorView
        self.activityIndicatorView = activityIndicatorView

        if meetupsArray.count == 0 {
            activityIndicatorView.startAnimating()
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        self.fetchMeetups()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        if let searchedObjectId = searchedObjectId {
            self.searchedObjectId = nil
            displayObject(searchedObjectId)
        }

        Answers.logContentView(withName: "Show meetups",
                                       contentType: "Meetup",
                                       contentId: "overview",
                                       customAttributes: nil)
    }

    func discover() {

        let container = CKContainer.default()

        container.requestApplicationPermission(CKApplicationPermissions.userDiscoverability) { (status, error) in
            guard error == nil else { return }

            if status == CKApplicationPermissionStatus.granted {
                // User allowed for searching on email
                container.fetchUserRecordID { (recordID, error) in
                    guard error == nil else { return }
                    guard let recordID = recordID else { return }

                    container.discoverUserInfo(withUserRecordID: recordID) { (info, fetchError) in
                        // TODO check for deprecation and save to userRecord?
                        if let error = fetchError {
                            print("error dicovering user info: \(error)")
                            return
                        }

                        guard let info = info else {
                            print("error dicovering user info, info is nil for unknown reason")
                            return
                        }

                        container.publicCloudDatabase.fetch(withRecordID: recordID, completionHandler: { (userRecord, error) in
                            if let error = fetchError {
                                print("error dicovering user record: \(error)")
                                return
                            }

                            if let record = userRecord {
                                record["firstName"] = info.firstName as CKRecordValue?
                                record["lastName"] = info.lastName as CKRecordValue?

                                container.publicCloudDatabase.save(record, completionHandler: { (record, error) in
                                    //print(record)
                                })
                            }
                        })
                    }
                }
            }
        }
    }

    func subscribe() {
        let publicDB = CKContainer.default().publicCloudDatabase

        let subscription = CKSubscription(
            recordType: "Meetup",
            predicate: NSPredicate(value: true),
            options: .firesOnRecordCreation
        )

        let info = CKNotificationInfo()

        info.alertBody = "New meetup has been added!"
        info.shouldBadge = true

        subscription.notificationInfo = info

        publicDB.save(subscription, completionHandler: { record, error in }) 
    }

    //MARK: - 3D Touch

    func previewingContext(_ previewingContext: UIViewControllerPreviewing, viewControllerForLocation location: CGPoint) -> UIViewController? {
        //quick peek
        guard let indexPath = tableView.indexPathForRow(at: location), let cell = tableView.cellForRow(at: indexPath) as? MeetupCell
            else { return nil }

        let vcId = "detailViewController"

        guard let detailVC = storyboard?.instantiateViewController(withIdentifier: vcId) as? DetailViewController
            else { return nil }

        if #available(iOS 9.0, *) {

            let meetup = self.meetupsArray[indexPath.row]
            detailVC.dataSource = MeetupDataSource(object: meetup )
            detailVC.presentingVC  = self

            previewingContext.sourceRect = cell.frame

            return detailVC

        } else {
            // Fallback on earlier versions
            return nil
        }
    }

    func previewingContext(_ previewingContext: UIViewControllerPreviewing, commit viewControllerToCommit: UIViewController) {
        //push to detailView - pop forceTouch window
        show(viewControllerToCommit, sender: self)
    }


    //MARK: - Search

    func searchOccured(_ notification: Notification) -> Void {
        guard let userInfo = (notification as NSNotification).userInfo as? Dictionary<String, String> else {
            return
        }

        let type = userInfo["type"]

        if type != "meetup" {
            //Not for me
            return
        }
        if let objectId = userInfo["objectId"] {
            displayObject(objectId)
        }
    }

    func displayObject(_ recordName: String) -> Void {
        //if !loading {
            if self.navigationController?.visibleViewController == self {
                let meetups = self.meetupsArray

                if let selectedObject = meetups.filter({ (meetup: Meetup) -> Bool in
                    return meetup.recordName == recordName
                }).first {
                    performSegue(withIdentifier: "ShowDetail", sender: selectedObject)
                }

            } else {
                _ = self.navigationController?.popToRootViewController(animated: false)
                searchedObjectId = recordName
            }

//        } else {
//            //cache object
//            searchedObjectId = objectId
//        }
    }


    //MARK: - Segues

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ShowDetail" {
            if let selectedObject = sender as? Meetup {
                let detailViewController = segue.destination as! DetailViewController
                detailViewController.dataSource = MeetupDataSource(object: selectedObject)

                Answers.logContentView(withName: "Show Meetup details",
                                               contentType: "Meetup",
                                               contentId: selectedObject.meetup_id!,
                                               customAttributes: nil)
            } else if let indexPath = self.tableView.indexPath(for: sender as! UITableViewCell) {
                let meetup = self.meetupsArray[indexPath.row]
                let detailViewController = segue.destination as! DetailViewController
                detailViewController.dataSource = MeetupDataSource(object: meetup)
                Answers.logContentView(withName: "Show Meetup details",
                                               contentType: "Meetup",
                                               contentId: meetup.meetup_id!,
                                               customAttributes: nil)
            }
        }
    }

    //MARK: - UITableViewDataSource

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        return self.meetupsArray.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCell(withIdentifier: MeetupCell.Identifier, for: indexPath) as! MeetupCell

        let meetup = self.meetupsArray[indexPath.row]
        cell.configureCellForMeetup(meetup, row: indexPath.row)

        return cell

    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }

    override func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return CGFloat(88)
    }

    //MARK: - UITableViewDelegate

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.performSegue(withIdentifier: "ShowDetail", sender: tableView.cellForRow(at: indexPath))
        self.tableView.deselectRow(at: indexPath, animated: true)
    }

    //MARK: - fetching Cloudkit

    func fetchMeetups() {

        let pred = NSPredicate(value: true)
        let sort = NSSortDescriptor(key: "time", ascending: false)
        let query = CKQuery(recordType: "Meetup", predicate: pred)
        query.sortDescriptors = [sort]

        let operation = CKQueryOperation(query: query)
        operation.qualityOfService = .userInteractive

        var meetups = [Meetup]()

        operation.recordFetchedBlock = { (record) in
            let meetup = Meetup.meetup(forRecord: record)
            let _ = meetup.smallLogoImage
            let _ = meetup.logoImage
            meetups.append(meetup)
        }

        operation.queryCompletionBlock = { [weak self] (cursor, error) in
            DispatchQueue.main.async {
                guard error == nil else {
                    let ac = UIAlertController(
                        title: "Fetch failed",
                        message: "There was a problem fetching the list of meetups; please try again: \(error!.localizedDescription)", preferredStyle: .alert)
                    ac.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                    self?.present(ac, animated: true, completion: nil)
                    return
                }
                
                self?.realm.beginWrite()
                self?.realm.add(meetups, update: true)
                try! self?.realm.commitWrite()
                
                self?.activityIndicatorView.stopAnimating()
                self?.activityIndicatorView.hidesWhenStopped = true
            }
        }

        CKContainer.default().publicCloudDatabase.add(operation)

    }


}
