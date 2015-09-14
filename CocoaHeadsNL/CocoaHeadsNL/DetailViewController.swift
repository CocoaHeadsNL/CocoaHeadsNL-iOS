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

class DetailViewController: UITableViewController {
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
}
