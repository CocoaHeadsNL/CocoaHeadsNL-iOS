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
    
    private var viewDidAppearCount = 0

    lazy var realm = {
        return try! Realm()
    }()

    lazy var meetupsArray = {
        return try! Realm().objects(Meetup.self).sorted(byKeyPath: "time", ascending: false)
    }()
    
    var meetupsByYear: [String: [Meetup]] {
        get {
            // I am assuming ordering stays correct due to FIFO behavior.
            var meetupsByYear = meetupsArray.reduce([String: [Meetup]]()) { (previousResult, meetup) -> [String: [Meetup]] in
                guard let meetupTime = meetup.time else {
                    return previousResult
                }

                var newResult = previousResult

                let year = Calendar.current.component(.year, from: meetupTime)
                let yearString: String
                
                if meetupTime.timeIntervalSince(Date()) > 0 {
                    yearString = NSLocalizedString("Upcoming", comment: "Section title for upcoming meetups.")
                } else {
                    yearString = "\(year)"
                }
                
                if var meetupsForYear = newResult[yearString] {
                    meetupsForYear.append(meetup)
                    newResult[yearString] = meetupsForYear
                } else {
                    newResult[yearString] = [meetup]
                }
                return newResult
            }
            
            // Inverse the sorting of upcoming meetups.
            if let upcomingMeetups = meetupsByYear[NSLocalizedString("Upcoming", comment: "Section title for upcoming meetups.")] {
                meetupsByYear[NSLocalizedString("Upcoming", comment: "Section title for upcoming meetups.")] = upcomingMeetups.reversed()
            }
            
            return meetupsByYear
        }
    }
    
    fileprivate var sectionTitles: [String] {
        get {
            return meetupsByYear.keys.sorted().reversed()
        }
    }
    
    fileprivate func meetups(forSection section: Int) -> [Meetup] {
        return meetupsByYear[sectionTitles[section]]!
    }
    
    fileprivate func meetup(for indexPath: IndexPath) -> Meetup {
        return meetups(forSection: indexPath.section)[indexPath.row]
    }
    
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

        let backItem = UIBarButtonItem(title: NSLocalizedString("Events"), style: .plain, target: nil, action: nil)
        self.navigationItem.backBarButtonItem = backItem

        let accessibilityLabel = NSLocalizedString("Upcoming and past events of CocoaHeadsNL")
        self.navigationItem.setupForRootViewController(withTitle: accessibilityLabel)

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
        self.notificationToken = meetupsArray.observe { (changes: RealmCollectionChange) in
            switch changes {
            case .initial:
                // Results are now populated and can be accessed without blocking the UI
                self.tableView.reloadData()
                break
            case .update(_, _, _, _):
//            case .update(_, let deletions, let insertions, let modifications):
                self.tableView.reloadData()
                break
//                // Query results have changed, so apply them to the TableView
//                self.tableView.beginUpdates()
//                self.tableView.insertRows(at: insertions.map { (NSIndexPath(row: $0, section: 0) as IndexPath) },
//                                          with: .automatic)
//                self.tableView.deleteRows(at: deletions.map { (NSIndexPath(row: $0, section: 0) as IndexPath) },
//                                          with: .automatic)
//                self.tableView.reloadRows(at: modifications.map { (NSIndexPath(row: $0, section: 0) as IndexPath) },
//                                          with: .automatic)
//                self.tableView.endUpdates()
//                break
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
        viewDidAppearCount = viewDidAppearCount + 1
        if viewDidAppearCount > 2 {
            RequestReview.requestReview()
        }
    }

    func subscribe() {
        let publicDB = CKContainer.default().publicCloudDatabase

        let subscription = CKQuerySubscription(recordType: "Meetup", predicate: NSPredicate(format: "TRUEPREDICATE"), options: .firesOnRecordCreation)


        let info = CKNotificationInfo()

        info.alertBody = NSLocalizedString("New meetup has been added!")
        info.shouldBadge = true
        info.category = "MEETUP"

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

            let meetup = self.meetup(for: indexPath)
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

    @objc func searchOccured(_ notification: Notification) -> Void {
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
                let meetup = self.meetup(for: indexPath)
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
    override func numberOfSections(in tableView: UITableView) -> Int {
        return meetupsByYear.keys.count
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let label = UILabel(frame: .zero)
        label.text = sectionTitles[section]
        label.textAlignment = .center
        label.textColor = UIColor(white: 0.5, alpha: 0.8)
        label.sizeToFit()
        label.backgroundColor = UIColor(white: 0.95, alpha: 0.5)
        return label
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return meetups(forSection: section).count
//        return meetupsByYearSection[section].1.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCell(withIdentifier: MeetupCell.Identifier, for: indexPath) as! MeetupCell

        let meetup = self.meetup(for: indexPath)
        cell.configureCellForMeetup(meetup)

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
                    let ac = UIAlertController.fetchErrorDialog(whileFetching: NSLocalizedString("meetups"), error: error!)
                    self?.present(ac, animated: true, completion: nil)
                    return
                }
                
                let meetupNames = meetups.flatMap({ $0.recordName })
                let predicate = NSPredicate(format: "NOT recordName IN %@", meetupNames)
                let obsoleteMeetups = self?.realm.objects(Meetup.self).filter(predicate)
                self?.realm.beginWrite()
                self?.realm.add(meetups, update: true)
                if let obsoleteMeetups = obsoleteMeetups {
                    self?.realm.delete(obsoleteMeetups)
                }
                try! self?.realm.commitWrite()
                
                self?.activityIndicatorView.stopAnimating()
                self?.activityIndicatorView.hidesWhenStopped = true
            }
        }

        CKContainer.default().publicCloudDatabase.add(operation)

    }


}
