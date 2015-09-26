//
//  DetailViewController.swift
//  CocoaHeadsNL
//
//  Created by Bart Hoffman on 14/03/15.
//  Copyright (c) 2015 Stichting CocoaheadsNL. All rights reserved.
//

import UIKit

extension UIResponder {
    func reloadCell(cell: UITableViewCell) {
        self.nextResponder()?.reloadCell(cell)
    }
}

class DetailViewController: UITableViewController, SKStoreProductViewControllerDelegate {
    var dataSource: DetailDataSource!

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
}
