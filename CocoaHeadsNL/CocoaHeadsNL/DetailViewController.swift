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

class DetailViewController: UITableViewController, UITableViewDataSource, UITableViewDelegate {
    var selectedObject: PFObject?
    var companyApps = NSMutableArray()

    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override func viewDidLoad() {

        //Can be used to hide masterViewController and increase size of detailView if wanted
        self.navigationItem.leftBarButtonItem = splitViewController?.displayModeButtonItem()
        self.navigationItem.leftItemsSupplementBackButton = true

        //For some reason this triggers correct resizing behavior when rotating views.
        self.tableView.estimatedRowHeight = 100.0

        if let company = selectedObject as? Company {
            if let apps = company["hasApps"] as? Bool {
                self.fetchAffiliateLinksFromParse(company)
            }
        }

        self.tableView.reloadData()
    }

    func fetchAffiliateLinksFromParse(company: PFObject) {
        if let objectID = company.objectId {
            let affiliateQuery = PFQuery(className: "affiliateLinks")
            affiliateQuery.whereKey("company", equalTo: PFObject(withoutDataWithClassName: "Companies", objectId: objectID))
            affiliateQuery.cachePolicy = PFCachePolicy.CacheElseNetwork

            affiliateQuery.findObjectsInBackgroundWithBlock {
                (objects: [AnyObject]?, error: NSError?) -> Void in

                if error == nil {
                    // The find succeeded.
                    println("Successfully retrieved \(objects!.count) scores.")
                    // Do something with the found objects
                    if let objects = objects as? [PFObject] {
                        for object in objects {
                            self.companyApps.addObject(object)
                        }
                    }

                    self.tableView.reloadData()


                } else {
                    // Log details of the failure
                    println("Error: \(error!) \(error!.userInfo!)")
                }
            }
        }
    }

    override func viewWillAppear(animated: Bool) {
        if let company = selectedObject as? Company {
            if let name = company.name {
                self.navigationItem.title = name
            }
        } else if let meetup = selectedObject as? Meetup {
            if let title = meetup.name{
                self.navigationItem.title = title
            }
        } else if let job = selectedObject as? Job {
            if let title = job.title{
                self.navigationItem.title = title
            }
        }
    }

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        if let company = selectedObject as? Company {
            if let apps = company["hasApps"] as? Bool {
                return 2
            } else {
                return 1
            }
        } else if let meetup = selectedObject as? Meetup {
            return 1
        } else if let job = selectedObject as? Job {
            return 1
        }
        return 1
    }

    override func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if section == 1 {
            tableView.headerViewForSection(1)?.backgroundColor = UIColor.grayColor()
            return tableView.headerViewForSection(1)
        } else {
            let view = UIView(frame: CGRectMake(0, 0, 0, 0))
            return view
        }
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let company = selectedObject as? Company {
            //section 0 is company details
            if section == 0 {
                return 4
            } else {
                //section 1 = company apps
                return self.companyApps.count
                //only need default TableViewCell with image for icon and title.
            }
            // no map
            // no web
        } else if let meetup = selectedObject as? Meetup {
            return 6
        } else if let job = selectedObject as? Job {
            return 3
            //no map
            //no descriptiveTitle
            //no dateLabel
        }

        return 6
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var actualRow = indexPath.row

        if let company = selectedObject as? Company {
            if indexPath.section == 1 {
                //section 1 = company apps
                //need to return AffilitateCell
                let cellId = "affiliateCell"
                var cell = tableView.dequeueReusableCellWithIdentifier(cellId) as? UITableViewCell
                if cell == nil {
                    cell = UITableViewCell(style: .Subtitle, reuseIdentifier: cellId)
                }

                if let cell = cell {
                    if let affiliateLink = companyApps.objectAtIndex(indexPath.row) as? AffiliateLink {
                        if let textLabel = cell.textLabel {
                            textLabel.adjustsFontSizeToFitWidth = true
                            textLabel.text = affiliateLink.productName
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


            } else {
                if actualRow > 0 {
                    // no map
                    actualRow++
                }
                if actualRow > 4 {
                    // no web
                    actualRow++
                }
            }

        } else if let meetup = selectedObject as? Meetup {
        } else if let job = selectedObject as? Job {
            if actualRow > 0 {
                // no map
                actualRow++
            }
            if actualRow > 2 {
                //no descriptiveTitle
                actualRow++
            }
            if actualRow > 3 {
                //no dateLabel
                actualRow++
            }
        }
        switch actualRow {
        case 0:
            if let cell = tableView.dequeueReusableCellWithIdentifier("logoCell") as? LogoCell {
                cell.selectedObject = selectedObject
                return cell
            }
        case 1:
            if let cell = tableView.dequeueReusableCellWithIdentifier("mapViewCell") as? MapViewCell {
                cell.selectedObject = selectedObject
                return cell
            }
        case 2:
            if let cell = tableView.dequeueReusableCellWithIdentifier("titleCell") as? TitleCell {
                cell.cellMode = .Line1
                cell.selectedObject = selectedObject
                return cell
            }
        case 3:
            if let cell = tableView.dequeueReusableCellWithIdentifier("titleCell") as? TitleCell {
                cell.cellMode = .Line2
                cell.selectedObject = selectedObject
                return cell
            }
        case 4:
            if let cell = tableView.dequeueReusableCellWithIdentifier("titleCell") as? TitleCell {
                cell.cellMode = .Line3
                cell.selectedObject = selectedObject
                return cell
            }
        case 5:
            if let cell = tableView.dequeueReusableCellWithIdentifier("webViewCell") as? WebViewCell {
                cell.selectedObject = selectedObject
                return cell
            }
        default:
            assertionFailure("This should not happen.")
            return UITableViewCell()
        }

        assertionFailure("This should not happen.")
        return UITableViewCell()
    }

    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath.section == 1 {

            if let affiliateToken = PFConfig.currentConfig()["appleAffiliateToken"] as? String {
                if let affiliateLink = companyApps.objectAtIndex(indexPath.row) as? AffiliateLink {
                    if let affiliateId = affiliateLink.affiliateId {
                        if let url = NSURL(string: "https://itunes.apple.com/app/apple-store/id\(affiliateId)?at=\(affiliateToken)&ct=app") {

                            if UIApplication.sharedApplication().canOpenURL(url) {

                                UIApplication.sharedApplication().openURL(url)
                            }
                        }
                    }
                }
            }

            self.tableView.deselectRowAtIndexPath(indexPath, animated: true)
        }
    }

    override func reloadCell(cell:UITableViewCell) {
        tableView.beginUpdates()
        tableView.endUpdates()
    }

    override func didRotateFromInterfaceOrientation(fromInterfaceOrientation: UIInterfaceOrientation) {
        for object in self.tableView.visibleCells() {
            if let webCell = object as? WebViewCell {
                webCell.webViewDidFinishLoad(webCell.htmlWebView)
            }
        }
    }
}
