//
//  DetailTableViewController.swift
//  CocoaHeadsNL
//
//  Created by Bart Hoffman on 14/03/15.
//  Copyright (c) 2015 Stichting CocoaheadsNL. All rights reserved.
//

import Foundation
import UIKit
import MapKit

class DetailTableViewController: UITableViewController, UITableViewDataSource, UITableViewDelegate {
    var selectedObject: PFObject?
    var companyApps: NSMutableArray
    
    required init(coder aDecoder: NSCoder) {
        companyApps = NSMutableArray()
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        //Can be used to hide masterViewController and increase size of detailView if wanted
        self.navigationItem.leftBarButtonItem = splitViewController?.displayModeButtonItem()
        self.navigationItem.leftItemsSupplementBackButton = true

        //For some reason this triggers correct resizing behavior when rotating views.
        self.tableView.estimatedRowHeight = 100.0
        
        if let company = selectedObject as? Company {
            if company.hasApps {
                self.fetchAffiliateLinksFromParse(company)
            }
        }
    }
    
    func fetchAffiliateLinksFromParse(company: PFObject) {
        if let objectID = company.objectId {
            let affiliateQuery = PFQuery(className: "affiliateLinks")
            affiliateQuery.whereKey("company", equalTo: PFObject(withoutDataWithClassName: "Companies", objectId: objectID))
            
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
                        self.tableView.reloadData()
                    }
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
            if company.hasApps {
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

class LogoCell: UITableViewCell {
    @IBOutlet weak var logoImageView: PFImageView!

    var selectedObject: PFObject? {
        didSet{
            if selectedObject == oldValue {
                return
            }
            
            self.logoImageView.image = nil

            if let company = selectedObject as? Company {
                if let logo = company.logo {
                    self.logoImageView.file = logo
                }

            } else if let meetup = selectedObject as? Meetup {
                if let logoFile = meetup.logo {
                    self.logoImageView.file = logoFile
                }
            } else if let job = selectedObject as? Job {
                if let logoFile = job.logo {
                    self.logoImageView.file = logoFile
                }
            }
            
            if (self.logoImageView.image != nil) {
                self.logoImageView.loadInBackground({ (image, error) -> Void in
                    self.logoImageView.contentMode = .ScaleAspectFit
                })
            }
        }
    }
}

class  MapViewCell: UITableViewCell, MKMapViewDelegate {
    @IBOutlet weak var littleMap: MKMapView!
    
    var selectedObject: PFObject? {
        didSet{
            if selectedObject == oldValue {
                return
            }
            
            if let company = selectedObject as? Company {
            } else if let meetup = selectedObject as? Meetup {
                if let geoLoc = meetup.geoLocation {
                    let mapRegion = MKCoordinateRegion(center: CLLocationCoordinate2DMake(geoLoc.latitude, geoLoc.longitude), span: MKCoordinateSpanMake(0.01, 0.01))
                    littleMap.region = mapRegion;
                    
                    if let nameOfLocation = meetup.locationName {
                        var annotation = MapAnnotation(coordinate: CLLocationCoordinate2DMake(geoLoc.latitude, geoLoc.longitude), title: "Here it is!", subtitle: nameOfLocation) as MapAnnotation
                        littleMap.addAnnotation(annotation)
                    }
                }
            } else if let job = selectedObject as? Job {
            }
        }
    }
    
    func mapView(mapView: MKMapView!, viewForAnnotation annotation: MKAnnotation!) -> MKAnnotationView! {
        let annotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: "pinAnnotationView")
        annotationView.animatesDrop = true
        
        return annotationView
    }
    
    func mapView(mapView: MKMapView!, didSelectAnnotationView view: MKAnnotationView!) {
        if let meetup = selectedObject as? Meetup {
            if let geoLoc = meetup.geoLocation {
                self.openMapWithCoordinates(geoLoc.longitude, theLat: geoLoc.latitude)
            }
        }
    }
    
    //self.openMapWithCoordinates(geoLoc.longitude, theLat: geoLoc.latitude)
    
    func openMapWithCoordinates(theLon:Double, theLat:Double){
        if let meetup = selectedObject as? Meetup {
            var coordinate = CLLocationCoordinate2DMake(theLat, theLon)
            var placemark:MKPlacemark = MKPlacemark(coordinate: coordinate, addressDictionary:nil)
            
            var mapItem:MKMapItem = MKMapItem(placemark: placemark)
            
            if let nameOfLocation = meetup.locationName {
                mapItem.name = nameOfLocation
            }
            
            let launchOptions = [MKLaunchOptionsDirectionsModeKey : MKLaunchOptionsDirectionsModeDriving]
            
            var currentLocationMapItem:MKMapItem = MKMapItem.mapItemForCurrentLocation()
            
            MKMapItem.openMapsWithItems([currentLocationMapItem, mapItem], launchOptions: launchOptions)
        }
    }
}


enum CellMode {
    case Line1
    case Line2
    case Line3
}

class  TitleCell: UITableViewCell {
    @IBOutlet weak var titleLabel: UILabel!
    
    var cellMode = CellMode.Line1

    var selectedObject: PFObject? {
        didSet{
            if selectedObject == oldValue {
                return
            }
            
            if let company = selectedObject as? Company {
                switch cellMode {
                case .Line1:
                    if let email = company.emailAddress {
                        self.titleLabel.text = email
                    }
                case .Line2:
                    if let address = company.streetAddress {
                        self.titleLabel.text = address
                    }
                case .Line3:
                    if let zipcode = company.zipCode {
                        self.titleLabel.text = zipcode
                    }
                }
            } else if let meetup = selectedObject as? Meetup {
                switch cellMode {
                case .Line1:
                    if let nameOfHost = meetup.name {
                        titleLabel.text = nameOfHost
                    }
                case .Line2:
                    titleLabel.text = String("Number of Cocoaheads: \(meetup.yes_rsvp_count)")
                case .Line3:
                    if let date = meetup.time {
                        var dateFormatter = NSDateFormatter()
                        dateFormatter.dateStyle = .MediumStyle
                        dateFormatter.timeStyle = .ShortStyle
                        dateFormatter.dateFormat = "d MMMM, HH:mm a"
                        self.titleLabel.text = dateFormatter.stringFromDate(date)
                    }
                }
            } else if let job = selectedObject as? Job {
                switch cellMode {
                case .Line1:
                    if let jobTitle = job.title {
                        self.titleLabel.text = jobTitle
                    }
                case .Line2:
                    self.titleLabel.text = ""
                case .Line3:
                    self.titleLabel.text = ""
                }

            }
        }
    }
}

class  WebViewCell: UITableViewCell, UIWebViewDelegate {
    @IBOutlet weak var htmlWebView: UIWebView!
    
    @IBOutlet weak var heighLayoutConstraint: NSLayoutConstraint!
    var selectedObject: PFObject? {
        didSet{
            if selectedObject == oldValue {
                return
            }
            
            if let company = selectedObject as? Company {
//                if let webSite = company.website {
//                    let webString = "http://\(webSite)"
//                    
//                    let url = NSURL(string: webString)
//                    let urlRequest = NSURLRequest(URL: url!)
//                    self.htmlWebView.loadRequest(urlRequest)
//                    self.htmlWebView.scrollView.scrollEnabled = true
//                    tableView.reloadData()
//                }
            } else if let meetup = selectedObject as? Meetup {
                if let meetupDescription = meetup.meetup_description {
                    self.htmlWebView.loadHTMLString(meetupDescription, baseURL: NSURL(string:"http://jobs.cocoaheads.nl"))
                    self.htmlWebView.scrollView.scrollEnabled = false
                }
            } else if let job = selectedObject as? Job {
                if let vacanyContent = job.content {
                    self.htmlWebView.loadHTMLString(vacanyContent, baseURL: NSURL(string:"http://jobs.cocoaheads.nl"))
                    self.htmlWebView.scrollView.scrollEnabled = false
                }
            }
        }
    }
    
    func layoutWebView() {
        let size = htmlWebView.sizeThatFits(CGSize(width:htmlWebView.frame.width, height: 10000.0))
        
        if size.height != heighLayoutConstraint.constant {
            heighLayoutConstraint.constant =  size.height
            reloadCell(self)
        }
    }
    
    func webViewDidFinishLoad(webView: UIWebView) {
        layoutWebView()
    }
    
    func webView(webView: UIWebView, shouldStartLoadWithRequest request: NSURLRequest, navigationType: UIWebViewNavigationType) -> Bool {
        if navigationType == .LinkClicked {
            UIApplication.sharedApplication().openURL(request.URL!)
            return false
        }
        
        return true
    }
}

extension UIResponder {
    func reloadCell(cell:UITableViewCell) {
        self.nextResponder()?.reloadCell(cell)
    }
}

