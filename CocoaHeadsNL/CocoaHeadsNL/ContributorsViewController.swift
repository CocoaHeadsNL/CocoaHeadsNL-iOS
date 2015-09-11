//
//  ContributorsViewController.swift
//  CocoaHeadsNL
//
//  Created by Berend Schotanus on 27-08-15.
//  Copyright (c) 2015 Stichting CocoaheadsNL. All rights reserved.
//

import UIKit

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
        let cell = tableView.dequeueReusableCellWithIdentifier(ContributorCell.Identifier, forIndexPath: indexPath) as! ContributorCell
        
        if let contributor = object as? Contributor, name = contributor.name {
            cell.nameLabel.text = name
            cell.fetchTask?.cancel()
            if let a = contributor.avatar_url, url = NSURL(string: a) {
                let task = fetchImageTask(url, forImageView: cell.avatarView)
                cell.fetchTask = task
                task.resume()
            }
        } else {
            cell.nameLabel.text = "Somebody"
        }
        
        return cell
    }
    
    // MARK: Networking
    
    lazy var remoteSession: NSURLSession = {
        let config = NSURLSessionConfiguration.defaultSessionConfiguration()
        return NSURLSession(configuration: config)
    }()
    
    func fetchImageTask(url: NSURL, forImageView imageView: UIImageView) -> NSURLSessionDataTask {
        let task = remoteSession.dataTaskWithRequest(NSURLRequest(URL: url)) {
            (data, response, error) in
            
            let image = UIImage(data: data)
            dispatch_async(dispatch_get_main_queue()) {
                imageView.image = image
            }
        }
        return task
    }
    
}
