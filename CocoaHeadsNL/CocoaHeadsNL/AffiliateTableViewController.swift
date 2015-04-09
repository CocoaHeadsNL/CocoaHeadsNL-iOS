//
//  AffiliateTableViewController.swift
//  CocoaHeadsNL
//
//  Created by Jeroen Leenarts on 26/03/15.
//  Copyright (c) 2015 Stichting CocoaheadsNL. All rights reserved.
//

import Foundation

class AffiliateTableViewController : PFQueryTableViewController {
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        self.parseClassName = "affiliateLinks"
        self.pullToRefreshEnabled = true
        self.paginationEnabled = true
        self.objectsPerPage = 50
    }
    
    override func viewDidLoad() {
        self.loadObjects()
    }
    
    override func viewWillAppear(animated: Bool) {
        self.tableView.reloadData()
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 80
    }
    
    //MARK: - UITableViewDataSource
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath, object: PFObject!) -> PFTableViewCell {
        let cellId = "affiliateCell"
        var cell = tableView.dequeueReusableCellWithIdentifier(cellId) as? PFTableViewCell
        if cell == nil {
            cell = PFTableViewCell(style: .Subtitle, reuseIdentifier: cellId)
        }
        
        if let cell = cell {
            if let affiliateLink = object as? AffiliateLink {
                if let textLabel = cell.textLabel {
                    textLabel.adjustsFontSizeToFitWidth = true
                    textLabel.text = affiliateLink.productName
                }
                if let detailTextLabel = cell.detailTextLabel {
                    detailTextLabel.text = affiliateLink.productCreator
                }
                if let imageView = cell.imageView {
                    if let affiliateId = affiliateLink.affiliateId {
                        imageView.image = UIImage(named: "CocoaHeadsNLLogo")
                        imageView.contentMode = .ScaleAspectFit

                        if let url = NSURL(string: "https://itunes.apple.com/lookup?id=\(affiliateId)") {
                            var request = NSURLRequest(URL: url)
                            let dataTask = NSURLSession.sharedSession().dataTaskWithRequest(request,
                                completionHandler: { [weak cell](data, response, error) -> Void in
                                    var parseError: NSError?
                                    let parsedObject: AnyObject? = NSJSONSerialization.JSONObjectWithData(data,
                                        options: NSJSONReadingOptions.AllowFragments,
                                        error:&parseError)
                                    if let root = parsedObject as? NSDictionary {
                                        if let results = root["results"] as? NSArray {
                                            if let result = results[0] as? NSDictionary {
                                                if let iconUrlString = result["artworkUrl100"] as? String {
                                                    if let url = NSURL(string: iconUrlString) {
                                                        var request = NSURLRequest(URL: url)
                                                        let dataTask = NSURLSession.sharedSession().dataTaskWithRequest(request,
                                                            completionHandler: { (data, response, error) -> Void in
                                                                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                                                                    if let cell = cell {
                                                                        let image = UIImage(data: data)
                                                                        imageView.image = image
                                                                        cell.setNeedsLayout()
                                                                    }
                                                                })
                                                        })
                                                        dataTask.resume()
                                                    }
                                                }
                                            }
                                        }
                                    }
                            })
                            dataTask.resume()
                        }
                    }
                }
            }
        }
        
        return cell!
    }
    
    //MARK: - UITableViewDelegate
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if let affiliateToken = PFConfig.currentConfig()["appleAffiliateToken"] as? String {
            if let affiliateLink = self.objectAtIndexPath(indexPath) as? AffiliateLink {
                if let affiliateId = affiliateLink.affiliateId {
                    if let url = NSURL(string: NSString(format: "https://itunes.apple.com/app/apple-store/id%@?at=%@&ct=app", affiliateId,
                        affiliateToken) as String) {
                        if UIApplication.sharedApplication().canOpenURL(url) {
                            if TARGET_IPHONE_SIMULATOR == 1 {
                                // No app store on simulator.
                                println("Actual device would open: \(url)")
                            } else {
                                UIApplication.sharedApplication().openURL(url)
                            }
                        }
                    }
                }
            }
        }
        
        self.tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
}
