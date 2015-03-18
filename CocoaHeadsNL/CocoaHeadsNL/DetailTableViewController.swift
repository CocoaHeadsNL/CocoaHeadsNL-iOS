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

class DetailTableViewController: UITableViewController, UIWebViewDelegate {
    
    var selectedObject: PFObject?
    
    @IBOutlet weak var logoImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var descriptiveTitle: UILabel!
    @IBOutlet weak var htmlWebView: UIWebView!
    @IBOutlet weak var littleMap: MKMapView!
    
    
    @IBOutlet weak var logoCell: UITableViewCell!
    @IBOutlet weak var mapViewCell: UITableViewCell!
    @IBOutlet weak var titleCell: UITableViewCell!
    @IBOutlet weak var descriptiveTitleCell: UITableViewCell!
    @IBOutlet weak var dateLabelCell: UITableViewCell!
    @IBOutlet weak var webViewCell: UITableViewCell!


    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        
        //Can be used to hide masterViewController and increase size of detailView if wanted
        self.navigationItem.leftBarButtonItem = splitViewController?.displayModeButtonItem()
        self.navigationItem.leftItemsSupplementBackButton = true
    }
    
    override func viewWillAppear(animated: Bool) {
        //tableView.frame = CGRect(origin: tableView.frame.origin, size: tableView.contentSize)
        
        if let company = selectedObject?.valueForKey("companyDescription") as? String {
            
            self.setupCompany()
            
        } else if let meetup = selectedObject?.valueForKey("meetup_description") as? String {
            
            self.setupMeeting()
            
        } else if let job = selectedObject?.valueForKey("content") as? String {
            
            self.setupVacancy()
        }
    
        tableView.reloadData()
    }
    
    func setupCompany() {
    
        if let logoFile = selectedObject?.objectForKey("logo") as? PFFile {
            logoFile.getDataInBackgroundWithBlock({ (imageData: NSData!, error: NSError!) -> Void in
                let logoData = UIImage(data: imageData)
                self.logoImageView.image = logoData
            })
        }
        
        if let name = selectedObject?.valueForKey("name") as? String {
            self.navigationItem.title = name
        }
        
        if let email = selectedObject?.valueForKey("emailAddress") as? String {
            self.titleLabel.text = email
        }
        
        if let address = selectedObject?.valueForKey("streetAddress") as? String {
            self.descriptiveTitle.text = address
        }
        
        if let zipcode = selectedObject?.valueForKey("zipCode") as? String {
            self.dateLabel.text = zipcode
        }
        
//        if let webSite = selectedObject?.valueForKey("website") as? String {
//            let webString = "http://\(webSite)"
//            
//            let url = NSURL(string: webString)
//            let urlRequest = NSURLRequest(URL: url!)
//            self.htmlWebView.loadRequest(urlRequest)
//            self.htmlWebView.scrollView.scrollEnabled = true
//            tableView.reloadData()
//        }
    }
    
    func setupVacancy() {
        
        if let title = selectedObject?.valueForKey("title") as? String {
            self.navigationItem.title = title
        }
        
        if let logoFile = selectedObject?.objectForKey("logo") as? PFFile {
            logoFile.getDataInBackgroundWithBlock({ (imageData: NSData!, error: NSError!) -> Void in
                let logoData = UIImage(data: imageData)
                self.logoImageView.image = logoData
            })
        }
        
        if let jobTitle = selectedObject?.valueForKey("title") as? String {
            self.titleLabel.text = jobTitle
        }
        
        if let vacanyContent = selectedObject?.valueForKey("content") as? String {
            self.htmlWebView.loadHTMLString(vacanyContent, baseURL: NSURL(string:"http://jobs.cocoaheads.nl"))
            self.htmlWebView.scrollView.scrollEnabled = false
        }
    }
    
    func setupMeeting() {
        
        if let nameOfHost = selectedObject?.valueForKey("name") as? String {
            titleLabel.text = nameOfHost
        }
        
        if let geoLoc = selectedObject?.valueForKey("geoLocation") as? PFGeoPoint {
            let mapRegion = MKCoordinateRegion(center: CLLocationCoordinate2DMake(geoLoc.latitude, geoLoc.longitude), span: MKCoordinateSpanMake(0.01, 0.01))
            littleMap.region = mapRegion;
            
            if let nameOfLocation = selectedObject?.valueForKey("locationName") as? String {
                var annotation = MapAnnotation(coordinate: CLLocationCoordinate2DMake(geoLoc.latitude, geoLoc.longitude), title: "Here it is!", subtitle: nameOfLocation) as MapAnnotation
                let annotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: "pinAnnotationView")
                annotationView.backgroundColor = UIColor.whiteColor()
                annotationView.alpha = 0.9
                littleMap.addAnnotation(annotation)
            }
        }
        
        if let numberOfPeople = selectedObject?.valueForKey("yes_rsvp_count") as? Int {
            descriptiveTitle.text = String("Number of Cocoaheads: \(numberOfPeople)")
        }
        
        if let date = selectedObject?.valueForKey("time") as? NSDate {
            var dateFormatter = NSDateFormatter()
            dateFormatter.dateStyle = .MediumStyle
            dateFormatter.timeStyle = .ShortStyle
            dateFormatter.dateFormat = "d MMMM, HH:mm a"
            self.dateLabel.text = dateFormatter.stringFromDate(date)
        }
        
        if let meetupDescription = selectedObject?.valueForKey("meetup_description") as? String {
            self.htmlWebView.loadHTMLString(meetupDescription, baseURL: NSURL(string:"http://jobs.cocoaheads.nl"))
            self.htmlWebView.scrollView.scrollEnabled = false
        }
        
        if let logoFile = selectedObject?.objectForKey("logo") as? PFFile {
            logoFile.getDataInBackgroundWithBlock({ (imageData: NSData!, error: NSError!) -> Void in
                let logoData = UIImage(data: imageData)
                self.logoImageView.image = logoData
            })
        }

    }
    
    func printSelectedObject()
    {
        if let object = selectedObject {
            println(selectedObject)
        }
    }

    func webView(webView: UIWebView, shouldStartLoadWithRequest request: NSURLRequest, navigationType: UIWebViewNavigationType) -> Bool {
        if navigationType == .LinkClicked {
            UIApplication.sharedApplication().openURL(request.URL)
            return false
        }
        
        return true
    }
    
    
    
}
