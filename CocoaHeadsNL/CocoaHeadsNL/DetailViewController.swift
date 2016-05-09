//
//  DetailViewController.swift
//  CocoaHeadsNL
//
//  Created by Bart Hoffman on 14/03/15.
//  Copyright (c) 2015 Stichting CocoaheadsNL. All rights reserved.
//

import UIKit
import StoreKit

extension UIResponder {
    func reloadCell(cell: UITableViewCell) {
        self.nextResponder()?.reloadCell(cell)
    }
}

class DetailViewController: UITableViewController, SKStoreProductViewControllerDelegate {
    var dataSource: DetailDataSource!
    weak var presentingVC: UIViewController?
    private var activityViewController: UIActivityViewController?
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        //Can be used to hide masterViewController and increase size of detailView if wanted
        self.navigationItem.leftBarButtonItem = splitViewController?.displayModeButtonItem()
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

    override func didRotateFromInterfaceOrientation(fromInterfaceOrientation: UIInterfaceOrientation) {
        for object in self.tableView.visibleCells {
            if let webCell = object as? WebViewCell {
                webCell.webViewDidFinishLoad(webCell.htmlWebView)
            }
        }
    }
        
    override func reloadCell(cell: UITableViewCell) {
        tableView.beginUpdates()
        tableView.endUpdates()
    }
    
    func showStoreView(parameters : [String : AnyObject], indexPath : NSIndexPath) {
        
        let storeViewController = SKStoreProductViewController()
        storeViewController.delegate = self
        
        storeViewController.loadProductWithParameters(parameters,
            completionBlock: {result, error in
                if result {
                    self.presentViewController(storeViewController,
                        animated: true, completion: nil)
                    self.tableView.deselectRowAtIndexPath(indexPath, animated: true)
                }
        })
    }
    
    func productViewControllerDidFinish(viewController:
        SKStoreProductViewController) {
            self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @available(iOS 9.0, *)
    override func previewActionItems() -> [UIPreviewActionItem] {
        let shareAction = UIPreviewAction(title: "Share", style: .Default) { (previewAction, viewController) in
            
            if let meetup = self.dataSource.object as? Meetup, let meetupId = meetup.meetup_id {
                let string: String = "http://www.meetup.com/CocoaHeadsNL/events/\(meetupId)/"
                let URL: NSURL = NSURL(string: string)!
                
                let acViewController = UIActivityViewController(activityItems: [string, URL], applicationActivities: nil)
                
                if let meetupVC = self.presentingVC {
                    self.activityViewController = acViewController
                    meetupVC.presentViewController(self.activityViewController!, animated: true, completion: nil)
                }
            }
        }
        
        let rsvpAction = UIPreviewAction(title: "RSVP", style: .Default) { (previewAction, viewController) in
            
             if let meetup = self.dataSource.object as? Meetup, let meetupId = meetup.meetup_id {
                if let URL = NSURL(string: "http://www.meetup.com/CocoaHeadsNL/events/\(meetupId)/") {
                    UIApplication.sharedApplication().openURL(URL)
                }
            }
        }
        
        return [rsvpAction, shareAction]
    }
}
