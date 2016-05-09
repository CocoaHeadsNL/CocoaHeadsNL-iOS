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

class ContributorTableViewController: UITableViewController {
    
    var contributors = [Contributor]()
    
    //MARK: - View LifeCycle
    
    override func viewWillAppear(animated: Bool) {
        
        self.fetchContributors()
    }
    
    //MARK: - UITableViewDataSource
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return self.contributors.count
        
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("contributorCell", forIndexPath: indexPath)
        
        let contributor = self.contributors[indexPath.row]
        
        if let name = contributor.name {
            cell.textLabel?.text = name
        }
        
        if let url = contributor.url {
            cell.detailTextLabel?.text = url
        }
        
        if let a = contributor.avatar_url, url = NSURL(string: a) {
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
    
        guard let urlString = contributors[indexPath.row].url else {
            return
        }
        
        if let url = NSURL(string: urlString) {
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

    
    //MARK: - fetching Cloudkit
    
    func fetchContributors() {
        
        let pred = NSPredicate(value: true)
        let sort = NSSortDescriptor(key: "commit_count", ascending: false)
        let query = CKQuery(recordType: "Contributor", predicate: pred)
        query.sortDescriptors = [sort]
        
        let operation = CKQueryOperation(query: query)
        
        var CKContributor = [Contributor]()
        
        operation.recordFetchedBlock = { (record) in
            let contributor = Contributor()
            
            contributor.recordID = record.recordID 
            contributor.name = record["name"] as? String
            contributor.url = record["url"] as? String
            contributor.avatar_url = record["avatar_url"] as? String
            contributor.contributor_id = record["contributor_id"] as? Int64
  
            CKContributor.append(contributor)
        }
        
        operation.queryCompletionBlock = { [unowned self] (cursor, error) in
            dispatch_async(dispatch_get_main_queue()) {
                if error == nil {

                    self.contributors = CKContributor
                    self.tableView.reloadData()
                    
                } else {
                    let ac = UIAlertController(title: "Fetch failed", message: "There was a problem fetching the list of contributors; please try again: \(error!.localizedDescription)", preferredStyle: .Alert)
                    ac.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
                    self.presentViewController(ac, animated: true, completion: nil)
                }
            }
        }
        
        CKContainer.defaultContainer().publicCloudDatabase.addOperation(operation)
        
    }

    
}