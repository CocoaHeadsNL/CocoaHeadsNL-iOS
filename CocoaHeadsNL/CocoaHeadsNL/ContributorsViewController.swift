//
//  ContributorsViewController.swift
//  CocoaHeadsNL
//
//  Created by Berend Schotanus on 27-08-15.
//  Copyright (c) 2015 Stichting CocoaheadsNL. All rights reserved.
//

import Foundation

class ContributorsViewController: PFQueryTableViewController {
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.parseClassName = "Contributor"
        self.paginationEnabled = false
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let nib = UINib(nibName: "ContributorCell", bundle: nil)
        self.tableView.registerNib(nib, forCellReuseIdentifier: ContributorCell.Identifier)
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath, object: PFObject?) -> PFTableViewCell? {
        var cell = tableView.dequeueReusableCellWithIdentifier(ContributorCell.Identifier, forIndexPath: indexPath) as! ContributorCell
        
        if let contributor = object as? Contributor {
            cell.nameLabel.text = contributor.name
            cell.urlLabel.text = contributor.avatar_url
        }
        
        return cell
    }
    
}
