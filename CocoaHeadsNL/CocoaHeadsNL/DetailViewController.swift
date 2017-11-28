//
//  DetailViewController.swift
//  CocoaHeadsNL
//
//  Created by Bart Hoffman on 14/03/15.
//  Copyright (c) 2016 Stichting CocoaheadsNL. All rights reserved.
//

import UIKit
import StoreKit

extension UIResponder {
    @objc func reloadCell(_ cell: UITableViewCell) {
        self.next?.reloadCell(cell)
    }
}

class DetailViewController: UITableViewController, SKStoreProductViewControllerDelegate {
    var dataSource: DetailDataSource!
    weak var presentingVC: UIViewController?
    fileprivate var activityViewController: UIActivityViewController?

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        //Can be used to hide masterViewController and increase size of detailView if wanted
        self.navigationItem.leftBarButtonItem = splitViewController?.displayModeButtonItem
        self.navigationItem.leftItemsSupplementBackButton = true

        //For some reason this triggers correct resizing behavior when rotating views.
        self.tableView.estimatedRowHeight = 100

        if let dataSource = dataSource {
            dataSource.tableView = self.tableView
            self.tableView.dataSource = dataSource
            self.tableView.delegate = dataSource
            self.navigationItem.title = dataSource.title
        }

        if let data = dataSource as? CompanyDataSource {
            data.presenter = self
        }

        self.tableView.reloadData()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        var url: URL?
        var title: String?
        var activityType: String?

        if let companyDataSource = dataSource as? CompanyDataSource {
            if let urlString = companyDataSource.company.website, let titleString = companyDataSource.company.name {
                title = titleString
                url = URL(string: urlString)
                activityType = "nl.cocoaheads.app.company"
            }
        } else if let jobsDataSource = dataSource as? JobDataSource {
            title = jobsDataSource.job.title
            url = URL(string: jobsDataSource.job.link)
            activityType = "nl.cocoaheads.app.job"
        } else if let meetupDataSource = dataSource as? MeetupDataSource, let urlString = meetupDataSource.meetup.meetupUrl {
            title = meetupDataSource.meetup.name
            url = URL(string: urlString)
            activityType = "nl.cocoaheads.app.meetup"
        }

        if let title = title, let url = url, let activityType = activityType {
            let activity = NSUserActivity(activityType: activityType)
            activity.title = title

            guard var urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: false) else {
                return
            }

            if urlComponents.scheme == nil {
                urlComponents.scheme = "http"
            }

            guard let checkedUrl = urlComponents.url , urlComponents.scheme == "http" || urlComponents.scheme == "https" else {
                return
            }

            activity.webpageURL = checkedUrl
            activity.becomeCurrent()
            self.userActivity = activity
        }
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)

        if #available(iOS 9.0, *) {
            self.userActivity?.resignCurrent()
        }
    }

    override func reloadCell(_ cell: UITableViewCell) {
        tableView.beginUpdates()
        tableView.endUpdates()
    }

    func showStoreView(_ parameters: [String : AnyObject], indexPath: IndexPath) {

        let storeViewController = SKStoreProductViewController()
        storeViewController.delegate = self

        storeViewController.loadProduct(withParameters: parameters,
            completionBlock: {result, error in
                if result {
                    self.present(storeViewController,
                        animated: true, completion: nil)
                    self.tableView.deselectRow(at: indexPath, animated: true)
                }
        })
    }

    func productViewControllerDidFinish(_ viewController: SKStoreProductViewController) {
            self.dismiss(animated: true, completion: nil)
    }

    override var previewActionItems : [UIPreviewActionItem] {
        let shareAction = UIPreviewAction(title: NSLocalizedString("Share"), style: .default) { (previewAction, viewController) in

            if let meetup = self.dataSource.object as? Meetup, let meetupId = meetup.meetup_id {
                let string: String = "http://www.meetup.com/CocoaHeadsNL/events/\(meetupId)/"
                let URL: Foundation.URL = Foundation.URL(string: string)!

                let acViewController = UIActivityViewController(activityItems: [string, URL], applicationActivities: nil)

                if let meetupVC = self.presentingVC {
                    self.activityViewController = acViewController
                    meetupVC.present(self.activityViewController!, animated: true, completion: nil)
                }
            }
        }

        let rsvpAction = UIPreviewAction(title: NSLocalizedString("RSVP"), style: .default) { (previewAction, viewController) in

             if let meetup = self.dataSource.object as? Meetup, let meetupId = meetup.meetup_id {
                if let URL = URL(string: "http://www.meetup.com/CocoaHeadsNL/events/\(meetupId)/") {
                    UIApplication.shared.openURL(URL)
                }
            }
        }

        return [rsvpAction, shareAction]
    }
}
