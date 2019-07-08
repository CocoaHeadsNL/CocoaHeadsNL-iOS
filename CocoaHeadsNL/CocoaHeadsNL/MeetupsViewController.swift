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
import CoreData

class MeetupsViewController: UITableViewController, UIViewControllerPreviewingDelegate {

    private var viewDidAppearCount = 0

    private lazy var fetchedResultsController: FetchedResultsController<Meetup> = {
        let fetchRequest = NSFetchRequest<Meetup>()
        fetchRequest.entity = Meetup.entity()
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "year", ascending: false), NSSortDescriptor(key: "time", ascending: false)]
        let frc = FetchedResultsController<Meetup>(fetchRequest: fetchRequest,
                                                     managedObjectContext: CoreDataStack.shared.viewContext,
                                                     sectionNameKeyPath: nil)
        frc.setDelegate(self.frcDelegate)
        return frc
    }()

    private lazy var frcDelegate: MeetupFetchedResultsControllerDelegate = { // swiftlint:disable:this weak_delegate
        return MeetupFetchedResultsControllerDelegate(tableView: self.tableView)
    }()

    var meetupsByYear: [String: [Meetup]] {
        get {
            return [:]
            // TODO: fix meetups by year
            // I am assuming ordering stays correct due to FIFO behavior.
//            var meetupsByYear = meetupsArray.reduce([String: [Meetup]]()) { (previousResult, meetup) -> [String: [Meetup]] in
//                guard let meetupTime = meetup.time else {
//                    return previousResult
//                }
//
//                var newResult = previousResult
//
//                let year = Calendar.current.component(.year, from: meetupTime)
//                let yearString: String
//
//                if meetup.isToday {
//                    yearString = NSLocalizedString("Today", comment: "Section title for todays meetup.")
//                }
//                else if meetup.isUpcoming {
//                    yearString = NSLocalizedString("Upcoming", comment: "Section title for upcoming meetups.")
//                } else {
//                    yearString = "\(year)"
//                }
//
//                if var meetupsForYear = newResult[yearString] {
//                    meetupsForYear.append(meetup)
//                    newResult[yearString] = meetupsForYear
//                } else {
//                    newResult[yearString] = [meetup]
//                }
//                return newResult
//            }
//
//            // Inverse the sorting of upcoming meetups.
//            if let upcomingMeetups = meetupsByYear[NSLocalizedString("Upcoming", comment: "Section title for upcoming meetups.")] {
//                meetupsByYear[NSLocalizedString("Upcoming", comment: "Section title for upcoming meetups.")] = upcomingMeetups.reversed()
//            }
//
//            return meetupsByYear
        }
    }

    fileprivate var sectionTitles: [String] {
        get {
            let sections = meetupsByYear.keys
            let today = sections.filter { $0 == NSLocalizedString("Today", comment: "Section title for todays meetup.") }
            let upcoming = sections.filter { $0 == NSLocalizedString("Upcoming", comment: "Section title for upcoming meetups.") }

            let rest = sections
                .filter { section in
                    return section != NSLocalizedString("Today", comment: "Section title for todays meetup.")
                        && section != NSLocalizedString("Upcoming", comment: "Section title for upcoming meetups.")
                }
                .sorted()
                .reversed()

            return today + upcoming + rest
        }
    }

    fileprivate func meetups(forSection section: Int) -> [Meetup] {
        return meetupsByYear[sectionTitles[section]]!
    }

    fileprivate func meetup(for indexPath: IndexPath) -> Meetup {
        return meetups(forSection: indexPath.section)[indexPath.row]
    }

    var searchedObjectId: String?

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
        if let pasteBoard = UIPasteboard(name: UIPasteboard.Name(rawValue: searchPasteboardName), create: false) {
            let uniqueIdentifier = pasteBoard.string
            if let components = uniqueIdentifier?.components(separatedBy: ":") {
                if components.count > 1 {
                    let objectId = components[1]
                    displayObject(objectId)
                }
            }
        }

        NotificationCenter.default.addObserver(self, selector: #selector(MeetupsViewController.searchOccured(_:)), name: NSNotification.Name(rawValue: searchNotificationName), object: nil)

        if #available(iOS 9.0, *) {
            if traitCollection.forceTouchCapability == .available {
                registerForPreviewing(with: self, sourceView: view)
            }
        } else {
            // Fallback on earlier versions
        }

        self.subscribe()

        let activityIndicatorView = UIActivityIndicatorView(style: UIActivityIndicatorView.Style.gray)
        tableView.backgroundView = activityIndicatorView
        self.activityIndicatorView = activityIndicatorView
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

        viewDidAppearCount = viewDidAppearCount + 1
        if viewDidAppearCount > 2 {
            RequestReview.requestReview()
        }
    }

    func subscribe() {
        let publicDB = CKContainer.default().publicCloudDatabase

        let subscription = CKQuerySubscription(recordType: "Meetup", predicate: NSPredicate(format: "TRUEPREDICATE"), options: .firesOnRecordCreation)

        let info = CKSubscription.NotificationInfo()

        info.alertBody = NSLocalizedString("New meetup has been added!")
        info.shouldBadge = true
        info.category = "MEETUP"

        subscription.notificationInfo = info

        publicDB.save(subscription, completionHandler: { _, _ in })
    }

    // MARK: - 3D Touch

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

    // MARK: - Search

    @objc func searchOccured(_ notification: Notification) {
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

    func displayObject(_ recordName: String) {
        //if !loading {
            if self.navigationController?.visibleViewController == self {
                //TODO: fix object displaying
//                let meetups = self.meetupsArray
//
//                if let selectedObject = meetups.filter({ (meetup: Meetup) -> Bool in
//                    return meetup.recordName == recordName
//                }).first {
//                    performSegue(withIdentifier: "ShowDetail", sender: selectedObject)
//                }

            } else {
                _ = self.navigationController?.popToRootViewController(animated: false)
                searchedObjectId = recordName
            }

//        } else {
//            //cache object
//            searchedObjectId = objectId
//        }
    }

    // MARK: - Segues

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ShowDetail" {
            if let selectedObject = sender as? Meetup {
                let detailViewController = segue.destination as! DetailViewController
                detailViewController.dataSource = MeetupDataSource(object: selectedObject)

            } else if let indexPath = self.tableView.indexPath(for: sender as! UITableViewCell) {
                let meetup = self.meetup(for: indexPath)
                let detailViewController = segue.destination as! DetailViewController
                detailViewController.dataSource = MeetupDataSource(object: meetup)
            }
        }
    }

    // MARK: - UITableViewDataSource
    override func numberOfSections(in tableView: UITableView) -> Int {
        return meetupsByYear.keys.count
    }

    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let label = UILabel(frame: .zero)
        label.text = sectionTitles[section]
        label.textAlignment = .center
        label.textColor = UIColor(white: 0.5, alpha: 0.8)
        label.backgroundColor = UIColor(white: 0.95, alpha: 0.95)
        label.sizeToFit()

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
        return UITableView.automaticDimension
    }

    override func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return CGFloat(88)
    }

    // MARK: - UITableViewDelegate

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.performSegue(withIdentifier: "ShowDetail", sender: tableView.cellForRow(at: indexPath))
        self.tableView.deselectRow(at: indexPath, animated: true)
    }

    // MARK: - fetching Cloudkit

    func fetchMeetups() {

        let pred = NSPredicate(value: true)
        let sort = NSSortDescriptor(key: "time", ascending: false)
        let query = CKQuery(recordType: "Meetup", predicate: pred)
        query.sortDescriptors = [sort]

        let operation = CKQueryOperation(query: query)
        operation.qualityOfService = .userInteractive

        var meetups = [Meetup]()

        operation.recordFetchedBlock = { (record) in
            let meetup = Meetup.meetup(forRecord: record, on: CoreDataStack.shared.viewContext)
            _ = meetup.smallLogoImage
            _ = meetup.logoImage
            meetups.append(meetup)
        }

        operation.queryCompletionBlock = { [weak self] (cursor, error) in
            DispatchQueue.main.async {
                guard error == nil else {
                    let ac = UIAlertController.fetchErrorDialog(whileFetching: NSLocalizedString("meetups"), error: error!)
                    self?.present(ac, animated: true, completion: nil)
                    return
                }

                let meetupNames = meetups.compactMap ({ $0.recordName })
                let predicate = NSPredicate(format: "NOT recordName IN %@", meetupNames)
                // TODO: write meetups to CoreData
//                let obsoleteMeetups = self?.realm.objects(Meetup.self).filter(predicate)
//                self?.realm.beginWrite()
//                self?.realm.add(meetups, update: true)
//                if let obsoleteMeetups = obsoleteMeetups {
//                    self?.realm.delete(obsoleteMeetups)
//                }
//                try! self?.realm.commitWrite()

                self?.activityIndicatorView.stopAnimating()
                self?.activityIndicatorView.hidesWhenStopped = true
            }
        }

        CKContainer.default().publicCloudDatabase.add(operation)

    }

}

class MeetupFetchedResultsControllerDelegate: NSObject, FetchedResultsControllerDelegate {

    private weak var tableView: UITableView?

    // MARK: - Lifecycle
    init(tableView: UITableView) {
        self.tableView = tableView
    }

    func fetchedResultsControllerDidPerformFetch(_ controller: FetchedResultsController<Meetup>) {
        tableView?.reloadData()
    }

    func fetchedResultsControllerWillChangeContent(_ controller: FetchedResultsController<Meetup>) {
        tableView?.beginUpdates()
    }

    func fetchedResultsControllerDidChangeContent(_ controller: FetchedResultsController<Meetup>) {
        tableView?.endUpdates()
    }

    func fetchedResultsController(_ controller: FetchedResultsController<Meetup>, didChangeObject change: FetchedResultsObjectChange<Meetup>) {
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

    func fetchedResultsController(_ controller: FetchedResultsController<Meetup>, didChangeSection change: FetchedResultsSectionChange<Meetup>) {
        guard let tableView = tableView else { return }
        switch change {
        case let .insert(_, index):
            tableView.insertSections(IndexSet(integer: index), with: .automatic)

        case let .delete(_, index):
            tableView.deleteSections(IndexSet(integer: index), with: .automatic)
        }
    }
}
